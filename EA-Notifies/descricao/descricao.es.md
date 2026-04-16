# EXP-Notifies

**Tu Asistente de Análisis Técnico que Trabaja por Ti – Sin Abrir Posiciones, Sin Riesgos, Solo Alertas Inteligentes**

**Recibe notificaciones precisas de patrones de mercado y toma decisiones conscientes – directamente en tu celular, sin estar pegado a la pantalla de la computadora.**

---

## Descripción Principal

El **EXP-Notifies** no es un robot de negociación común. Fue desarrollado para **traders que quieren mantener el control total sobre sus entradas y salidas**, pero no tienen tiempo para estar monitoreando gráficos todo el día.

Mientras que los robots de negociación automatizada ejecutan órdenes por ti (muchas veces sin contexto), el EXP-Notifies **solo avisa** cuando ocurren condiciones técnicas relevantes. La decisión final y la gestión del riesgo permanecen 100% contigo.

---

## ¿Por qué elegir un Robot de Notificaciones en lugar de un Robot de Negociación?

### ✅ **1. Sin sorpresas – tú decides si entras o no**
El robot no abre, no cierra ni modifica ninguna posición. Esto elimina el riesgo de ejecuciones no deseadas causadas por volatilidad anormal o fallos en la lógica automatizada.

### ✅ **2. Monitorea múltiples activos simultáneamente**
Mientras que un trader humano sigue 1 o 2 pares, el EXP-Notifies puede monitorear docenas de activos, temporalidades e indicadores al mismo tiempo – y solo te llama cuando algo realmente relevante ocurre.

### ✅ **3. Recibe alertas en el celular y actúa donde estés**
Las notificaciones van directamente a tu MetaTrader 5 en el celular. Puedes estar en el trabajo, en el gimnasio o en casa – al recibir la alerta, evalúas rápidamente el contexto operativo del momento y decides si abrir la posición.

### ✅ **4. Mejor gestión de riesgo**
Como analizas cada señal antes de actuar, puedes filtrar operaciones que no encajan en tu momento de mercado, horario favorable, apetito por el riesgo o condiciones de capital. Ningún robot de negociación ofrece este nivel de flexibilidad.

### ✅ **5. Ideal para traders discrecionales**
Si confías en tu criterio pero quieres ahorrar horas de análisis gráfico, el EXP-Notifies actúa como un asistente incansable – detectando toques en medias móviles, patrones V-Shape (en RSI, OBV, Momentum y Estocástico), reversiones de sobrecompra/sobreventa y agresiones de volumen.

---

## Diferenciadores Técnicos del EXP-Notifies

- **Totalmente configurable**: periodos, métodos, límites y temporalidades personalizables para cada indicador.
- **Tolerante a imperfecciones**: la detección de patrones V-Shape está diseñada para funcionar incluso con pequeñas variaciones en el fondo o techo.
- **Enfoque en vela cerrada**: evita señales falsas dentro de la barra.
- **Temporalidad dedicada para volumen**: análisis separado de la agresión de volumen, sin interferir en la estructura principal.

---

## Público Objetivo

Este EA es perfecto para:
- Traders discrecionales que no usan robots de negociación automática.
- Gestores que quieren alertas técnicas para múltiples activos sin automatizar ejecuciones.
- Principiantes que desean aprender patrones de mercado con alertas objetivas.
- Profesionales que operan desde el celular y necesitan señales confiables.

---

## Funcionalidades

### 1. Notificaciones basadas en Medias Móviles (MAs)
- El EA monitorea tres medias móviles configurables (rápida, media y lenta).
- Emite notificaciones cuando el precio toca cualquiera de estas medias móviles al cierre de la vela.

### 2. Notificaciones de Patrones de Reversión (V-Shape)
- Detecta patrones de reversión en forma de "V" para los siguientes indicadores:
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Índice de Fuerza Relativa)
  - Estocástico
- Los patrones de reversión son tolerantes a pequeñas imperfecciones en el fondo o techo.

### 3. Notificaciones de Sobrecompra y Sobrevenda
- **RSI**:
  - Notifica cuando el RSI sale de las regiones de sobrecompra o sobrevenda.
- **Estocástico**:
  - Notifica cuando el Estocástico sale de las regiones de sobrecompra o sobrevenda.

### 4. Notificaciones de Agresión de Volumen
- **Volumen**:
  - Monitorea agresiones de volumen en una temporalidad dedicada y notifica cuando el volumen supera el promedio configurado.

---

### Parámetros Generales
- **Medias Móviles**:
  - Periodos, métodos y precios aplicados para las medias rápidas, medias y lentas.
  - Habilitación de notificaciones para toques en las medias.
- **Momentum**:
  - Periodo y método de cálculo.
  - Habilitación de notificaciones para patrones V-Shape.
- **OBV**:
  - Método de cálculo y habilitación de notificaciones para patrones V-Shape.
- **RSI**:
  - Periodo, límites de sobrecompra/sobrevenda y método de cálculo.
  - Habilitación de notificaciones para cruces y patrones V-Shape.
- **Estocástico**:
  - Parámetros %K, %D y Slow, además de límites de sobrecompra/sobrevenda.
  - Habilitación de notificaciones para cruces y patrones V-Shape.
- **Volumen**:
  - Temporalidad dedicada, periodo y método de cálculo.
  - Habilitación de notificaciones para agresiones de volumen.

## Lógica de Funcionamiento

1. **Inicialización**:
   - Los indicadores técnicos se configuran y se crean los handles necesarios.
   - Se inicializan buffers para almacenar los datos de los indicadores.

2. **Ejecución en Tick**:
   - En cada nuevo tick, el EA verifica si hay una nueva vela principal o de volumen.
   - Para cada nueva vela:
     - Verifica toques en las medias móviles.
     - Evalúa cruces y patrones de reversión en los indicadores técnicos.
     - Envía notificaciones según las condiciones configuradas.

3. **Notificaciones**:
   - Los mensajes de notificación incluyen el símbolo, temporalidad y hora del evento.
   - Se envían directamente al terminal de MetaTrader o a dispositivos móviles conectados.

---

## Conclusión

Con el **EXP-Notifies**, ya no pierdes oportunidades por falta de tiempo, pero tampoco entregas el control de tu cuenta a un robot. **Él se encarga del análisis pesado. Tú tomas la decisión inteligente.**