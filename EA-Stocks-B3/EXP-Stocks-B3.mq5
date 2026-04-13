//+------------------------------------------------------------------+
//|                                                EXP-Stocks-B3.mq5 |
//|                           Copyright 2026, EXP Automação STI LTDA |
//|                                  https://www.expautomacao.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EXP Automação STI LTDA"
#property link "https://www.expautomacao.com.br"
#property version "2.00"
#property description "Expert Advisor para Ações com alta Liquidez na B3"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

//--- ENUMS ---
enum ENUM_ATR_TF
{
   ATR_CURRENT = 0,
   ATR_M15 = PERIOD_M15,
   ATR_M30 = PERIOD_M30,
   ATR_H1 = PERIOD_H1,
   ATR_H4 = PERIOD_H4,
   ATR_D1 = PERIOD_D1,
   ATR_W1 = PERIOD_W1
};
enum ENUM_RR_SET
{
   RR_1_1 = 1,
   RR_2_1 = 2,
   RR_3_1 = 3
};

//--- INPUTS ---
input group "GRUPO 1: CONFIGURAÇÕES DA TENDÊNCIA"

    input int InpMAPrincipal = 9;          // Período Média Tendência
input ENUM_MA_METHOD InpMATipo = MODE_EMA; // Tipo da Média

input group "GRUPO 2: CONFIGURAÇÕES DOS INDICADORES"

    input int InpOBVPeriod = 9;                        // Período SMA do OBV
input int InpRSIPeriod = 9;                            // Período RSI
input int InpMomPeriod = 9;                            // Período Momentum
input int InpMASecund = 9;                             // Período Médias Confirmação
input ENUM_APPLIED_VOLUME InpOBVVolType = VOLUME_TICK; // OBV: Tipo de Volume

input group "GRUPO 3: HABILITAÇÃO E RETENÇÃO"

    input bool InpUsarOBV = true;        // Usar OBV?
input bool InpUsarRSI = true;            // Usar RSI?
input bool InpUsarMomentum = true;       // Usar Momentum?
input int InpMaxRetention = 5;           // Max candles retenção sinal
input bool InpUsarFiltroReversao = true; // Filtro: reversão da slope da MA do indicador (6 candles)?

input group "GRUPO 4: GERENCIAMENTO DE RISCO"

    input double InpCapPercent = 10.0;      // % Capital por Operação
input ENUM_ATR_TF InpATR_TF = ATR_H1;       // Timeframe ATR
input int InpATRPeriod = 20;                // Período ATR
input double InpMultiplicadorStop = 2.0;    // Multiplicador do Stop (ATR)
input ENUM_RR_SET InpRR_Final = RR_1_1;     // Relação risco-retorno do alvo final
input double InpTakeProfitFactor = 1.0;     // Multiplicador livre do take profit final
input double InpVolP1 = 100.0;              // % volume para parcial 1
input double InpVolP2 = 0.0;                // % volume para parcial 2
input int InpMaxTradesDay = 1;              // Max Operações por Ativo/Dia
input double InpMaxDrawdown = 5.0;          // Max Drawdown Conta (%)
input string InpEAComment = "EA-Stocks-B3"; // Comentário nas Ordens

input group "GRUPO 5: BREAKEVEN"

    input double InpBreakEvenTrigger = 50.0; // Ativação do breakeven (% do stop)
input double InpBreakEvenOffset = 10.0;      // Offset do breakeven (% do stop)
input double InpMaxSLPrice = 5.0;            // Limite Stop (% Preço Ativo)

input group "GRUPO 6: OPERAÇÕES DE VENDA"

    input bool InpPermitirVenda = false; // Permitir operações de venda?

input group "GRUPO 7: HORÁRIOS E DIAS"

    input bool InpSegunda = false; // Operar Segunda?
input bool InpTerca = true;        // Operar Terça?
input bool InpQuarta = true;       // Operar Quarta?
input bool InpQuinta = true;       // Operar Quinta?
input bool InpSexta = false;       // Operar Sexta?

input int InpHoraIni = 12;      // Hora Início
input int InpMinIni = 0;        // Minuto Início
input int InpHoraFim = 17;      // Hora Fim
input int InpMinFim = 30;       // Minuto Fim
input bool InpCloseEnd = false; // Fechar tudo no fim do horário?

//--- GLOBAIS ---
int hMA_Pri, hOBV, hOBV_MA, hRSI, hRSI_MA, hMom, hMom_MA, hATR;
CTrade trade;
CSymbolInfo m_sym;
CPositionInfo m_pos;
const long EA_MAGIC = 123456;

bool InpDomingo = false; // Operar Domingo?
bool InpSabado = false;  // Operar Sábado?

struct SSignalArm
{
   bool armed;
   int bar;
};
SSignalArm m_buyOBV, m_buyRSI, m_buyMOM, m_sellOBV, m_sellRSI, m_sellMOM;

double m_sl_dist = 0, m_tp1 = 0, m_initial_lot = 0;
bool m_hit1 = false;
ulong m_last_ticket = 0;
bool m_ea_disabled = false;
double m_p1_vol = 0;
double m_tp2 = 0;
double m_tp3 = 0;
double m_tp_final = 0;

//--- Helper persistência ---
void SavePositionData(ulong ticket)
{
   string pref = "EA_MA_" + IntegerToString(ticket) + "_";
   GlobalVariableSet(pref + "sl_dist", m_sl_dist);
   GlobalVariableSet(pref + "tp1", m_tp1);
   GlobalVariableSet(pref + "tp_final", m_tp_final);
   GlobalVariableSet(pref + "p1_vol", m_p1_vol);
   GlobalVariableSet(pref + "init_lot", m_initial_lot);
}

void LoadPositionData(ulong ticket)
{
   string pref = "EA_MA_" + IntegerToString(ticket) + "_";
   if (GlobalVariableCheck(pref + "sl_dist"))
   {
      m_sl_dist = GlobalVariableGet(pref + "sl_dist");
      m_tp1 = GlobalVariableGet(pref + "tp1");
      m_tp_final = GlobalVariableGet(pref + "tp_final");
      m_p1_vol = GlobalVariableGet(pref + "p1_vol");
      m_initial_lot = GlobalVariableGet(pref + "init_lot");

      double cur_vol = PositionGetDouble(POSITION_VOLUME);
      m_hit1 = (cur_vol <= m_initial_lot - m_p1_vol + 0.00001);
   }
}

void ClearPositionData(ulong ticket)
{
   string pref = "EA_MA_" + IntegerToString(ticket) + "_";
   GlobalVariableDel(pref + "sl_dist");
   GlobalVariableDel(pref + "tp1");
   GlobalVariableDel(pref + "tp_final");
   GlobalVariableDel(pref + "p1_vol");
   GlobalVariableDel(pref + "init_lot");
}

double HelperNormalizePrice(double p)
{
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if (ts == 0)
      return NormalizeDouble(p, _Digits);
   return MathRound(p / ts) * ts;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (hMA_Pri != INVALID_HANDLE)
      IndicatorRelease(hMA_Pri);
   if (hOBV != INVALID_HANDLE)
      IndicatorRelease(hOBV);
   if (hOBV_MA != INVALID_HANDLE)
      IndicatorRelease(hOBV_MA);
   if (hRSI != INVALID_HANDLE)
      IndicatorRelease(hRSI);
   if (hRSI_MA != INVALID_HANDLE)
      IndicatorRelease(hRSI_MA);
   if (hMom != INVALID_HANDLE)
      IndicatorRelease(hMom);
   if (hMom_MA != INVALID_HANDLE)
      IndicatorRelease(hMom_MA);
   if (hATR != INVALID_HANDLE)
      IndicatorRelease(hATR);
}

//+------------------------------------------------------------------+
void OnTick()
{
   if (m_ea_disabled)
      return;

   static datetime last_time = 0;
   datetime cur_time = iTime(_Symbol, PERIOD_CURRENT, 0);
   bool is_new_bar = (cur_time != last_time);
   if (is_new_bar)
      last_time = cur_time;

   CheckDrawdown();

   if (!IsTradingTime())
   {
      if (InpCloseEnd && PositionSelect(_Symbol))
         trade.PositionClose(_Symbol);
      return;
   }

   if (!PositionSelect(_Symbol))
   {
      if (m_last_ticket > 0)
      {
         ClearPositionData(m_last_ticket);
         m_last_ticket = 0;
         m_sl_dist = 0;
      }
      if (is_new_bar)
         UpdateSignals();
      CheckEntry();
   }
   else
   {
      m_last_ticket = PositionGetInteger(POSITION_TICKET);
      if (m_sl_dist == 0)
         LoadPositionData(m_last_ticket);
      ManagePosition();
   }
}

//+------------------------------------------------------------------+
void UpdateSignals()
{
   int cur_bars = Bars(_Symbol, PERIOD_CURRENT);
   double v[], m[];
   ArrayResize(v, 3);
   ArrayResize(m, 3);
   ArraySetAsSeries(v, true);
   ArraySetAsSeries(m, true);

   if (CopyBuffer(hOBV, 0, 0, 3, v) > 2 && CopyBuffer(hOBV_MA, 0, 0, 3, m) > 2)
   {
      bool crossUp = (v[1] > m[1] && v[2] <= m[2]);
      if (crossUp && !m_buyOBV.armed)
      {
         m_buyOBV.armed = true;
         m_buyOBV.bar = cur_bars;
         PrintFormat("OBV COMPRA ARMADO: OBV[1]=%.2f, MA[1]=%.2f", v[1], m[1]);
      }
      // Desarma apenas a partir do candle SEGUINTE ao arme (regra: "novo toque a partir do candle seguinte")
      if (m_buyOBV.armed && (cur_bars - m_buyOBV.bar) >= 1 && v[1] <= m[1])
      {
         m_buyOBV.armed = false;
         Print("OBV COMPRA DESARMADO (Tocou a média)");
      }

      bool crossDown = (v[1] < m[1] && v[2] >= m[2]);
      if (crossDown && !m_sellOBV.armed)
      {
         m_sellOBV.armed = true;
         m_sellOBV.bar = cur_bars;
         PrintFormat("OBV VENDA ARMADO: OBV[1]=%.2f, MA[1]=%.2f", v[1], m[1]);
      }
      if (m_sellOBV.armed && (cur_bars - m_sellOBV.bar) >= 1 && v[1] >= m[1])
      {
         m_sellOBV.armed = false;
         Print("OBV VENDA DESARMADO (Tocou a média)");
      }
   }

   if (CopyBuffer(hRSI, 0, 0, 3, v) > 2 && CopyBuffer(hRSI_MA, 0, 0, 3, m) > 2)
   {
      if (v[1] > m[1] && v[2] <= m[2] && !m_buyRSI.armed)
      {
         m_buyRSI.armed = true;
         m_buyRSI.bar = cur_bars;
         Print("RSI COMPRA ARMADO");
      }
      if (m_buyRSI.armed && (cur_bars - m_buyRSI.bar) >= 1 && v[1] <= m[1])
      {
         m_buyRSI.armed = false;
         Print("RSI COMPRA DESARMADO");
      }
      if (v[1] < m[1] && v[2] >= m[2] && !m_sellRSI.armed)
      {
         m_sellRSI.armed = true;
         m_sellRSI.bar = cur_bars;
         Print("RSI VENDA ARMADO");
      }
      if (m_sellRSI.armed && (cur_bars - m_sellRSI.bar) >= 1 && v[1] >= m[1])
      {
         m_sellRSI.armed = false;
         Print("RSI VENDA DESARMADO");
      }
   }

   if (CopyBuffer(hMom, 0, 0, 3, v) > 2 && CopyBuffer(hMom_MA, 0, 0, 3, m) > 2)
   {
      if (v[1] > m[1] && v[2] <= m[2] && !m_buyMOM.armed)
      {
         m_buyMOM.armed = true;
         m_buyMOM.bar = cur_bars;
         Print("MOM COMPRA ARMADO");
      }
      if (m_buyMOM.armed && (cur_bars - m_buyMOM.bar) >= 1 && v[1] <= m[1])
      {
         m_buyMOM.armed = false;
         Print("MOM COMPRA DESARMADO");
      }
      if (v[1] < m[1] && v[2] >= m[2] && !m_sellMOM.armed)
      {
         m_sellMOM.armed = true;
         m_sellMOM.bar = cur_bars;
         Print("MOM VENDA ARMADO");
      }
      if (m_sellMOM.armed && (cur_bars - m_sellMOM.bar) >= 1 && v[1] >= m[1])
      {
         m_sellMOM.armed = false;
         Print("MOM VENDA DESARMADO");
      }
   }

   // Expiração por retenção máxima de candles
   if (m_buyOBV.armed && (cur_bars - m_buyOBV.bar) > InpMaxRetention)
      m_buyOBV.armed = false;
   if (m_buyRSI.armed && (cur_bars - m_buyRSI.bar) > InpMaxRetention)
      m_buyRSI.armed = false;
   if (m_buyMOM.armed && (cur_bars - m_buyMOM.bar) > InpMaxRetention)
      m_buyMOM.armed = false;
   if (m_sellOBV.armed && (cur_bars - m_sellOBV.bar) > InpMaxRetention)
      m_sellOBV.armed = false;
   if (m_sellRSI.armed && (cur_bars - m_sellRSI.bar) > InpMaxRetention)
      m_sellRSI.armed = false;
   if (m_sellMOM.armed && (cur_bars - m_sellMOM.bar) > InpMaxRetention)
      m_sellMOM.armed = false;
}

//+------------------------------------------------------------------+
// Verifica reversão da slope da MA de um indicador usando 6 candles fechados
// COMPRA: MA[1]>MA[2]>MA[3] (subindo) E MA[4]<MA[5]<MA[6] (vinha caindo)
// VENDA: MA[1]<MA[2]<MA[3] (caindo) E MA[4]>MA[5]>MA[6] (vinha subindo)
bool IsMARevertingUp(int hMAInd)
{
   double m[];
   ArraySetAsSeries(m, true);
   if (CopyBuffer(hMAInd, 0, 0, 7, m) < 7)
      return true;                                   // sem dados: libera
   bool recent_up = (m[1] > m[2]) && (m[2] > m[3]);  // [1],[2],[3] subindo
   bool prior_down = (m[4] < m[5]) && (m[5] < m[6]); // [4],[5],[6] caindo
   return (recent_up && prior_down);
}

bool IsMARevertingDown(int hMAInd)
{
   double m[];
   ArraySetAsSeries(m, true);
   if (CopyBuffer(hMAInd, 0, 0, 7, m) < 7)
      return true;
   bool recent_down = (m[1] < m[2]) && (m[2] < m[3]); // [1],[2],[3] caindo
   bool prior_up = (m[4] > m[5]) && (m[5] > m[6]);    // [4],[5],[6] subindo
   return (recent_down && prior_up);
}

//+------------------------------------------------------------------+
void CheckEntry()
{
   if (GetDailyTrades() >= InpMaxTradesDay)
      return;

   double ma[], price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   CopyBuffer(hMA_Pri, 0, 0, 2, ma);
   ArraySetAsSeries(ma, true);

   // Leitura dos valores do candle [1] (último fechado)
   double obv_v[], obv_m[], rsi_v[], rsi_m[], mom_v[], mom_m[];
   ArraySetAsSeries(obv_v, true);
   ArraySetAsSeries(obv_m, true);
   ArraySetAsSeries(rsi_v, true);
   ArraySetAsSeries(rsi_m, true);
   ArraySetAsSeries(mom_v, true);
   ArraySetAsSeries(mom_m, true);
   bool obv_data = (CopyBuffer(hOBV, 0, 0, 2, obv_v) > 1 && CopyBuffer(hOBV_MA, 0, 0, 2, obv_m) > 1);
   bool rsi_data = (CopyBuffer(hRSI, 0, 0, 2, rsi_v) > 1 && CopyBuffer(hRSI_MA, 0, 0, 2, rsi_m) > 1);
   bool mom_data = (CopyBuffer(hMom, 0, 0, 2, mom_v) > 1 && CopyBuffer(hMom_MA, 0, 0, 2, mom_m) > 1);

   // COMPRA: sinal armado + indicador[1] acima da MA[1] + slope da MA reverteu pra cima
   bool condBuy = (price > ma[1]);
   if (InpUsarOBV)
   {
      bool rev = !InpUsarFiltroReversao || IsMARevertingUp(hOBV_MA);
      condBuy = condBuy && m_buyOBV.armed && obv_data && (obv_v[1] > obv_m[1]) && rev;
   }
   if (InpUsarRSI)
   {
      bool rev = !InpUsarFiltroReversao || IsMARevertingUp(hRSI_MA);
      condBuy = condBuy && m_buyRSI.armed && rsi_data && (rsi_v[1] > rsi_m[1]) && rev;
   }
   if (InpUsarMomentum)
   {
      bool rev = !InpUsarFiltroReversao || IsMARevertingUp(hMom_MA);
      condBuy = condBuy && m_buyMOM.armed && mom_data && (mom_v[1] > mom_m[1]) && rev;
   }

   if (condBuy)
   {
      PrintFormat("CHECK ENTRY (BUY) | OBV[1]:%.4f>%.4f RSI[1]:%.2f>%.2f MOM[1]:%.4f>%.4f",
                  obv_v[1], obv_m[1], rsi_v[1], rsi_m[1], mom_v[1], mom_m[1]);
      OpenTrade(ORDER_TYPE_BUY);
   }

   if (InpPermitirVenda)
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      // VENDA: sinal armado + indicador[1] abaixo da MA[1] + slope da MA reverteu pra baixo
      bool condSell = (bid < ma[1]);
      if (InpUsarOBV)
      {
         bool rev = !InpUsarFiltroReversao || IsMARevertingDown(hOBV_MA);
         condSell = condSell && m_sellOBV.armed && obv_data && (obv_v[1] < obv_m[1]) && rev;
      }
      if (InpUsarRSI)
      {
         bool rev = !InpUsarFiltroReversao || IsMARevertingDown(hRSI_MA);
         condSell = condSell && m_sellRSI.armed && rsi_data && (rsi_v[1] < rsi_m[1]) && rev;
      }
      if (InpUsarMomentum)
      {
         bool rev = !InpUsarFiltroReversao || IsMARevertingDown(hMom_MA);
         condSell = condSell && m_sellMOM.armed && mom_data && (mom_v[1] < mom_m[1]) && rev;
      }
      if (condSell)
         OpenTrade(ORDER_TYPE_SELL);
   }
}

//+------------------------------------------------------------------+
void OpenTrade(ENUM_ORDER_TYPE type)
{
   if (PositionSelect(_Symbol))
      return;

   double atr[];
   ArraySetAsSeries(atr, true);
   CopyBuffer(hATR, 0, 0, 2, atr); // atr[1] = candle fechado atual
   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double cap = AccountInfoDouble(ACCOUNT_BALANCE) * (InpCapPercent / 100.0);
   if (price <= 0)
      return;

   double lot;
   lot = cap / price;
   lot = MathFloor(lot / m_sym.LotsStep()) * m_sym.LotsStep();
   if (lot < m_sym.LotsMin())
      return;

   m_sl_dist = atr[1] * InpMultiplicadorStop; // atr[1] = ATR do candle fechado atual
   double max_sl = price * (InpMaxSLPrice / 100.0);
   if (m_sl_dist > max_sl)
      m_sl_dist = max_sl;

   double sl = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price - m_sl_dist : price + m_sl_dist);

   m_tp1 = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price + 1.0 * m_sl_dist : price - 1.0 * m_sl_dist);
   m_tp2 = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price + 2.0 * m_sl_dist : price - 2.0 * m_sl_dist);
   m_tp3 = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price + 3.0 * m_sl_dist : price - 3.0 * m_sl_dist);

   double tp_factor = InpTakeProfitFactor;
   if (tp_factor <= 0.0)
      tp_factor = (double)InpRR_Final;
   m_tp_final = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price + tp_factor * m_sl_dist : price - tp_factor * m_sl_dist);

   m_p1_vol = MathFloor((lot * (InpVolP1 / 100.0)) / m_sym.LotsStep()) * m_sym.LotsStep();
   double remaining_vol = lot - m_p1_vol;
   if (m_p1_vol < m_sym.LotsMin() || remaining_vol < m_sym.LotsMin())
      m_p1_vol = 0;
   if (m_p1_vol > lot)
      m_p1_vol = lot;
   m_initial_lot = lot;
   m_hit1 = false;

   double tp_final = m_tp_final;

   //--- Print completo (ATR, SL, TPs, estados dos indicadores) ---
   PrintFormat("============================================================");
   PrintFormat("ABRINDO %s | %s", (type == ORDER_TYPE_BUY) ? "COMPRA" : "VENDA", _Symbol);
   PrintFormat("Preco: %.2f | ATR[1]: %.2f | SL Dist: %.2f", price, atr[1], m_sl_dist);
   PrintFormat("SL: %.2f | TP1(1:1): %.2f | TP Final: %.2f", sl, m_tp1, m_tp_final);
   PrintFormat("Vol: %.0f | P1: %.0f", lot, m_p1_vol);
   PrintFormat("============================================================");

   if (trade.PositionOpen(_Symbol, type, lot, price, sl, tp_final, InpEAComment))
   {
      PrintFormat("TRADE ABERTO | Ticket: %d", trade.ResultOrder());
      if (PositionSelect(_Symbol))
      {
         m_last_ticket = PositionGetInteger(POSITION_TICKET);
         SavePositionData(m_last_ticket);
      }
      ResetArmedSignals();
   }
   else
   {
      PrintFormat("ERRO AO ABRIR: %d - %s", trade.ResultRetcode(), trade.ResultComment());
   }
}

//+------------------------------------------------------------------+
void ManagePosition()
{
   if (!m_pos.Select(_Symbol))
      return;
   if (m_pos.Magic() != EA_MAGIC)
      return;

   bool isBuy = (m_pos.PositionType() == POSITION_TYPE_BUY);
   double price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double entry = m_pos.PriceOpen();
   double cur_sl = HelperNormalizePrice(m_pos.StopLoss());
   double cur_tp = HelperNormalizePrice(m_pos.TakeProfit());
   double profit_dist = isBuy ? (price - entry) : (entry - price);

   double tp_final_ativo = (cur_tp > 0.0) ? cur_tp : m_tp_final;

   //--- Breakeven ---
   double be_activation = m_sl_dist * (InpBreakEvenTrigger / 100.0);
   double be_offset = m_sl_dist * (InpBreakEvenOffset / 100.0);
   double breakeven_sl = HelperNormalizePrice(isBuy ? entry + be_offset : entry - be_offset);
   bool breakeven_done = isBuy ? (cur_sl >= breakeven_sl && cur_sl >= entry) : (cur_sl <= breakeven_sl && cur_sl <= entry);

   if (!breakeven_done && m_sl_dist > 0 && profit_dist >= be_activation)
   {
      if (trade.PositionModify(_Symbol, breakeven_sl, tp_final_ativo))
      {
         PrintFormat("BREAKEVEN: SL -> %.2f | gatilho %.2f%% do stop", breakeven_sl, InpBreakEvenTrigger);
         cur_sl = breakeven_sl;
      }
      else
      {
         Print("ERRO BREAKEVEN: ", trade.ResultRetcode(), " - ", trade.ResultComment());
      }
   }

   //--- Parcial 1 ---
   if (!m_hit1 && m_p1_vol > 0 && ((isBuy && price >= m_tp1) || (!isBuy && price <= m_tp1)))
   {
      double vol_to_close = MathMin(m_p1_vol, m_pos.Volume());
      PrintFormat("PARCIAL 1: Fechando %.0f de %.0f", vol_to_close, m_pos.Volume());
      bool ok = isBuy ? trade.Sell(vol_to_close, _Symbol) : trade.Buy(vol_to_close, _Symbol);
      if (ok)
      {
         m_hit1 = true;
         if (PositionSelect(_Symbol))
         {
            double new_sl = HelperNormalizePrice(isBuy ? entry + be_offset : entry - be_offset);
            if (trade.PositionModify(_Symbol, new_sl, tp_final_ativo))
               PrintFormat("POS-PARCIAL: SL -> %.2f | TP Final mantido em %.2f", new_sl, tp_final_ativo);
         }
         return;
      }
      else
      {
         Print("ERRO PARCIAL 1: ", trade.ResultRetcode(), " - ", trade.ResultComment());
      }
   }
}

//+------------------------------------------------------------------+
bool IsTradingTime()
{
   MqlDateTime dt;
   TimeCurrent(dt);

   // Filtro de dia da semana
   switch (dt.day_of_week)
   {
   case 0:
      if (!InpDomingo)
         return false;
      break;
   case 1:
      if (!InpSegunda)
         return false;
      break;
   case 2:
      if (!InpTerca)
         return false;
      break;
   case 3:
      if (!InpQuarta)
         return false;
      break;
   case 4:
      if (!InpQuinta)
         return false;
      break;
   case 5:
      if (!InpSexta)
         return false;
      break;
   case 6:
      if (!InpSabado)
         return false;
      break;
   }

   int cur = dt.hour * 60 + dt.min, start = InpHoraIni * 60 + InpMinIni, end_t = InpHoraFim * 60 + InpMinFim;
   return (cur >= start && cur < end_t);
}

int GetDailyTrades()
{
   HistorySelect(iTime(_Symbol, PERIOD_D1, 0), TimeCurrent());
   int cnt = 0;
   for (int i = HistoryDealsTotal() - 1; i >= 0; i--)
   {
      ulong t = HistoryDealGetTicket(i);
      if (HistoryDealGetInteger(t, DEAL_MAGIC) == EA_MAGIC && HistoryDealGetInteger(t, DEAL_ENTRY) == DEAL_ENTRY_IN && HistoryDealGetString(t, DEAL_SYMBOL) == _Symbol)
         cnt++;
   }
   return cnt;
}

void CheckDrawdown()
{
   double bal = AccountInfoDouble(ACCOUNT_BALANCE), eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if (bal > 0 && (bal - eq) / bal * 100.0 >= InpMaxDrawdown)
   {
      Print("!!! DRAWDOWN MÁXIMO ATINGIDO !!! Fechando todas as posições.");
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         if (m_pos.SelectByIndex(i) && m_pos.Magic() == EA_MAGIC)
         {
            ulong t = m_pos.Ticket();
            if (trade.PositionClose(t))
               ClearPositionData(t);
         }
      }
      // Desativa o EA persistentemente via variável global (sobrevive reinício)
      GlobalVariableSet("EA_MA_DISABLED_" + _Symbol, 1);
      m_ea_disabled = true;
      Print("EA DESATIVADO. Delete a variável global EA_MA_DISABLED_" + _Symbol + " para reativar.");
   }
}

void ResetArmedSignals()
{
   m_buyOBV.armed = false;
   m_buyRSI.armed = false;
   m_buyMOM.armed = false;
   m_sellOBV.armed = false;
   m_sellRSI.armed = false;
   m_sellMOM.armed = false;
}

int OnInit()
{
   hMA_Pri = INVALID_HANDLE;
   hOBV = INVALID_HANDLE;
   hOBV_MA = INVALID_HANDLE;
   hRSI = INVALID_HANDLE;
   hRSI_MA = INVALID_HANDLE;
   hMom = INVALID_HANDLE;
   hMom_MA = INVALID_HANDLE;
   hATR = INVALID_HANDLE;

   if (!m_sym.Name(_Symbol))
      return INIT_FAILED;

   trade.SetExpertMagicNumber(EA_MAGIC);

   hMA_Pri = iMA(_Symbol, PERIOD_CURRENT, InpMAPrincipal, 0, InpMATipo, PRICE_CLOSE);
   hOBV = iOBV(_Symbol, PERIOD_CURRENT, InpOBVVolType);
   hOBV_MA = iMA(_Symbol, PERIOD_CURRENT, InpOBVPeriod, 0, MODE_SMA, hOBV);
   hRSI = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);
   hRSI_MA = iMA(_Symbol, PERIOD_CURRENT, InpMASecund, 0, MODE_SMA, hRSI);
   hMom = iMomentum(_Symbol, PERIOD_CURRENT, InpMomPeriod, PRICE_CLOSE);
   hMom_MA = iMA(_Symbol, PERIOD_CURRENT, InpMASecund, 0, MODE_SMA, hMom);
   hATR = iATR(_Symbol, (ENUM_TIMEFRAMES)InpATR_TF, InpATRPeriod);

   if (hMA_Pri == INVALID_HANDLE || hOBV == INVALID_HANDLE || hOBV_MA == INVALID_HANDLE || hRSI == INVALID_HANDLE || hRSI_MA == INVALID_HANDLE ||
       hMom == INVALID_HANDLE || hMom_MA == INVALID_HANDLE || hATR == INVALID_HANDLE)
   {
      Print("Erro ao criar os handles dos indicadores.");
      return INIT_FAILED;
   }

   m_ea_disabled = (GlobalVariableCheck("EA_MA_DISABLED_" + _Symbol) && GlobalVariableGet("EA_MA_DISABLED_" + _Symbol) > 0);

   return INIT_SUCCEEDED;
}
