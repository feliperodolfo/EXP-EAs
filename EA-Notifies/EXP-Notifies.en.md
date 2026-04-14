# EXP-Notifies

## Description
The **EXP-Notifies** is an Expert Advisor (EA) developed for the MetaTrader 5 (MT5) platform by EXP Automação STI LTDA. Its purpose is to issue notifications based on technical events and market patterns, helping traders make decisions. This EA is highly configurable and allows monitoring of various technical indicators and reversal patterns.

## Features

### 1. Moving Average (MA) Based Notifications
- The EA monitors three configurable moving averages (fast, medium and slow).
- Sends notifications when price touches any of these moving averages at candle close.

### 2. V-Shape Reversal Pattern Notifications
- Detects V-shaped reversal patterns for the following indicators:
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Relative Strength Index)
  - Stochastic
- Reversal patterns are tolerant to small imperfections in the low or high.

### 3. Overbought and Oversold Notifications
- **RSI**:
  - Notifies when RSI exits overbought or oversold regions.
- **Stochastic**:
  - Notifies when the Stochastic exits overbought or oversold regions.

### 4. Volume Aggression Notifications
- **Volume**:
  - Monitors volume aggression on a dedicated timeframe and notifies when volume exceeds the configured average.

## Settings
The EA provides various configuration options for customization:

### General Parameters
- **Moving Averages**:
  - Periods, methods and applied price for the fast, medium and slow MAs.
  - Enable notifications for touches on the moving averages.
- **Momentum**:
  - Period and calculation method.
  - Enable notifications for V-Shape patterns.
- **OBV**:
  - Calculation method and enable notifications for V-Shape patterns.
- **RSI**:
  - Period, overbought/oversold limits and calculation method.
  - Enable notifications for crossovers and V-Shape patterns.
- **Stochastic**:
  - %K, %D and Slow parameters, plus overbought/oversold limits.
  - Enable notifications for crossovers and V-Shape patterns.
- **Volume**:
  - Dedicated timeframe, period and calculation method.
  - Enable notifications for volume aggression.

## Operation Logic

1. **Initialization**:
   - Technical indicators are configured and necessary handles are created.
   - Buffers are initialized to store indicator data.

2. **On Tick Execution**:
   - On each new tick, the EA checks for a new main or volume candle.
   - For each new candle:
     - Checks touches on moving averages.
     - Evaluates crossovers and reversal patterns on technical indicators.
     - Sends notifications according to configured conditions.

3. **Notifications**:
   - Notification messages include the symbol, timeframe and event timestamp.
   - They are sent directly to the MetaTrader terminal or connected mobile devices.

## Requirements
- MetaTrader 5 platform.
- Active internet connection for sending notifications.

## Credits
- Developed by **EXP Automação STI LTDA**.
- Website: [https://www.expautomacao.com.br](https://www.expautomacao.com.br)

---

This document describes the features and operation of the **EXP-Notifies** EA. For questions or support, contact the developer.
