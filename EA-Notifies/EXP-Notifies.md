# EXP-Notifies

## Descrição
O **EXP-Notifies** é um Expert Advisor (EA) desenvolvido para a plataforma MetaTrader 5 (MT5) pela EXP Automação STI LTDA. Ele tem como objetivo emitir notificações baseadas em eventos técnicos e padrões de mercado, auxiliando os traders na tomada de decisão. Este EA é altamente configurável e permite monitorar diversos indicadores técnicos e padrões de reversão.

## Funcionalidades

### 1. Notificações baseadas em Médias Móveis (MAs)
- O EA monitora três médias móveis configuráveis (rápida, média e lenta).
- Emite notificações quando o preço toca qualquer uma dessas médias móveis no fechamento do candle.

### 2. Notificações de Padrões de Reversão (V-Shape)
- Detecta padrões de reversão em formato de "V" para os seguintes indicadores:
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Índice de Força Relativa)
  - Estocástico
- Os padrões de reversão são tolerantes a pequenas imperfeições no fundo ou topo.

### 3. Notificações de Sobrecompra e Sobrevenda
- **RSI**:
  - Notifica quando o RSI sai das regiões de sobrecompra ou sobrevenda.
- **Estocástico**:
  - Notifica quando o Estocástico sai das regiões de sobrecompra ou sobrevenda.

### 4. Notificações de Agressão de Volume
- **Volume**:
  - Monitora agressões de volume em um timeframe dedicado e notifica quando o volume ultrapassa a média configurada.

## Configurações
O EA possui diversas opções de configuração para personalização:

### Parâmetros Gerais
- **Médias Móveis**:
  - Períodos, métodos e preços aplicados para as médias rápidas, médias e lentas.
  - Habilitação de notificações para toques nas médias.
- **Momentum**:
  - Período e método de cálculo.
  - Habilitação de notificações para padrões V-Shape.
- **OBV**:
  - Método de cálculo e habilitação de notificações para padrões V-Shape.
- **RSI**:
  - Período, limites de sobrecompra/sobrevenda e método de cálculo.
  - Habilitação de notificações para cruzamentos e padrões V-Shape.
- **Estocástico**:
  - Parâmetros %K, %D e Slow, além de limites de sobrecompra/sobrevenda.
  - Habilitação de notificações para cruzamentos e padrões V-Shape.
- **Volume**:
  - Timeframe dedicado, período e método de cálculo.
  - Habilitação de notificações para agressões de volume.

## Lógica de Funcionamento

1. **Inicialização**:
   - Os indicadores técnicos são configurados e os handles necessários são criados.
   - Buffers são inicializados para armazenar os dados dos indicadores.

2. **Execução no Tick**:
   - A cada novo tick, o EA verifica se há um novo candle principal ou de volume.
   - Para cada novo candle:
     - Verifica toques nas médias móveis.
     - Avalia cruzamentos e padrões de reversão nos indicadores técnicos.
     - Envia notificações conforme as condições configuradas.

3. **Notificações**:
   - As mensagens de notificação incluem o símbolo, timeframe e horário do evento.
   - São enviadas diretamente para o terminal do MetaTrader ou dispositivos móveis conectados.

## Requisitos
- Plataforma MetaTrader 5.
- Conexão ativa com a internet para envio de notificações.

## Créditos
- Desenvolvido por **EXP Automação STI LTDA**.
- Website: [https://www.expautomacao.com.br](https://www.expautomacao.com.br)

---

Este documento descreve as funcionalidades e o funcionamento do EA **EXP-Notifies**. Para dúvidas ou suporte, entre em contato com o desenvolvedor.