
# EXP-MultiAsset

Versão: 1.40

Expert Advisor Multi-Ativo para Bovespa implementado em MQL5. Este documento descreve o funcionamento, parâmetros e comportamento do `EXP-MultiAsset.mq5` baseado no código-fonte.

**Resumo**
- **Objetivo:** operar por sinal de tendência com confirmações por indicadores (OBV, RSI, Momentum), gerenciamento de risco por ATR e execução de parciais (TPs fixos 1:1, 2:1, 3:1).
- **Principais mecanismos:** médias móveis para detecção de tendência, indicadores com sinal "armado" por cruzamento com sua média de confirmação, filtro de reversão de slope, ATR para cálculo de stop, parciais configuráveis e trailing/breakeven.

**Como funciona (visão geral)**
- Detecta tendência usando uma média móvel principal (`InpMAPrincipal`).
- Cada indicador (OBV, RSI, Momentum) possui uma média de confirmação; quando o indicador cruza sua média, o sinal é "armado".
- O sinal armado só aciona se, no candle fechado anterior, o valor do indicador estiver acima/abaixo da média (conforme compra/venda) e, opcionalmente, a média do indicador apresentar reversão de slope (regra com 6 candles).
- Entrada: preço (ask para compra / bid para venda) em relação à média principal + sinais armados dos indicadores habilitados.
- Stop inicial: baseado em ATR do timeframe selecionado multiplicado por `InpMultiplicadorStop` (limitado por `InpMaxSLPrice` como % do preço).
- Take profits fixos: calculados como distância de 1×, 2× e 3× do SL inicial (TP1, TP2, TP3). O EA fecha parciais conforme configurações de `InpRR_Final`, `InpVolP1`, `InpVolP2`.
- Gerenciamento de parciais: ao atingir TP1/TP2 o EA fecha parcial (com volumes definidos) e move o SL para breakeven+margin; na terceira parcial fecha a posição inteira.
- Trailing: opcional, ativado após lucro mínimo relativo ao SL inicial (`InpTrailActiv`) e preservando uma distância fixa (`m_sl_dist` + margem).
- Proteção contra drawdown: se o drawdown da conta exceder `InpMaxDrawdown` (%) o EA fecha posições do seu magic number e desativa-se persistente via GlobalVariable.

Persistência
- O EA salva dados relevantes da posição (distância de SL, TPs, volumes parciais, lote inicial) em variáveis globais por ticket com prefixo `EA_MA_<ticket>_...` para manter estado entre reinícios.

Parâmetros principais (inputs)
- **GRUPO 1: CONFIGURAÇÕES DA TENDÊNCIA**
	- `InpMAPrincipal` (int): período da média de tendência. Padrão: 9.
	- `InpMATipo` (ENUM_MA_METHOD): tipo da média (ex.: `MODE_EMA`).

- **GRUPO 2: CONFIGURAÇÕES DOS INDICADORES**
	- `InpOBVPeriod` (int): período da SMA do OBV. Padrão: 9.
	- `InpRSIPeriod` (int): período do RSI. Padrão: 9.
	- `InpMomPeriod` (int): período do Momentum. Padrão: 9.
	- `InpMASecund` (int): período das médias de confirmação dos indicadores. Padrão: 9.
	- `InpOBVVolType` (ENUM_APPLIED_VOLUME): tipo de volume para OBV (por exemplo `VOLUME_TICK`).

- **GRUPO 3: HABILITAÇÃO E RETENÇÃO**
	- `InpUsarOBV` (bool): usar OBV no filtro. Padrão: false.
	- `InpUsarRSI` (bool): usar RSI. Padrão: false.
	- `InpUsarMomentum` (bool): usar Momentum. Padrão: true.
	- `InpMaxRetention` (int): max de candles que um sinal fica armado. Padrão: 5.
	- `InpUsarFiltroReversao` (bool): exigir reversão da slope da MA do indicador (6 candles). Padrão: true.

- **GRUPO 4: GERENCIAMENTO DE RISCO**
	- `InpCapPercent` (double): % do capital por operação. Padrão: 10.0.
	- `InpATR_TF` (ENUM_ATR_TF): timeframe usado para cálculo do ATR (p.ex. `ATR_H4`).
	- `InpATRPeriod` (int): período do ATR. Padrão: 20.
	- `InpMultiplicadorStop` (double): multiplicador do ATR para o SL. Padrão: 3.0.
	- `InpRR_Final` (ENUM_RR_SET): até qual parcial operar (1:1, 2:1, 3:1).
	- `InpVolP1`, `InpVolP2` (double): % da posição alocada para P1/P2 quando aplicável.
	- `InpMaxTradesDay` (int): máximo de operações por ativo por dia. Padrão: 1.
	- `InpMaxDrawdown` (double): % de drawdown da conta que desativa o EA. Padrão: 5.0.
	- `InpEAComment` (string): comentário para ordens. Padrão: "EXP-MultiAsset".

- **GRUPO 5: TRAILING STOP E BREAKEVEN**
	- `InpUseTrailing` (bool): habilitar trailing. Padrão: true.
	- `InpTrailActiv` (double): ativação do trailing em % da distância do SL inicial. Padrão: 50.0.
	- `InpProfitMin` (double): margem usada para mover SL ao breakeven (em % do SL). Padrão: 30.0.
	- `InpMaxSLPrice` (double): limite máximo do SL como % do preço do ativo.

- **GRUPO 6: OPERAÇÕES DE VENDA**
	- `InpPermitirVenda` (bool): permitir operações de venda (short). Padrão: true.

- **GRUPO 7: HORÁRIOS E DIAS**
	- Flags de dia da semana (`InpSegunda`, `InpTerca`, etc.) para permitir negociação em dias específicos.
	- `InpHoraIni` / `InpMinIni` e `InpHoraFim` / `InpMinFim`: janela diária de operação.
	- `InpCloseEnd` (bool): fechar posições ao fim do horário.

Lógica de sinais e armamento
- Cada indicador tem um handle e uma média de confirmação. Quando ocorre cruzamento no candle anterior, o sinal é marcado como `armed` e guarda o número de barras para controle de retenção.
- Regra "novo toque a partir do candle seguinte": um sinal armado só desarma quando, a partir do candle seguinte ao armado, o indicador tocar a média (requer candle adicional).
- Expiração de sinais ocorre após `InpMaxRetention` candles.

Reversão de slope (filtro opcional)
- Implementado nas funções `IsMARevertingUp` e `IsMARevertingDown` que analisam 6 candles fechados da MA do indicador para detectar mudança de direção antes de aceitar o sinal.

Execução da ordem e gestão
- Tamanho do lote calculado como `cap = AccountBalance * (InpCapPercent/100)` dividido pelo preço, ajustado ao `LotsStep` e `LotsMin` do símbolo.
- SL calculado por ATR*`InpMultiplicadorStop` limitado por `InpMaxSLPrice` (% preço).
- TP1/TP2/TP3 fixos a 1×, 2×, 3× da distância do SL.
- Ao abrir, o EA define TP final conforme `InpRR_Final` mas internamente gerencia parciais e pode zerar TP no broker para controlar manualmente as saídas.

Proteções e comportamentos especiais
- `InpMaxTradesDay` limita entradas por ativo por dia (ver `GetDailyTrades`).
- `CheckDrawdown` fecha posições com o magic number do EA e define a variável global `EA_MA_DISABLED_<Symbol>` para `1` quando o drawdown percentual excede `InpMaxDrawdown`, desativando o EA persistentemente até remoção manual da variável.

Instalação e uso
- Copie `EXP-MultiAsset.mq5` para a pasta `MQL5/Experts` e compile no MetaEditor.
- Carregue o EA no gráfico do ativo desejado e ajuste os parâmetros conforme perfil (capital, permissões de venda, horários, indicadores usados).

Recomendações
- Testar em conta demo antes de operar em real.
- Ajustar `InpCapPercent` e `InpMaxDrawdown` conforme gestão de risco do operador.
- Validar regras de horário e dias para o horário local do servidor do corretor.

Contatos e versão
- Autor: EXP Automação STI LTDA
- Site: https://www.expautomacao.com.br
- Versão do código: 1.40

