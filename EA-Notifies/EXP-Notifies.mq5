//+------------------------------------------------------------------+
//|                                                 EXP-Notifies.mq5 |
//|                           Copyright 2023, EXP Automação STI LTDA |
//|                                  https://www.expautomacao.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, EXP Automação STI LTDA."
#property link "https://www.expautomacao.com.br"
#property version "1.04"
#property description "Este Expert Advisor foi desenvolvido para emitir notificações quando:"
#property description "- Preço toca alguma das 3 médias móveis configuradas ou quando há agressão de volume;"
#property description "- Momentum forma um padrão de reversão (V-Shape);"
#property description "- OBV forma um padrão de reversão (V-Shape);"
#property description "- RSI sai dos limites sobrecomprado ou sobrevendido ou forma um padrão V-Shape;"
#property description "- Stochastic sai dos limites sobrecomprado ou sobrevendido ou forma um padrão V-Shape;"
#property strict

enum NOTIFY
{
   YES,
   NO
};

sinput string s0; //----------MA Parameters-------------
input int ma_fast_period = 20;
input ENUM_MA_METHOD ma_fast_method = MODE_EMA;
input ENUM_APPLIED_PRICE ma_fast_price = PRICE_CLOSE;
input int ma_med_period = 72;
input ENUM_MA_METHOD ma_med_method = MODE_EMA;
input ENUM_APPLIED_PRICE ma_med_price = PRICE_CLOSE;
input int ma_slow_period = 200;
input ENUM_MA_METHOD ma_slow_method = MODE_EMA;
input ENUM_APPLIED_PRICE ma_slow_price = PRICE_CLOSE;
input NOTIFY ena_ma_notify = YES; // enable MA touch notifications

sinput string s1; //----------Momentum Parameters-------------
input int mom_period = 9;
input ENUM_APPLIED_PRICE mom_applied = PRICE_CLOSE;
input int mom_ma_period = 9;
input ENUM_MA_METHOD mom_ma_method = MODE_SMA;
input NOTIFY ena_mom_vshape = YES; // enable Momentum V-Shape notifications

sinput string s2; //----------OBV Parameters-------------
input ENUM_APPLIED_VOLUME obv_applied = VOLUME_TICK;
input int obv_ma_period = 9;
input ENUM_MA_METHOD obv_ma_method = MODE_SMA;
input NOTIFY ena_obv_vshape = YES; // enable OBV V-Shape notifications

sinput string s3; //----------RSI Parameters-------------
input int rsi_period = 14;
input ENUM_APPLIED_PRICE rsi_applied = PRICE_CLOSE;
input int rsi_overbought = 70;
input int rsi_oversold = 30;
input int rsi_ma_period = 9;
input ENUM_MA_METHOD rsi_ma_method = MODE_SMA;
input NOTIFY ena_rsi_vshape = YES; // enable RSI V-Shape notifications
input NOTIFY ena_rsi_notify = YES; // enable RSI notifications for crossing overbought/oversold

sinput string s4; //-----------Stochastic Parameters-------------
input int stoch_K = 20;
input int stoch_D = 4;
input int stoch_Slow = 4;
input ENUM_MA_METHOD stoch_method = MODE_SMA;
input ENUM_STO_PRICE stoch_price = STO_CLOSECLOSE;
input int stoch_overbought = 80;
input int stoch_oversold = 20;
input int stoch_ma_period = 9;
input ENUM_MA_METHOD stoch_ma_method = MODE_SMA;
input NOTIFY ena_stoch_vshape = YES; // enable Stochastic V-Shape notifications
input NOTIFY ena_stoch_notify = YES; // enable Stochastic notifications for crossing overbought/oversold

sinput string s5; //----------Volume Parameters-------------
input ENUM_TIMEFRAMES volume_time_frame = PERIOD_H2;
input int volume_ma_period = 9;
input ENUM_MA_METHOD volume_ma_method = MODE_EMA;
input NOTIFY ena_volume_notify = YES; // enable Volume notifications for aggression on specific timeframe

//--- Handles e Buffers
int stoch_Handle, stoch_ma_Handle;
double stoch_Buffer[], stoch_ma_Buffer[];

int rsi_Handle, rsi_ma_Handle;
double rsi_Buffer[], rsi_ma_Buffer[];

int ma_fast_handle;
double ma_fast_buffer[];
int ma_med_handle;
double ma_med_buffer[];
int ma_slow_handle;
double ma_slow_buffer[];

int volume_handle, volume_ma_handle;
double volumeBuffer[], volumeMABuffer[];

int mom_handle, mom_ma_handle;
double mom_Buffer[], mom_ma_Buffer[];

int obv_handle, obv_ma_handle;
double obv_Buffer[], obv_ma_Buffer[];

//--- Variáveis globais removidas pois a lógica das MAs foi migrada para o fechamento de candle
datetime lastBarTimeMain = 0;
datetime lastBarTimeVol = 0;

//+------------------------------------------------------------------+
bool IsNewBarMain()
{
   datetime tempoAtual = iTime(Symbol(), PERIOD_CURRENT, 0);
   if (tempoAtual == 0)
      return false;
   if (lastBarTimeMain == 0)
   {
      lastBarTimeMain = tempoAtual;
      return false; // Previne disparo na hora que anexa o EA no gráfico
   }
   if (tempoAtual != lastBarTimeMain)
   {
      lastBarTimeMain = tempoAtual;
      return true;
   }
   return false;
}

bool IsNewBarVol()
{
   datetime tempoAtual = iTime(Symbol(), volume_time_frame, 0);
   if (tempoAtual == 0)
      return false;
   if (lastBarTimeVol == 0)
   {
      lastBarTimeVol = tempoAtual;
      return false; // Previne disparo no primeiro tick da inicialização
   }
   if (tempoAtual != lastBarTimeVol)
   {
      lastBarTimeVol = tempoAtual;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
// Padrão de reversão (V-Shape) tolerante a imperfeições no fundo/topo (com gap)
bool IsRevertingUp(double &m[])
{
   if (ArraySize(m) < 12)
      return false;
   ArraySetAsSeries(m, true);                                                             // Garantir ordenação correta
   bool recent_up = (m[1] > m[2]) && (m[2] > m[3]) && (m[3] > m[4]);                      // Subindo 1, 2, 3, 4
   bool prior_down = (m[7] < m[8]) && (m[8] < m[9]) && (m[9] < m[10]) && (m[10] < m[11]); // Caindo 7...11, gap 5 e 6
   bool is_bottom = (m[4] < m[7]);                                                        // Fundo confirmado
   return (recent_up && prior_down && is_bottom);
}

bool IsRevertingDown(double &m[])
{
   if (ArraySize(m) < 12)
      return false;
   ArraySetAsSeries(m, true);                                                           // Garantir ordenação correta
   bool recent_down = (m[1] < m[2]) && (m[2] < m[3]) && (m[3] < m[4]);                  // Caindo 1, 2, 3, 4
   bool prior_up = (m[7] > m[8]) && (m[8] > m[9]) && (m[9] > m[10]) && (m[10] > m[11]); // Subindo 7...11, gap 5 e 6
   bool is_top = (m[4] > m[7]);                                                         // Topo confirmado
   return (recent_down && prior_up && is_top);
}

//+------------------------------------------------------------------+
int OnInit()
{
   // Stochastic
   stoch_Handle = iStochastic(Symbol(), PERIOD_CURRENT, stoch_K, stoch_D, stoch_Slow, stoch_method, stoch_price);
   stoch_ma_Handle = iMA(Symbol(), PERIOD_CURRENT, stoch_ma_period, 0, stoch_ma_method, stoch_Handle);

   // RSI
   rsi_Handle = iRSI(Symbol(), PERIOD_CURRENT, rsi_period, rsi_applied);
   rsi_ma_Handle = iMA(Symbol(), PERIOD_CURRENT, rsi_ma_period, 0, rsi_ma_method, rsi_Handle);

   // MAs
   ma_fast_handle = iMA(Symbol(), PERIOD_CURRENT, ma_fast_period, 0, ma_fast_method, ma_fast_price);
   ma_med_handle = iMA(Symbol(), PERIOD_CURRENT, ma_med_period, 0, ma_med_method, ma_med_price);
   ma_slow_handle = iMA(Symbol(), PERIOD_CURRENT, ma_slow_period, 0, ma_slow_method, ma_slow_price);

   // Volume (timeframe específico) - O iMA de VolumeTick usa a constante VOLUME_TICK como Preço Aplicado
   volume_handle = iVolumes(Symbol(), volume_time_frame, VOLUME_TICK);
   volume_ma_handle = iMA(Symbol(), volume_time_frame, volume_ma_period, 0, volume_ma_method, VOLUME_TICK);

   // Momentum
   mom_handle = iMomentum(Symbol(), PERIOD_CURRENT, mom_period, mom_applied);
   mom_ma_handle = iMA(Symbol(), PERIOD_CURRENT, mom_ma_period, 0, mom_ma_method, mom_handle);

   // OBV
   obv_handle = iOBV(Symbol(), PERIOD_CURRENT, obv_applied);
   obv_ma_handle = iMA(Symbol(), PERIOD_CURRENT, obv_ma_period, 0, obv_ma_method, obv_handle);

   if (stoch_Handle < 0 || rsi_Handle < 0 || ma_fast_handle < 0 || volume_handle < 0 || mom_handle < 0 || obv_handle < 0)
   {
      Print("Erro ao criar Handles!");
      return INIT_FAILED;
   }

   ArraySetAsSeries(stoch_Buffer, true);
   ArraySetAsSeries(stoch_ma_Buffer, true);
   ArraySetAsSeries(rsi_Buffer, true);
   ArraySetAsSeries(rsi_ma_Buffer, true);
   ArraySetAsSeries(ma_fast_buffer, true);
   ArraySetAsSeries(ma_med_buffer, true);
   ArraySetAsSeries(ma_slow_buffer, true);
   ArraySetAsSeries(volumeBuffer, true);
   ArraySetAsSeries(volumeMABuffer, true);
   ArraySetAsSeries(mom_Buffer, true);
   ArraySetAsSeries(mom_ma_Buffer, true);
   ArraySetAsSeries(obv_Buffer, true);
   ArraySetAsSeries(obv_ma_Buffer, true);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(stoch_Handle);
   IndicatorRelease(stoch_ma_Handle);
   IndicatorRelease(rsi_Handle);
   IndicatorRelease(rsi_ma_Handle);
   IndicatorRelease(ma_fast_handle);
   IndicatorRelease(ma_med_handle);
   IndicatorRelease(ma_slow_handle);
   IndicatorRelease(volume_handle);
   IndicatorRelease(volume_ma_handle);
   IndicatorRelease(mom_handle);
   IndicatorRelease(mom_ma_handle);
   IndicatorRelease(obv_handle);
   IndicatorRelease(obv_ma_handle);
}

//+------------------------------------------------------------------+
void OnTick()
{
   bool isNewBarMain = IsNewBarMain();
   bool isNewBarVol = IsNewBarVol();
   string msgFinal = Symbol() + ", " + EnumToString(Period()) + " em: " + TimeToString(TimeLocal()) + ". by EXP-Notifies";

   // ----------------------------------------------------
   // VOLUME CHECK (Timeframe Dedicado)
   // ----------------------------------------------------
   if (isNewBarVol)
   {
      if (ena_volume_notify == YES)
      {
         if (CopyBuffer(volume_handle, 0, 0, 3, volumeBuffer) > 0 &&
             CopyBuffer(volume_ma_handle, 0, 0, 3, volumeMABuffer) > 0)
         {
            // Avalia o candle 1 (candle fechado mais recente)
            if (volumeBuffer[1] > volumeMABuffer[1])
            {
               SendNotification("Agressão de Volume (" + EnumToString(volume_time_frame) + ") em " + msgFinal);
               Alert("Agressão de Volume (" + EnumToString(volume_time_frame) + ") em " + msgFinal);
            }
         }
      }
   }

   // ----------------------------------------------------
   // NOVO CANDLE PRINCIPAL (Resets e Reversões)
   // Todos os valores consultados são [1] (Candle Fechado)
   // ----------------------------------------------------
   if (isNewBarMain)
   {

      // MAs Touch (Validado no fechamento do candle)
      // Se a MA estiver entre a mínima e a máxima do candle fechado, houve "toque".
      if (ena_ma_notify == YES)
      {
         double high_1 = iHigh(Symbol(), PERIOD_CURRENT, 1);
         double low_1 = iLow(Symbol(), PERIOD_CURRENT, 1);

         if (CopyBuffer(ma_fast_handle, 0, 0, 2, ma_fast_buffer) > 0)
         {
            if (ma_fast_buffer[1] >= low_1 && ma_fast_buffer[1] <= high_1)
            {
               SendNotification("Preço tocou na MA " + IntegerToString(ma_fast_period) + " em " + msgFinal);
               Alert("Preço tocou na MA " + IntegerToString(ma_fast_period) + " em " + msgFinal);
            }
         }
         if (CopyBuffer(ma_med_handle, 0, 0, 2, ma_med_buffer) > 0)
         {
            if (ma_med_buffer[1] >= low_1 && ma_med_buffer[1] <= high_1)
            {
               SendNotification("Preço tocou na MA " + IntegerToString(ma_med_period) + " em " + msgFinal);
               Alert("Preço tocou na MA " + IntegerToString(ma_med_period) + " em " + msgFinal);
            }
         }
         if (CopyBuffer(ma_slow_handle, 0, 0, 2, ma_slow_buffer) > 0)
         {
            if (ma_slow_buffer[1] >= low_1 && ma_slow_buffer[1] <= high_1)
            {
               SendNotification("Preço tocou na MA " + IntegerToString(ma_slow_period) + " em " + msgFinal);
               Alert("Preço tocou na MA " + IntegerToString(ma_slow_period) + " em " + msgFinal);
            }
         }
      }

      // STOCHASTIC
      if (CopyBuffer(stoch_Handle, 0, 0, 4, stoch_Buffer) > 0 &&
          CopyBuffer(stoch_ma_Handle, 0, 0, 15, stoch_ma_Buffer) > 0)
      {
         // Cruzamento clássico
         if (ena_stoch_notify == YES)
         {
            if (stoch_Buffer[1] < stoch_overbought && stoch_Buffer[2] > stoch_overbought)
            {
               SendNotification("Estocástico saiu da região de sobre-compra em " + msgFinal);
               Alert("Estocástico saiu da região de sobre-compra em " + msgFinal);
            }
            if (stoch_Buffer[1] > stoch_oversold && stoch_Buffer[2] < stoch_oversold)
            {
               SendNotification("Estocástico saiu da região de sobre-venda em " + msgFinal);
               Alert("Estocástico saiu da região de sobre-venda em " + msgFinal);
            }
         }
         // V-Shape Stoch
         if (ena_stoch_vshape == YES)
         {
            if (IsRevertingUp(stoch_ma_Buffer))
            {
               SendNotification("Estocástico V-Shape - Reversão de ALTA em " + msgFinal);
               Alert("Estocástico V-Shape - Reversão de ALTA em " + msgFinal);
            }
            if (IsRevertingDown(stoch_ma_Buffer))
            {
               SendNotification("Estocástico V-Shape - Reversão BAIXA em " + msgFinal);
               Alert("Estocástico V-Shape - Reversão BAIXA em " + msgFinal);
            }
         }
      }

      // RSI
      if (CopyBuffer(rsi_Handle, 0, 0, 4, rsi_Buffer) > 0 &&
          CopyBuffer(rsi_ma_Handle, 0, 0, 15, rsi_ma_Buffer) > 0)
      {
         // Cruzamento Clássico
         if (ena_rsi_notify == YES)
         {
            if (rsi_Buffer[1] < rsi_overbought && rsi_Buffer[2] > rsi_overbought)
            {
               SendNotification("RSI saiu da região de sobre-compra em " + msgFinal);
               Alert("RSI saiu da região de sobre-compra em " + msgFinal);
            }
            if (rsi_Buffer[1] > rsi_oversold && rsi_Buffer[2] < rsi_oversold)
            {
               SendNotification("RSI saiu da região de sobre-venda em " + msgFinal);
               Alert("RSI saiu da região de sobre-venda em " + msgFinal);
            }
         }
         // V-Shape RSI
         if (ena_rsi_vshape == YES)
         {
            if (IsRevertingUp(rsi_ma_Buffer))
            {
               SendNotification("RSI V-Shape - Reversão de ALTA em " + msgFinal);
               Alert("RSI V-Shape - Reversão de ALTA em " + msgFinal);
            }
            if (IsRevertingDown(rsi_ma_Buffer))
            {
               SendNotification("RSI V-Shape - Reversão de BAIXA em " + msgFinal);
               Alert("RSI V-Shape - Reversão de BAIXA em " + msgFinal);
            }
         }
      }

      // MOMENTUM (V-Shape apenas)
      if (ena_mom_vshape == YES)
      {
         if (CopyBuffer(mom_ma_handle, 0, 0, 15, mom_ma_Buffer) > 0)
         {
            if (IsRevertingUp(mom_ma_Buffer))
            {
               SendNotification("Momentum V-Shape - Reversão de ALTA em " + msgFinal);
               Alert("Momentum V-Shape - Reversão de ALTA em " + msgFinal);
            }
            if (IsRevertingDown(mom_ma_Buffer))
            {
               SendNotification("Momentum V-Shape - Reversão BAIXA em " + msgFinal);
               Alert("Momentum V-Shape - Reversão BAIXA em " + msgFinal);
            }
         }
      }

      // OBV (V-Shape apenas)
      if (ena_obv_vshape == YES)
      {
         if (CopyBuffer(obv_ma_handle, 0, 0, 15, obv_ma_Buffer) > 0)
         {
            if (IsRevertingUp(obv_ma_Buffer))
            {
               SendNotification("OBV V-Shape - Reversão de ALTA em " + msgFinal);
               Alert("OBV V-Shape - Reversão de ALTA em " + msgFinal);
            }
            if (IsRevertingDown(obv_ma_Buffer))
            {
               SendNotification("OBV V-Shape - Reversão de BAIXA em " + msgFinal);
               Alert("OBV V-Shape - Reversão de BAIXA em " + msgFinal);
            }
         }
      }
   }
}
