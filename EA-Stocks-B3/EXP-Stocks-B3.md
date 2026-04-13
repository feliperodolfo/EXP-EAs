# EXP-Stocks-B3

## Descrição
O **EXP-Stocks-B3** é um Expert Advisor (EA) desenvolvido para a plataforma MetaTrader 5 (MT5) pela EXP Automação STI LTDA. Ele foi projetado para operar um único ativo por vez, com foco em estratégias baseadas em indicadores técnicos e gerenciamento de risco avançado. Este EA é altamente configurável e permite personalizar diversos parâmetros para atender às necessidades específicas de cada trader.

## Funcionalidades

### 1. Operações em Ativo Único
- Opera apenas um ativo por vez, facilitando a análise gráfica das entradas e saídas.
- Suporte para compra e venda, com habilitação opcional para operações de venda.

### 2. Indicadores Técnicos
- **Média Móvel Principal**:
  - Utilizada para identificar a tendência principal do mercado.
- **OBV (On-Balance Volume)**:
  - Utilizado para identificar cruzamentos e confirmar sinais de compra e venda.
- **RSI (Índice de Força Relativa)**:
  - Utilizado para identificar cruzamentos e confirmar sinais de compra e venda.
- **Momentum**:
  - Utilizado para identificar cruzamentos e confirmar sinais de compra e venda.
- **ATR (Average True Range)**:
  - Utilizado para calcular o stop loss baseado na volatilidade.

### 3. Gerenciamento de Risco
- **Stop Loss Dinâmico**:
  - Baseado no ATR, com multiplicador configurável.
- **Saída Total na Parcial 1**:
  - O EA realiza 100% da saída na primeira parcial, simplificando o gerenciamento de posições.
- **Controle de Capital**:
  - Percentual do capital alocado por operação.
  - Limite de drawdown diário configurável.
- **Limite de Operações**:
  - Número máximo de operações por ativo/dia.

### 4. Horários e Dias de Operação
- Configuração de horários e dias específicos para operar.
- Opção para encerrar todas as posições ao final do horário configurado.

### 5. Breakeven
- **Breakeven**:
  - Move o stop loss para o ponto de equilíbrio após atingir o gatilho configurado.

### 6. Persistência de Dados
- Armazena informações de posições abertas em variáveis globais para recuperação em caso de reinicialização do EA.

## Configurações
O EA possui diversas opções de configuração para personalização:

### Indicadores Técnicos
- Períodos, métodos e tipos de cálculo para os indicadores utilizados.
- Habilitação individual para cada indicador (OBV, RSI, Momentum).

### Gerenciamento de Risco
- Percentual do capital alocado por operação.
- Multiplicador do ATR para cálculo do stop loss.
- Limite de drawdown diário.

### Horários e Dias
- Dias da semana habilitados para operação.
- Horários de início e fim das operações.
- Opção para encerrar posições ao final do horário configurado.

### Breakeven
- Percentual de ativação do breakeven.
- Offset opcional sobre o preço de entrada.

## Lógica de Funcionamento

1. **Inicialização**:
   - Os indicadores técnicos são configurados e os handles necessários são criados.
   - Verifica se o EA está desativado devido a drawdown anterior.

2. **Execução no Tick**:
   - A cada novo tick, verifica se há um novo candle.
   - Avalia se está dentro do horário e dias configurados para operação.
   - Atualiza os sinais dos indicadores técnicos.
  - Gerencia posições abertas, incluindo breakeven.

3. **Entrada de Operações**:
   - Verifica se há sinais armados para compra ou venda.
   - Confirma os sinais com base nos indicadores técnicos e na tendência principal.
   - Realiza a entrada com base nas condições configuradas.

4. **Gerenciamento de Posições**:
   - Ajusta o stop loss conforme o preço se move.
   - Fecha posições ao atingir o nível de take profit ou stop loss.

## Requisitos
- Plataforma MetaTrader 5.
- Conexão ativa com a internet para execução de ordens.

## Créditos
- Desenvolvido por **EXP Automação STI LTDA**.
- Website: [https://www.expautomacao.com.br](https://www.expautomacao.com.br)

---

Este documento descreve as funcionalidades e o funcionamento do EA **EXP-Stocks-B3**. Para dúvidas ou suporte, entre em contato com o desenvolvedor.