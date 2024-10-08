//+------------------------------------------------------------------+
//|                                                   BarekatEXP.mq4 |
//|                                   Copyright 2024, Kazem Ebrahimi |
//|             https://www.linkedin.com/in/kazem-ebrahimi-35573386/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Kazem Ebrahimi"
#property link      "https://www.linkedin.com/in/kazem-ebrahimi-35573386/"
#property version   "1.00"
#property strict


double   zHighSlow, zLowSlow;
double   zHighFast, zLowFast;
double   zigzagSlow, zigzagFast;

double   zHighSlowd, zLowSlowd;
double   zHighFastd, zLowFastd;
double   zigzagSlowd, zigzagFastd;

double   SMA;
double   MyPoint = Point;
double   SLPrice;
double   CurrentRSI, PrevRSI;
double   PrevStochMain, PrevStochSignal, CurrentStochMain, CurrentStochSignal;
double   count_tp; // number of TP
int      depthSlow, deviationSlow, backstepSlow;
int      depthFast, deviationFast, backstepFast;
int      SMAPeriod;
int      oldNumBars = 0; // check for new candles coming
int      Stop_Hunt; // StopLoss
int      tradeBuyFound = 0;
int      tradeSellFound = 0;
int      nextCandle = 0; // check at next candle
int      foundSellPos = 0;
int      foundBuyPos = 0;
int      SellStep1 = 0;//, SellStep2 = 0;
int      BuyStep1 = 0;//, BuyStep2 = 0;
int      RsiPeriod;
int      RsiMax, RsiMin;
int      StochPeriod;
int      StochMax, StochMin;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   zHighSlow = 0.0;
   zLowSlow = 0.0;

   zHighFast = 0.0;
   zLowFast = 0.0;

   zigzagSlow = 0.0;
   zigzagFast = 0.0;

   zHighSlowd = 0.0;
   zLowSlowd = 0.0;

   zHighFastd = 0.0;
   zLowFastd = 0.0;

   zigzagSlowd = 0.0;
   zigzagFastd = 0.0;

   SMA = 0;
   SMAPeriod = 0;

// Fast ZIGZAG
   depthFast = 9;
   deviationFast = 6;
   backstepFast = 3;

// Slow ZIGZAG
   depthSlow = 60;
   deviationSlow = 6;
   backstepSlow = 3;

// Simple Moving Average
   SMAPeriod = 182;

   SLPrice = 0;

   RsiPeriod = 14;
   CurrentRSI = 0;
   PrevRSI = 0;
   RsiMin = 30; //35
   RsiMax = 70; //65

   Stop_Hunt = 0;
   count_tp = 1;

   StochPeriod = 21;
   StochMin = 20;
   StochMax = 80;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int            diffSLPip = 0;
   int            result;
   MqlDateTime    DateTimeStr;
   datetime       date1;
   int            hour, min, day_of_week;
//---
   date1 = TimeCurrent();
   TimeToStruct(date1, DateTimeStr);
   hour = DateTimeStr.hour;
   min = DateTimeStr.min;
   day_of_week = DateTimeStr.day_of_week;

   if(Digits==3 || Digits==5)
      MyPoint=Point*10;

//if(((hour >= 9 && hour < 21)) && (day_of_week >= 1 && day_of_week <= 5))
     //{

      if(TotalOrdersCount() == 0)
        {
         //معامله فروش
         if(tradeSellFound)
           {
            diffSLPip = (int)(MathAbs(SLPrice - Bid) / MyPoint);
            result=OrderSend(Symbol(),OP_SELL,0.1,Bid,1,NormalizeDouble(SLPrice + (Stop_Hunt * MyPoint),Digits),NormalizeDouble(Bid - ((diffSLPip + Stop_Hunt) * count_tp * MyPoint),Digits),(string)SLPrice,0,0,clrRed);
            tradeSellFound = 0;
            tradeBuyFound = 0;
            foundSellPos = 0;
            foundBuyPos = 0;
            SellStep1 = 0;
            BuyStep1 = 0;
            SLPrice = 0;
           }

         //معامله خرید
         if(tradeBuyFound)
           {
            diffSLPip = (int)(MathAbs(SLPrice - Ask) / MyPoint);
            result=OrderSend(Symbol(),OP_BUY,0.1,Ask,1,NormalizeDouble(SLPrice - (Stop_Hunt * MyPoint),Digits),NormalizeDouble(Ask + ((diffSLPip + Stop_Hunt) * count_tp * MyPoint),Digits),(string)SLPrice,0,0,clrGreen);
            tradeBuyFound = 0;
            tradeSellFound = 0;
            foundSellPos = 0;
            foundBuyPos = 0;
            SellStep1 = 0;
            BuyStep1 = 0;
            SLPrice = 0;
           }

         CheckSlowZigZag();
         //به ازای هر کندل جدید ادامه دستورات اجرا خواهند شد
         if(!NewBarPresent())
            return;
         CheckFastZigZag();

        }
      else //Close Trade if reach to STOP or reach to other same point of ZIGZAG
        {
         RiskFree();
         //trailing();
         //closeTrade();
        }
     //}
  }
//***********************************************
// تابع چک کردن زیگزاگ کند
//***********************************************
void CheckSlowZigZag()
  {
   zigzagFast = iCustom(Symbol(), 0, "ZigZag", depthFast, deviationFast, backstepFast, 0, nextCandle); //value of zigzag fast
   zHighFast = iCustom(Symbol(), 0, "ZigZag", depthFast, deviationFast, backstepFast, 1, nextCandle); //High value of zigzag fast
   zLowFast = iCustom(Symbol(), 0, "ZigZag", depthFast, deviationFast, backstepFast, 2, nextCandle); //Low value of zigzag fast

   zigzagSlow = iCustom(Symbol(), 0, "ZigZag", depthSlow, deviationSlow, backstepSlow, 0, nextCandle); //value of zigzag slow
   zHighSlow = iCustom(Symbol(), 0, "ZigZag", depthSlow, deviationSlow, backstepSlow, 1, nextCandle); //High value of zigzag slow
   zLowSlow = iCustom(Symbol(), 0, "ZigZag", depthSlow, deviationSlow, backstepSlow, 2, nextCandle); //Low value of zigzag slow

   SMA = iMA(Symbol(), 0, SMAPeriod, 0, MODE_SMA, PRICE_WEIGHTED, nextCandle);

//سیگنال فروش
   if(zigzagFast == zigzagSlow && zHighFast == zigzagFast && zHighSlow == zigzagSlow && zigzagFast > 0.0 &&zigzagSlow > 0.0 && Bid > SMA && zHighFast == zHighSlow) // دو زیگزاگ بهم رسیده اند به با هم قفل شده اند و آماده فروش میشیم
     {
      foundSellPos = 1;
      foundBuyPos = 0;
      SLPrice = zigzagFast;
      SellStep1 = 0;
      BuyStep1 = 0;
      Comment("Sell Found ... ", SLPrice);
     }// End of IF
//سیگنال خرید
   if(zigzagFast == zigzagSlow && zLowFast == zigzagFast && zLowSlow == zigzagSlow && zigzagFast > 0.0 && zigzagSlow > 0.0 && Bid < SMA && zLowFast == zLowSlow) // دو زیگزاگ بهم رسیده اند به با هم قفل شده اند و آماده خرید میشیم
     {
      foundBuyPos = 1;
      foundSellPos = 0;
      SLPrice = zigzagFast;
      SellStep1 = 0;
      BuyStep1 = 0;
      Comment("Buy Found ... ", SLPrice);
     }// End of IF
  }
//***********************************************
// تابع چک کردن زیگزاگ سریع
//***********************************************
int CheckFastZigZag()
  {
   int   diffMAprice;

   SMA = iMA(Symbol(), 0, SMAPeriod, 0, MODE_SMA, PRICE_WEIGHTED, 0);
//diffMAprice = (int)(MathAbs(SMA - Bid) / MyPoint);
   /*
   / ZIGZAG Config
   */
   zigzagFast = iCustom(Symbol(), 0, "ZigZag", depthFast, deviationFast, backstepFast, 0, nextCandle + 1); //value of zigzag fast
   zHighFast = iCustom(Symbol(), 0, "ZigZag", depthFast, deviationFast, backstepFast, 1, nextCandle + 1); //High value of zigzag fast
   zLowFast = iCustom(Symbol(), 0, "ZigZag", depthFast, deviationFast, backstepFast, 2, nextCandle + 1); //Low value of zigzag fast

   diffMAprice = (int)(MathAbs(zigzagFast - Bid) / MyPoint);

   /*
   / Stoch Config
   */
//CurrentStochMain = iStochastic(Symbol(), 0, StochPeriod, 3, 6, MODE_SMA, 0, MODE_MAIN, nextCandle);
//CurrentStochSignal = iStochastic(Symbol(), 0, StochPeriod, 3, 6, MODE_SMA, 0, MODE_SIGNAL, nextCandle);
//PrevStochMain = iStochastic(Symbol(), 0, StochPeriod, 3, 6, MODE_SMA, 0, MODE_MAIN, nextCandle + 2);
//PrevStochSignal = iStochastic(Symbol(), 0, StochPeriod, 3, 6, MODE_SMA, 0, MODE_SIGNAL, nextCandle + 2);

   /*
   / RSI Config
   */
   /*   CurrentRSI = iRSI(Symbol(), 0, RsiPeriod, PRICE_CLOSE, nextCandle);
      PrevRSI = iRSI(Symbol(), 0, RsiPeriod, PRICE_CLOSE, nextCandle + 2); //for H4 +2

   //موقعیت فروش
      if(foundSellPos == 1 && diffMAprice > 110)
        {
         if(PrevRSI > RsiMax && CurrentRSI < RsiMax)
           {
            //if(zigzagFastd == zigzagSlowd && zHighFastd == zigzagFastd && zHighSlowd == zigzagSlowd && zigzagFastd > 0.0 &&zigzagSlowd > 0.0
         //&& Bid > SMA && zHighFastd == zHighSlowd)
            //if(PrevStochMain > PrevStochSignal && CurrentStochMain < CurrentStochSignal && CurrentStochMain < StochMax)// && CurrentStochSignal < StochMax)
              {
               tradeSellFound = 1;
               return(1);
              }
           }
        }
   //موقعیت خرید
      if(foundBuyPos == 1 && diffMAprice > 110)
        {
         if(PrevRSI < RsiMin && CurrentRSI > RsiMin)
           {
            //if(zigzagFastd == zigzagSlowd && zLowFastd == zigzagFastd && zLowSlowd == zigzagSlowd && zigzagFastd > 0.0 && zigzagSlowd > 0.0
         //&& Bid < SMA && zLowFastd == zLowSlowd)
            //if(PrevStochMain < PrevStochSignal && CurrentStochMain > CurrentStochSignal && CurrentStochMain > StochMin)// && CurrentStochSignal > StochMin)
              {
               tradeBuyFound = 1;
               return(1);
              }
           }
        }
        */

//موقعیت فروش
   if(foundSellPos == 1)// && diffMAprice > 80)
     {
      if(zigzagFast == zLowFast && zigzagFast > 0.0 && zLowFast > 0.0 && SellStep1 == 0 /*&& zigzagFast < SMA*/) //اولین لوی زیگزاگ سریع ایجاد می شود
        {
         SellStep1 = 1;         
        }
      if(zigzagFast == zHighFast && zigzagFast > 0.0 && zHighFast > 0.0 && SellStep1 == 1 /*&& zigzagFast < SMA*/)
        {
         tradeSellFound = 1;
         //SLPrice = zigzagFast;
         return(tradeSellFound);
        }
     }
//موقعیت خرید
   if(foundBuyPos == 1)// && diffMAprice > 80)
     {
      if(zigzagFast == zHighFast && zigzagFast > 0.0 && zHighFast > 0.0 && BuyStep1 == 0 /*&& zigzagFast > SMA*/) //اولین لوی زیگزاگ سریع ایجاد می شود
        {
         BuyStep1 = 1;         
        }
      if(zigzagFast == zLowFast && zigzagFast > 0.0 && zLowFast > 0.0 && BuyStep1 == 1 /*&& zigzagFast > SMA*/)
        {
         tradeBuyFound = 1;
         //SLPrice = zigzagFast;
         return(tradeBuyFound);
        }
     }

   return(0);
  }
//***********************************************
// تابع تریلینگ کردن استاپ لاس
//***********************************************
void closeTrade()
  {
   int      ordTick = 0;
   int      ordType = 0;
   int      result = 0;
   double   ordProfit = 0;

   CurrentRSI = iRSI(Symbol(), 0, RsiPeriod, PRICE_CLOSE, nextCandle);
   PrevRSI = iRSI(Symbol(), 0, RsiPeriod, PRICE_CLOSE, nextCandle + 1);

   for(int i=0; i<=OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
         ordTick = OrderTicket();
         ordType = OrderType();
         ordProfit = OrderProfit();
         Comment(ordProfit);
         if(ordType == OP_BUY)
           {
            if(CurrentRSI < RsiMin)
              {
               result = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrWhite);
              }
           }

         if(ordType == OP_SELL)
           {
            if(CurrentRSI > RsiMax)
              {
               result = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrWhite);
              }
           }
        }
     }
  }
//***********************************************
// تابع ریسک فری کردن
//***********************************************
void RiskFree()
  {
   int         i, indx = 0;
   int         modifyResult;
//int      diffProfit;
   double      newFractal;

   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         double   ordOp = OrderOpenPrice();
         double   ordSl = OrderStopLoss();
         double   ordTp = OrderTakeProfit();
         datetime orddatetime = OrderOpenTime();
         int      ordTick = OrderTicket();
         int      ordType = OrderType();

         //diffProfit = (int)(MathAbs(ordOp - Bid) / MyPoint);
         if(ordType == OP_BUY /*&& diffProfit >= 30*/ && ordSl < ordOp)
           {
            newFractal = findFractal(50, MODE_LOWER, 0, Ask, indx);
            if(newFractal != ordSl && newFractal > ordSl && newFractal > ordOp && newFractal != 0 && indx != 0 && orddatetime < Time[indx])
              {
               //modifyResult = OrderModify(ordTick, ordOp, (ordOp + (15 * MyPoint)), ordTp, 0, clrRed);
               modifyResult = OrderModify(ordTick, ordOp, newFractal, ordTp, 0, clrRed);
              }
           }
         if(ordType == OP_SELL /*&& diffProfit >= 30*/ && ordSl > ordOp)
           {
            newFractal = findFractal(50, MODE_UPPER, 0, Bid, indx);
            if(newFractal != ordSl && newFractal < ordSl && newFractal < ordOp && newFractal != 0 && indx != 0 && orddatetime < Time[indx])
              {
               //modifyResult = OrderModify(ordTick, ordOp, (ordOp - (15 * MyPoint)), ordTp, 0, clrRed);
               modifyResult = OrderModify(ordTick, ordOp, newFractal, ordTp, 0, clrRed);
              }
           }
        }
     }
  }
//***********************************************
// تابع تریلینگ کردن استاپ لاس
//***********************************************
void trailing()
  {
   int      i, indx = 0;
   double   newFractal;
   int      modifyResult;

   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         double ordOp = OrderOpenPrice();
         double ordSl = OrderStopLoss();
         double ordTp = OrderTakeProfit();
         datetime orddatetime = OrderOpenTime();
         int ordTick = OrderTicket();
         int ordType = OrderType();

         if(ordType == OP_BUY)
           {
            newFractal = findFractal(50, MODE_LOWER, 0, Ask, indx);
            //newFractal -= (Stop_Hunt * MyPoint);
            if(newFractal != ordSl && newFractal > ordSl && newFractal > ordOp && newFractal != 0 && indx != 0 && orddatetime < Time[indx])
              {
               modifyResult = OrderModify(ordTick, ordOp, newFractal, ordTp, 0, clrRed);
              }
           }
         if(ordType == OP_SELL)
           {
            newFractal = findFractal(50, MODE_UPPER, 0, Bid, indx);
            //newFractal += (Stop_Hunt * MyPoint);
            if(newFractal != ordSl && newFractal < ordSl && newFractal < ordOp && newFractal != 0 && indx != 0 && orddatetime < Time[indx])
              {
               modifyResult = OrderModify(ordTick, ordOp, newFractal, ordTp, 0, clrRed);
              }
           }
        }
     }
  }
//***********************************************
// تابع پیدا کردن آخرین فرکتال برای استاپ لاس
//***********************************************
double findFractal(int nbr, int mode, int timeframe, double price, int &index)
  {
   //SMA = iMA(Symbol(), 0, SMAPeriod, 0, MODE_SMA, PRICE_WEIGHTED, 0);
   for(int i=1; i<=nbr; i++)
     {
      double f=iFractals(NULL,timeframe,mode,i);
      if(f > 0 && mode == MODE_UPPER && f > price)// && f > SMA)
        {
         index = i;
         return(f);
        }
      if(f > 0 && mode == MODE_LOWER && f < price)// && f < SMA)
        {
         index = i;
         return(f);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//***********************************************
// تابع محاسبه تعداد معاملات باز
//***********************************************
int TotalOrdersCount()
  {
   int found = 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            found = 1;
           }
        }
     }
   if(found == 1)
     {
      return(1);
     }
   else
     {
      return(0);
     }
  }