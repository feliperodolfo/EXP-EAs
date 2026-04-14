# EXP-Notifies

## Descripción
**EXP-Notifies** es un Asesor Experto (EA) desarrollado para la plataforma MetaTrader 5 (MT5) por EXP Automação STI LTDA. Su objetivo es emitir notificaciones basadas en eventos técnicos y patrones de mercado, ayudando a los traders en la toma de decisiones. Este EA es altamente configurable y permite monitorear varios indicadores técnicos y patrones de reversión.

## Funcionalidades

### 1. Notificaciones basadas en Medias Móviles (MAs)
- El EA monitorea tres medias móviles configurables (rápida, media y lenta).
- Envía notificaciones cuando el precio toca cualquiera de estas medias móviles en el cierre de la vela.

### 2. Notificaciones de patrones de reversión en V
- Detecta patrones de reversión en forma de "V" para los siguientes indicadores:
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Índice de Fuerza Relativa)
  - Estocástico
- Los patrones de reversión toleran pequeñas imperfecciones en el mínimo o máximo.

### 3. Notificaciones de sobrecompra y sobreventa
- **RSI**:
  - Notifica cuando el RSI sale de las regiones de sobrecompra o sobreventa.
- **Estocástico**:
  - Notifica cuando el Estocástico sale de las regiones de sobrecompra o sobreventa.

### 4. Notificaciones de agresión de volumen
- **Volumen**:
  - Monitorea agresiones de volumen en un timeframe dedicado y notifica cuando el volumen supera la media configurada.

## Configuraciones
El EA ofrece varias opciones de configuración para personalización:

### Parámetros Generales
- **Medias Móviles**:
  - Períodos, métodos y precio aplicado para las medias rápidas, medias y lentas.
  - Habilitar notificaciones para toques en las medias móviles.
- **Momentum**:
  - Período y método de cálculo.
  - Habilitar notificaciones para patrones en V.
- **OBV**:
  - Método de cálculo y habilitar notificaciones para patrones en V.
- **RSI**:
  - Período, límites de sobrecompra/sobreventa y método de cálculo.
  - Habilitar notificaciones para cruces y patrones en V.
- **Estocástico**:
  - Parámetros %K, %D y Slow, además de límites de sobrecompra/sobreventa.
  - Habilitar notificaciones para cruces y patrones en V.
- **Volumen**:
  - Timeframe dedicado, período y método de cálculo.
  - Habilitar notificaciones para agresiones de volumen.

## Lógica de Funcionamiento

1. **Inicialización**:
   - Se configuran los indicadores técnicos y se crean los handles necesarios.
   - Se inicializan buffers para almacenar los datos de los indicadores.

2. **Ejecución por Tick**:
   - En cada nuevo tick, el EA verifica si hay una nueva vela principal o de volumen.
   - Para cada nueva vela:
     - Verifica toques en las medias móviles.
     - Evalúa cruces y patrones de reversión en los indicadores técnicos.
     - Envía notificaciones según las condiciones configuradas.

3. **Notificaciones**:
   - Los mensajes de notificación incluyen el símbolo, timeframe y horario del evento.
   - Se envían directamente al terminal de MetaTrader o a dispositivos móviles conectados.

## Requisitos
- Plataforma MetaTrader 5.
- Conexión activa a internet para el envío de notificaciones.

## Créditos
- Desarrollado por **EXP Automação STI LTDA**.
- Sitio web: [https://www.expautomacao.com.br](https://www.expautomacao.com.br)

---

Este documento describe las funcionalidades y el funcionamiento del EA **EXP-Notifies**. Para dudas o soporte, contacte al desarrollador.
