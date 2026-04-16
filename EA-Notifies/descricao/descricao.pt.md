# EXP-Notifies

**O Assistente de Análise Técnica que Trabalha por Você – Sem Abrir Posições, Sem Riscos, Apenas Alertas Inteligentes**

**Receba notificações precisas de padrões de mercado e tome decisões com consciência – direto do seu celular, sem ficar preso à tela do computador.**

---

## Descrição Principal

O **EXP-Notifies** não é um robô de negociação comum. Ele foi desenvolvido para **traders que querem manter o controle total sobre suas entradas e saídas**, mas não têm tempo de ficar monitorando gráficos o dia inteiro.

Enquanto robôs de negociação automatizada executam ordens por você (muitas vezes sem contexto), o EXP-Notifies **apenas avisa** quando condições técnicas relevantes acontecem. A decisão final e o gerenciamento de risco permanece 100% com você.

---

## Por que escolher um Robô de Notificações em vez de um Robô de Negociação?

### ✅ **1. Sem surpresas – você decide se entra ou não**  
O robô não abre, não fecha e não modifica nenhuma posição. Isso elimina o risco de execuções indesejadas causadas por volatilidade anormal ou falhas na lógica automatizada.

### ✅ **2. Monitore múltiplos ativos simultaneamente**  
Enquanto um trader humano acompanha 1 ou 2 pares, o EXP-Notifies pode monitorar dezenas de ativos, timeframes e indicadores ao mesmo tempo – e só te chama quando algo realmente relevante acontece.

### ✅ **3. Receba alertas no celular e aja de onde estiver**  
As notificações vão direto para o seu MetaTrader 5 no celular. Você pode estar no trabalho, na academia ou em casa – ao receber o alerta, avalia rapidamente o contexto operacional do momento e decide se abre a posição.

### ✅ **4. Melhor gerenciamento de risco**  
Como você analisa cada sinal antes de agir, pode filtrar operações que não se encaixam no seu momento de mercado, horário favorável, apetite a risco ou condições de capital. Nenhum robô de negociação oferece esse nível de flexibilidade.

### ✅ **5. Ideal para traders discricionários**  
Se você confia no seu julgamento, mas quer economizar horas de análise gráfica, o EXP-Notifies age como um assistente incansável – detectando toques em médias móveis, padrões V-Shape (em RSI, OBV, Momentum e Estocástico), reversões de sobrecompra/sobrevenda e agressões de volume.

---

## Diferenciais Técnicos do EXP-Notifies

- **Configurável do zero**: períodos, métodos, limites e timeframes personalizáveis para cada indicador.
- **Tolerante a imperfeições**: a detecção de padrões V-Shape foi projetada para funcionar mesmo com pequenas variações no fundo ou topo.
- **Foco no candle fechado**: evita falsos sinais intrabar.
- **Timeframe dedicado para volume**: análise separada da agressão de volume, sem interferir na estrutura principal.

---

## Público-alvo

Este EA é perfeito para:
- Traders discricionários que não usam robôs de negociação automática.
- Gestores que querem alertas técnicos para múltiplos ativos sem automatizar execuções.
- Iniciantes que desejam aprender padrões de mercado com alertas objetivos.
- Profissionais que operam pelo celular e precisam de sinais confiáveis.

---

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

---

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

---

## Conclusão

Com o **EXP-Notifies**, você não perde mais oportunidades por falta de tempo, mas também não entrega o controle da sua conta a um robô. **Ele cuida da análise pesada. Você cuida da decisão inteligente.**

---