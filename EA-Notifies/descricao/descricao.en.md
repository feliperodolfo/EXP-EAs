# EXP-Notifies

**Your Technical Analysis Assistant That Works for You – No Trades Opened, No Risks, Just Smart Alerts**

**Receive accurate market pattern notifications and make conscious trading decisions – directly on your mobile, without being glued to your computer screen.**

---

## Main Description

**EXP-Notifies** is not an ordinary trading robot. It was developed for **traders who want full control over their entries and exits** but don't have the time to watch charts all day long.

While automated trading robots execute orders for you (often without context), EXP-Notifies **only alerts** you when relevant technical conditions occur. The final decision – and risk management – remains 100% yours.

---

## Why Choose a Notification Robot Instead of a Trading Robot?

### ✅ **1. No surprises – you decide whether to enter or not**
The robot does not open, close, or modify any positions. This eliminates the risk of unwanted executions caused by abnormal volatility or flaws in automated logic.

### ✅ **2. Monitor multiple assets simultaneously**
While a human trader follows 1 or 2 pairs, EXP-Notifies can monitor dozens of assets, timeframes, and indicators at the same time – and only calls you when something truly relevant happens.

### ✅ **3. Receive alerts on your mobile and act from anywhere**
Notifications go straight to your MetaTrader 5 mobile app. Whether you're at work, at the gym, or at home – when you receive an alert, you quickly assess the current market context and decide whether to open a position.

### ✅ **4. Better risk management**
Because you analyze each signal before acting, you can filter out trades that don't fit your current market conditions, favorable trading hours, risk appetite, or capital availability. No trading robot offers this level of flexibility.

### ✅ **5. Ideal for discretionary traders**
If you trust your own judgment but want to save hours of chart analysis, EXP-Notifies acts as a tireless assistant – detecting moving average touches, V-Shape patterns (on RSI, OBV, Momentum, and Stochastic), overbought/oversold reversals, and volume spikes.

---

## Technical Differentiators of EXP-Notifies

- **Fully configurable**: periods, methods, limits, and timeframes customizable for each indicator.
- **Imperfection-tolerant**: V-Shape pattern detection is designed to work even with small variations at bottoms or tops.
- **Candle close focus**: avoids false intra-bar signals.
- **Dedicated timeframe for volume**: separate analysis of volume spikes without interfering with the main chart structure.

---

## Target Audience

This EA is perfect for:
- Discretionary traders who do not use automated trading robots.
- Managers who want technical alerts for multiple assets without automating executions.
- Beginners who want to learn market patterns through objective alerts.
- Professionals who trade via mobile and need reliable signals.

---

## Features

### 1. Moving Average (MA) Touch Notifications
- Monitors three configurable moving averages (fast, medium, slow).
- Sends notifications when the price touches any of these moving averages at candle close.

### 2. V-Shape Reversal Pattern Notifications
- Detects "V" shaped reversal patterns for the following indicators:
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Relative Strength Index)
  - Stochastic
- Reversal patterns are tolerant to small imperfections at bottoms or tops.

### 3. Overbought/Oversold Notifications
- **RSI**:
  - Notifies when RSI exits overbought or oversold regions.
- **Stochastic**:
  - Notifies when Stochastic exits overbought or oversold regions.

### 4. Volume Spike Notifications
- **Volume**:
  - Monitors volume spikes on a dedicated timeframe and notifies when volume exceeds the configured average.

---

### General Parameters
- **Moving Averages**:
  - Periods, methods, and applied prices for fast, medium, and slow averages.
  - Enable/disable notifications for MA touches.
- **Momentum**:
  - Period and calculation method.
  - Enable/disable notifications for V-Shape patterns.
- **OBV**:
  - Calculation method and enable/disable notifications for V-Shape patterns.
- **RSI**:
  - Period, overbought/oversold limits, and calculation method.
  - Enable/disable notifications for crossovers and V-Shape patterns.
- **Stochastic**:
  - %K, %D, and Slow parameters, plus overbought/oversold limits.
  - Enable/disable notifications for crossovers and V-Shape patterns.
- **Volume**:
  - Dedicated timeframe, period, and calculation method.
  - Enable/disable notifications for volume spikes.

## Operating Logic

1. **Initialization**:
   - Technical indicators are configured and necessary handles are created.
   - Buffers are initialized to store indicator data.

2. **OnTick Execution**:
   - On each new tick, the EA checks for a new main candle or volume candle.
   - For each new candle:
     - Checks moving average touches.
     - Evaluates crossovers and reversal patterns on technical indicators.
     - Sends notifications according to configured conditions.

3. **Notifications**:
   - Notification messages include the symbol, timeframe, and event time.
   - They are sent directly to the MetaTrader terminal or connected mobile devices.

---

## Conclusion

With **EXP-Notifies**, you no longer miss opportunities due to lack of time, but you also don't hand over control of your account to a robot. **It handles the heavy analysis. You make the smart decision.**