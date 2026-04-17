//+------------------------------------------------------------------+
//|                                               EXP-MultiAsset.mq5 |
//|                           Copyright 2026, EXP Automação STI LTDA |
//|                                  https://www.expautomacao.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EXP Automação STI LTDA"
#property link "https://www.expautomacao.com.br"
#property version "1.40"
#property description "Expert Advisor Multi-Ativo para Bovespa"
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
input int InpOBVPeriod = 9; // Período SMA do OBV
input int InpRSIPeriod = 9;                                                      // Período RSI
input int InpMomPeriod = 9;                                                      // Período Momentum
input int InpMASecund = 9;                                                       // Período Médias Confirmação
input ENUM_APPLIED_VOLUME InpOBVVolType = VOLUME_TICK;                           // OBV: Tipo de Volume

input group "GRUPO 3: HABILITAÇÃO E RETENÇÃO" 
input bool InpUsarOBV = false; // Usar OBV?
input bool InpUsarRSI = false;                                               // Usar RSI?                                              // Usar RSI?
input bool InpUsarMomentum = true;                                           // Usar Momentum?                                     // Usar Momentum?
input int InpMaxRetention = 5;                                               // Max candles retenção sinal
input bool InpUsarFiltroReversao = true;                                     // Filtro: reversão da slope da MA do indicador (6 candles)?

input group "GRUPO 4: GERENCIAMENTO DE RISCO" 
input double InpCapPercent = 10.0; // % Capital por Operação
input ENUM_ATR_TF InpATR_TF = ATR_H4;                                            // Timeframe ATR
input int InpATRPeriod = 20;                                                     // Período ATR
input double InpMultiplicadorStop = 3.0;                                         // Multiplicador do Stop (ATR)
input ENUM_RR_SET InpRR_Final = RR_3_1;                                          // Até qual parcial operar (1:1, 2:1, 3:1)
input double InpVolP1 = 100.0;                                                   // Volume 1ª Parcial (%)
input double InpVolP2 = 100.0;                                                   // Volume 2ª Parcial (%)
input int InpMaxTradesDay = 1;                                                   // Max Operações por Ativo/Dia
input double InpMaxDrawdown = 5.0;                                               // Max Drawdown Conta (%)
input string InpEAComment = "EXP-MultiAsset";                                    // Comentário nas Ordens

input group "GRUPO 5: TRAILING STOP E BREAKEVEN" 
input bool InpUseTrailing = true; // Habilitar Trailing Stop?
input double InpTrailActiv = 50.0;                                                 // Ativação (%) do Stop Inicial
input double InpProfitMin = 30.0;                                                  // Lucro Mínimo Breakeven (%)
input double InpMaxSLPrice = 3.0;                                                  // Limite Stop (% Preço Ativo)

input group "GRUPO 6: OPERAÇÕES DE VENDA" 
input bool InpPermitirVenda = true; // Permitir operações de venda?

input group "GRUPO 7: HORÁRIOS E DIAS"

input bool InpSegunda = false; // Operar Segunda?
input bool InpTerca = true;        // Operar Terça?
input bool InpQuarta = true;       // Operar Quarta?
input bool InpQuinta = true;       // Operar Quinta?
input bool InpSexta = false;       // Operar Sexta?

input int InpHoraIni = 11;      // Hora Início
input int InpMinIni = 15;       // Minuto Início
input int InpHoraFim = 17;      // Hora Fim
input int InpMinFim = 30;       // Minuto Fim
input bool InpCloseEnd = false; // Fechar tudo no fim do horário?

//--- GLOBAIS ---
int hMA_Pri, hOBV, hOBV_MA, hRSI, hRSI_MA, hMom, hMom_MA, hATR;
CTrade trade;
CSymbolInfo m_sym;
CPositionInfo m_pos;

bool InpDomingo = false; // Operar Domingo?
bool InpSabado = false;  // Operar Sábado?

struct SSignalArm
{
    bool armed;
    int bar;
};
SSignalArm m_buyOBV, m_buyRSI, m_buyMOM, m_sellOBV, m_sellRSI, m_sellMOM;

double m_sl_dist = 0, m_tp1 = 0, m_tp2 = 0, m_tp3 = 0, m_p1_vol = 0, m_p2_vol = 0, m_p3_vol = 0, m_initial_lot = 0;
bool m_hit1 = false, m_hit2 = false;
ulong m_last_ticket = 0;
bool m_ea_disabled = false;

//--- Helper persistência ---
void SavePositionData(ulong ticket)
{
    string pref = "EA_MA_" + IntegerToString(ticket) + "_";
    GlobalVariableSet(pref + "sl_dist", m_sl_dist);
    GlobalVariableSet(pref + "tp1", m_tp1);
    GlobalVariableSet(pref + "tp2", m_tp2);
    GlobalVariableSet(pref + "tp3", m_tp3);
    GlobalVariableSet(pref + "p1_vol", m_p1_vol);
    GlobalVariableSet(pref + "p2_vol", m_p2_vol);
    GlobalVariableSet(pref + "init_lot", m_initial_lot);
}

void LoadPositionData(ulong ticket)
{
    string pref = "EA_MA_" + IntegerToString(ticket) + "_";
    if (GlobalVariableCheck(pref + "sl_dist"))
    {
        m_sl_dist = GlobalVariableGet(pref + "sl_dist");
        m_tp1 = GlobalVariableGet(pref + "tp1");
        m_tp2 = GlobalVariableGet(pref + "tp2");
        m_tp3 = GlobalVariableGet(pref + "tp3");
        m_p1_vol = GlobalVariableGet(pref + "p1_vol");
        m_p2_vol = GlobalVariableGet(pref + "p2_vol");
        m_initial_lot = GlobalVariableGet(pref + "init_lot");

        double cur_vol = PositionGetDouble(POSITION_VOLUME);
        m_hit1 = (cur_vol <= m_initial_lot - m_p1_vol + 0.00001);
        m_hit2 = (cur_vol <= m_initial_lot - m_p1_vol - m_p2_vol + 0.00001);
    }
}

void ClearPositionData(ulong ticket)
{
    string pref = "EA_MA_" + IntegerToString(ticket) + "_";
    GlobalVariableDel(pref + "sl_dist");
    GlobalVariableDel(pref + "tp1");
    GlobalVariableDel(pref + "tp2");
    GlobalVariableDel(pref + "tp3");
    GlobalVariableDel(pref + "p1_vol");
    GlobalVariableDel(pref + "p2_vol");
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
int OnInit()
{
    if (GlobalVariableCheck("EA_MA_DISABLED_" + _Symbol) && GlobalVariableGet("EA_MA_DISABLED_" + _Symbol) == 1)
    {
        PrintFormat("EA DESATIVADO por drawdown anterior. Delete a variável global EA_MA_DISABLED_%s para reativar.", _Symbol);
        m_ea_disabled = true;
    }

    if (!m_sym.Name(_Symbol))
        return INIT_FAILED;
    trade.SetExpertMagicNumber(123456);
    trade.SetTypeFilling(ORDER_FILLING_RETURN);
    trade.SetDeviationInPoints(50);

    hMA_Pri = iMA(_Symbol, PERIOD_CURRENT, InpMAPrincipal, 0, InpMATipo, PRICE_CLOSE);
    hOBV = iOBV(_Symbol, PERIOD_CURRENT, InpOBVVolType);
    hOBV_MA = iMA(_Symbol, PERIOD_CURRENT, InpMASecund, 0, MODE_SMA, hOBV);
    hRSI = iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);
    hRSI_MA = iMA(_Symbol, PERIOD_CURRENT, InpMASecund, 0, MODE_SMA, hRSI);
    hMom = iMomentum(_Symbol, PERIOD_CURRENT, InpMomPeriod, PRICE_CLOSE);
    hMom_MA = iMA(_Symbol, PERIOD_CURRENT, InpMASecund, 0, MODE_SMA, hMom);

    ENUM_TIMEFRAMES atr_tf = (InpATR_TF == ATR_CURRENT) ? PERIOD_CURRENT : (ENUM_TIMEFRAMES)InpATR_TF;
    hATR = iATR(_Symbol, atr_tf, InpATRPeriod);

    PrintFormat("EA INICIADO | Ativo: %s | TF: %s | ATR TF: %s | RR: %d:1",
                _Symbol, EnumToString(_Period), EnumToString(atr_tf), (int)InpRR_Final);

    return (hMA_Pri == INVALID_HANDLE || hATR == INVALID_HANDLE) ? INIT_FAILED : INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    IndicatorRelease(hMA_Pri);
    IndicatorRelease(hOBV);
    IndicatorRelease(hOBV_MA);
    IndicatorRelease(hRSI);
    IndicatorRelease(hRSI_MA);
    IndicatorRelease(hMom);
    IndicatorRelease(hMom_MA);
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
        return true;                                  // sem dados: libera
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

    //--- TPs FIXOS: sempre 1:1, 2:1, 3:1 (independente do InpRR_Final) ---
    m_tp1 = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price + 1.0 * m_sl_dist : price - 1.0 * m_sl_dist);
    m_tp2 = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price + 2.0 * m_sl_dist : price - 2.0 * m_sl_dist);
    m_tp3 = HelperNormalizePrice((type == ORDER_TYPE_BUY) ? price + 3.0 * m_sl_dist : price - 3.0 * m_sl_dist);

    //--- Volume das parciais depende do InpRR_Final ---
    m_initial_lot = lot;
    if (InpRR_Final == RR_1_1)
    {
        m_p1_vol = lot; // Fecha tudo no TP1
        m_p2_vol = 0;
        m_p3_vol = 0;
    }
    else if (InpRR_Final == RR_2_1)
    {
        m_p1_vol = MathFloor((lot * (InpVolP1 / 100.0)) / m_sym.LotsStep()) * m_sym.LotsStep();
        m_p2_vol = lot - m_p1_vol; // Restante no TP2
        m_p3_vol = 0;
    }
    else
    {
        m_p1_vol = MathFloor((lot * (InpVolP1 / 100.0)) / m_sym.LotsStep()) * m_sym.LotsStep();
        m_p2_vol = MathFloor((lot * (InpVolP2 / 100.0)) / m_sym.LotsStep()) * m_sym.LotsStep();
        m_p3_vol = lot - m_p1_vol - m_p2_vol;
    }
    if (m_p1_vol >= lot)
    {
        m_p1_vol = lot;
        m_p2_vol = 0;
        m_p3_vol = 0;
    }
    if (m_p1_vol + m_p2_vol >= lot)
    {
        m_p2_vol = lot - m_p1_vol;
        m_p3_vol = 0;
    }

    // TP final da ordem conforme o RR escolhido
    double tp_final = m_tp3;
    if (InpRR_Final == RR_1_1)
        tp_final = m_tp1;
    else if (InpRR_Final == RR_2_1)
        tp_final = m_tp2;

    m_hit1 = false;
    m_hit2 = false;

    //--- Print completo (ATR, SL, TPs, estados dos indicadores) ---
    PrintFormat("============================================================");
    PrintFormat("ABRINDO %s | %s", (type == ORDER_TYPE_BUY) ? "COMPRA" : "VENDA", _Symbol);
    PrintFormat("Preco: %.2f | ATR[1]: %.2f | SL Dist: %.2f", price, atr[1], m_sl_dist);
    PrintFormat("SL: %.2f | TP1(1:1): %.2f | TP2(2:1): %.2f | TP3(3:1): %.2f", sl, m_tp1, m_tp2, m_tp3);
    PrintFormat("Vol: %.0f | P1: %.0f | P2: %.0f | P3: %.0f | RR: %d:1", lot, m_p1_vol, m_p2_vol, m_p3_vol, (int)InpRR_Final);
    PrintFormat("OBV armado: %s | RSI armado: %s | MOM armado: %s",
                (m_buyOBV.armed || m_sellOBV.armed) ? "SIM" : "NAO",
                (m_buyRSI.armed || m_sellRSI.armed) ? "SIM" : "NAO",
                (m_buyMOM.armed || m_sellMOM.armed) ? "SIM" : "NAO");
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
    if (m_pos.Magic() != 123456)
        return;

    bool isBuy = (m_pos.PositionType() == POSITION_TYPE_BUY);
    double price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double entry = m_pos.PriceOpen();
    double cur_sl = HelperNormalizePrice(m_pos.StopLoss());
    double cur_tp = HelperNormalizePrice(m_pos.TakeProfit());
    double profit_dist = isBuy ? (price - entry) : (entry - price);

    // Determinar TP final ativo
    double tp_final_ativo = m_tp3;
    if (InpRR_Final == RR_1_1)
        tp_final_ativo = m_tp1;
    else if (InpRR_Final == RR_2_1)
        tp_final_ativo = m_tp2;

    //--- Parcial 1 ---
    if (!m_hit1 && m_p1_vol > 0 && ((isBuy && price >= m_tp1) || (!isBuy && price <= m_tp1)))
    {
        double vol_to_close = MathMin(m_p1_vol, m_pos.Volume());
        PrintFormat("PARCIAL 1: Fechando %.0f de %.0f", vol_to_close, m_pos.Volume());
        bool ok = isBuy ? trade.Sell(vol_to_close, _Symbol) : trade.Buy(vol_to_close, _Symbol);
        if (ok)
        {
            m_hit1 = true;
            // Breakeven: SL vai para entrada + margem de segurança
            // TP da ordem é zerado: EA gerencia as próximas parciais manualmente
            double offset = m_sl_dist * (InpProfitMin / 100.0);
            double new_sl = HelperNormalizePrice(isBuy ? entry + offset : entry - offset);
            trade.PositionModify(m_pos.Ticket(), new_sl, 0); // TP=0 para o EA gerenciar
            PrintFormat("BREAKEVEN P1: SL -> %.2f (entrada %.2f + margem %.2f) | TP removido", new_sl, entry, offset);
            return;
        }
        else
        {
            Print("ERRO PARCIAL 1: ", trade.ResultRetcode(), " - ", trade.ResultComment());
        }
    }

    //--- Parcial 2 ---
    if (m_hit1 && !m_hit2 && m_p2_vol > 0 && ((isBuy && price >= m_tp2) || (!isBuy && price <= m_tp2)))
    {
        double vol_to_close = MathMin(m_p2_vol, m_pos.Volume());
        PrintFormat("PARCIAL 2: Fechando %.0f de %.0f", vol_to_close, m_pos.Volume());
        bool ok = isBuy ? trade.Sell(vol_to_close, _Symbol) : trade.Buy(vol_to_close, _Symbol);
        if (ok)
        {
            m_hit2 = true;
            // Breakeven P2: SL vai para TP1 + margem, TP zerado para EA gerenciar P3
            double offset = m_sl_dist * (InpProfitMin / 100.0);
            double new_sl = HelperNormalizePrice(isBuy ? m_tp1 + offset : m_tp1 - offset);
            trade.PositionModify(m_pos.Ticket(), new_sl, 0); // TP=0, EA gerencia saída final
            PrintFormat("BREAKEVEN P2: SL -> %.2f (TP1 %.2f + margem %.2f) | TP removido", new_sl, m_tp1, offset);
            return;
        }
        else
        {
            Print("ERRO PARCIAL 2: ", trade.ResultRetcode(), " - ", trade.ResultComment());
        }
    }

    //--- Trailing Stop ---
    // Distância de trailing = m_sl_dist + margem breakeven (acompanha o preço mantendo essa folga)
    if (InpUseTrailing && m_sl_dist > 0)
    {
        double activation_dist = m_sl_dist * (InpTrailActiv / 100.0);

        if (profit_dist >= activation_dist)
        {
            double offset = m_sl_dist * (InpProfitMin / 100.0);
            double trail_dist = m_sl_dist + offset; // Distância fixa: SL_inicial + margem breakeven

            double new_trail_sl = HelperNormalizePrice(isBuy ? price - trail_dist : price + trail_dist);

            // Nunca recuar o SL (só avança na direção favorável)
            bool shouldModify = isBuy ? (new_trail_sl > cur_sl) : (new_trail_sl < cur_sl);

            if (shouldModify && MathAbs(new_trail_sl - cur_sl) > 1e-8)
            {
                // TP permanece 0 após parciais (EA gerencia), ou usa o TP da ordem se ainda não teve parcial
                double latest_tp = m_hit1 ? 0 : (cur_tp > 0 ? cur_tp : HelperNormalizePrice(tp_final_ativo));
                if (!trade.PositionModify(m_pos.Ticket(), new_trail_sl, latest_tp))
                {
                    if (trade.ResultRetcode() != 10016)
                        Print("ERRO TRAILING: ", trade.ResultRetcode(), " - ", trade.ResultComment());
                }
            }
        }
    }

    //--- Saída manual na Parcial 3 (TP final pelo EA, sem TP automático no broker) ---
    if (m_hit2 && ((isBuy && price >= m_tp3) || (!isBuy && price <= m_tp3)))
    {
        PrintFormat("PARCIAL 3 (SAÍDA FINAL): Fechando %.0f (posição total)", m_pos.Volume());
        trade.PositionClose(m_pos.Ticket());
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
        if (HistoryDealGetInteger(t, DEAL_MAGIC) == 123456 && HistoryDealGetInteger(t, DEAL_ENTRY) == DEAL_ENTRY_IN && HistoryDealGetString(t, DEAL_SYMBOL) == _Symbol)
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
            if (m_pos.SelectByIndex(i) && m_pos.Magic() == 123456)
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
