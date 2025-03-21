//+------------------------------------------------------------------+
//|                                                    ZZConvDiv.mq4 |
//|                                   Copyright 2025, Kazem Ebrahimi |
//|             https://www.linkedin.com/in/kazem-ebrahimi-35573386/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Kazem Ebrahimi"
#property link      "https://www.linkedin.com/in/kazem-ebrahimi-35573386/"
#property version   "1.00"
#property strict
#property indicator_chart_window

datetime    startTime, endTime, frstHighDate, secHighDate, frstLowDate, secLowDate;
double      frstHigh, secHigh, frstLow, secLow;
double      zHighFast, zLowFast, zigzagFast;
double      frstHighRSI, secHighRSI, frstLowRSI, secLowRSI, valRSI;
double      frstHighMACD, secHighMACD, frstLowMACD, secLowMACD, valMACD;
int         zdepthFast, zdeviationFast, zbackstepFast;
int         fastEMAMACD, slowEMAMACD, macdSMA;
int         RsiPeriod;
int         Step;
int         oldNumBars = 0; // check for new candles coming
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---
   frstHigh = 0;
   secHigh = 0;
   frstLow = 0;
   secLow = 0;
   frstHighDate = 0;
   secHighDate = 0;
   frstLowDate = 0;
   secLowDate = 0;
   zHighFast = 0;
   zLowFast = 0;
   zigzagFast = 0;
// Fast ZIGZAG
   zdepthFast = 12;
   zdeviationFast = 5;
   zbackstepFast = 3;
// RSI Config
   RsiPeriod = 14;
   frstHighRSI = 0;
   secHighRSI = 0;
   frstLowRSI = 0;
   secLowRSI = 0;
   valRSI = 0;
// MACD Config
   fastEMAMACD = 12;
   slowEMAMACD = 26;
   macdSMA = 9;
   frstHighMACD = 0;
   secHighMACD = 0;
   frstLowMACD = 0;
   secLowMACD = 0;
   valMACD = 0;
// TrendLine Time Drawing
   startTime = 0;
   endTime = 0;

   Step = 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(!NewBarPresent())
      return(0);
   CheckZigZagStatus();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//***********************************************
// تابع چک کردن زیگزاگ ها
//***********************************************
void CheckZigZagStatus()
  {

   frstHigh = 0;
   secHigh = 0;
   frstLow = 0;
   secLow = 0;
   frstHighRSI = 0;
   secHighRSI = 0;
   frstLowRSI = 0;
   secLowRSI = 0;

   frstHighMACD = 0;
   secHighMACD = 0;
   frstLowMACD = 0;
   secLowMACD = 0;

   frstHighDate = 0;
   secHighDate = 0;
   frstLowDate = 0;
   secLowDate = 0;

//Load Data
   for(int i = 0; i < Bars; i++)
     {
      zHighFast = 0;
      zLowFast = 0;
      zigzagFast = 0;

      zigzagFast = iCustom(Symbol(), 0, "ZigZag", zdepthFast, zdeviationFast, zbackstepFast, 0, i); //value of zigzag fast
      zHighFast = iCustom(Symbol(), 0, "ZigZag", zdepthFast, zdeviationFast, zbackstepFast, 1, i); //High value of zigzag fast
      zLowFast = iCustom(Symbol(), 0, "ZigZag", zdepthFast, zdeviationFast, zbackstepFast, 2, i); //Low value of zigzag fast
      valRSI = iRSI(Symbol(), 0, RsiPeriod, PRICE_CLOSE, i);
      valMACD = iMACD(Symbol(), 0, fastEMAMACD, slowEMAMACD, macdSMA, PRICE_CLOSE, MODE_MAIN, i);

      if(Step < 4)
        {
         if(zHighFast == zigzagFast && zigzagFast > 0.0)
           {
            if(frstHigh == 0 && secHigh == 0)
              {
               frstHigh = zHighFast;
               frstHighDate = Time[i];
               frstHighRSI = valRSI;
               frstHighMACD = valMACD;
               Step++;
               continue;
              }
            else
               if(secHigh == 0 && frstHigh != 0)
                 {
                  secHigh = zHighFast;
                  secHighDate = Time[i];
                  secHighRSI = valRSI;
                  secHighMACD = valMACD;
                  Step++;
                  continue;
                 }
           }// End of IF


         if(zLowFast == zigzagFast && zigzagFast > 0.0)
           {
            if(frstLow == 0 && secLow == 0)
              {
               frstLow = zLowFast;
               frstLowDate = Time[i];
               frstLowRSI = valRSI;
               frstLowMACD = valMACD;
               Step++;
               continue;
              }
            else
               if(secLow == 0 && frstLow != 0)
                 {
                  secLow = zLowFast;
                  secLowDate = Time[i];
                  secLowRSI = valRSI;
                  secLowMACD = valMACD;
                  Step++;
                  continue;
                 }
           }// End of IF
        }
      else
         if(Step == 4 && frstHigh != 0 && secHigh != 0 && frstLow != 0 && secLow != 0)
           {
            ObjectsDeleteAll();
            ObjectCreate(ChartID(), "upline1", OBJ_TREND, 0, secHighDate, secHigh, frstHighDate, frstHigh);
            ObjectSetInteger(ChartID(), "upline1", OBJPROP_COLOR, clrLime);
            ObjectSetInteger(ChartID(), "upline1", OBJPROP_RAY, false);
            ObjectCreate(ChartID(), "upline2", OBJ_TREND, 0, secLowDate, secLow, frstLowDate, frstLow);
            ObjectSetInteger(ChartID(), "upline2", OBJPROP_COLOR, clrDeepSkyBlue);
            ObjectSetInteger(ChartID(), "upline2", OBJPROP_RAY, false);
            ObjectCreate(ChartID(), "upline3", OBJ_TREND, 1, secHighDate, secHighRSI, frstHighDate, frstHighRSI);
            ObjectSetInteger(ChartID(), "upline3", OBJPROP_COLOR, clrLime);
            ObjectSetInteger(ChartID(), "upline3", OBJPROP_RAY, false);
            ObjectCreate(ChartID(), "upline4", OBJ_TREND, 1, secLowDate, secLowRSI, frstLowDate, frstLowRSI);
            ObjectSetInteger(ChartID(), "upline4", OBJPROP_COLOR, clrDeepSkyBlue);
            ObjectSetInteger(ChartID(), "upline4", OBJPROP_RAY, false);
            ObjectCreate(ChartID(), "upline5", OBJ_TREND, 2, secHighDate, secHighMACD, frstHighDate, frstHighMACD);
            ObjectSetInteger(ChartID(), "upline5", OBJPROP_COLOR, clrLime);
            ObjectSetInteger(ChartID(), "upline5", OBJPROP_RAY, false);
            ObjectCreate(ChartID(), "upline6", OBJ_TREND, 2, secLowDate, secLowMACD, frstLowDate, frstLowMACD);
            ObjectSetInteger(ChartID(), "upline6", OBJPROP_COLOR, clrDeepSkyBlue);
            ObjectSetInteger(ChartID(), "upline6", OBJPROP_RAY, false);
            Step = 0;
            frstHigh = 0;
            secHigh = 0;
            frstLow = 0;
            secLow = 0;
            frstHighDate = 0;
            secHighDate = 0;
            frstLowDate = 0;
            secLowDate = 0;
            frstHighRSI = 0;
            secHighRSI = 0;
            frstLowRSI = 0;
            secLowRSI = 0;
            break;
           }
     }
  }
//+------------------------------------------------------------------+
bool NewBarPresent()
  {
   int bars = Bars;
   if(oldNumBars != bars)
     {
      oldNumBars = bars;
      return(true);
     }
   return(false);
  }