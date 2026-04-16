# EXP-Notifies

**Il tuo assistente di analisi tecnica che lavora per te – senza aprire posizioni, senza rischi, solo avvisi intelligenti**

**Ricevi notifiche precise sui pattern di mercato e prendi decisioni di trading consapevoli – direttamente sul tuo cellulare, senza rimanere incollato allo schermo del computer.**

---

## Descrizione principale

**EXP-Notifies** non è un comune robot di trading. È stato sviluppato per **trader che vogliono mantenere il controllo totale sui propri ingressi e uscite**, ma non hanno tempo di monitorare i grafici tutto il giorno.

Mentre i robot di trading automatizzato eseguono ordini per te (spesso senza contesto), EXP-Notifies **ti avvisa solo** quando si verificano condizioni tecniche rilevanti. La decisione finale – e la gestione del rischio – rimane al 100% tua.

---

## Perché scegliere un Robot di Notifica invece di un Robot di Trading?

### ✅ **1. Nessuna sorpresa – decidi tu se entrare o no**
Il robot non apre, non chiude e non modifica alcuna posizione. Ciò elimina il rischio di esecuzioni indesiderate causate da volatilità anomala o difetti nella logica automatizzata.

### ✅ **2. Monitora più asset simultaneamente**
Mentre un trader umano segue 1 o 2 coppie, EXP-Notifies può monitorare dozzine di asset, timeframe e indicatori allo stesso tempo – e ti contatta solo quando accade qualcosa di veramente rilevante.

### ✅ **3. Ricevi avvisi sul cellulare e agisci ovunque ti trovi**
Le notifiche vanno direttamente sul tuo MetaTrader 5 sul cellulare. Che tu sia al lavoro, in palestra o a casa – quando ricevi un avviso, valuti rapidamente il contesto operativo del momento e decidi se aprire una posizione.

### ✅ **4. Migliore gestione del rischio**
Poiché analizzi ogni segnale prima di agire, puoi filtrare le operazioni che non si adattano al tuo momento di mercato, orario favorevole, propensione al rischio o condizioni di capitale. Nessun robot di trading offre questo livello di flessibilità.

### ✅ **5. Ideale per trader discrezionali**
Se ti fidi del tuo giudizio ma vuoi risparmiare ore di analisi grafica, EXP-Notifies agisce come un assistente instancabile – rilevando tocchi sulle medie mobili, pattern a V (su RSI, OBV, Momentum e Stocastico), inversioni da ipercomprato/ipervenduto e picchi di volume.

---

## Differenziatori tecnici di EXP-Notifies

- **Completamente configurabile** : periodi, metodi, limiti e timeframe personalizzabili per ogni indicatore.
- **Tollerante alle imperfezioni** : il rilevamento dei pattern a V è progettato per funzionare anche con piccole variazioni sui minimi o massimi.
- **Focus sulla chiusura della candela** : evita falsi segnali intra-barra.
- **Timeframe dedicato per il volume** : analisi separata dei picchi di volume senza interferire con la struttura principale del grafico.

---

## Pubblico target

Questo EA è perfetto per:
- Trader discrezionali che non utilizzano robot di trading automatico.
- Gestori che vogliono avvisi tecnici per multipli asset senza automatizzare le esecuzioni.
- Principianti che desiderano apprendere i pattern di mercato attraverso avvisi oggettivi.
- Professionisti che operano tramite cellulare e necessitano di segnali affidabili.

---

## Funzionalità

### 1. Notifiche basate sulle Medie Mobili (MAs)
- L'EA monitora tre medie mobili configurabili (veloce, media e lenta).
- Invia notifiche quando il prezzo tocca una qualsiasi di queste medie mobili alla chiusura della candela.

### 2. Notifiche di pattern di inversione (V-Shape)
- Rileva pattern di inversione a forma di "V" per i seguenti indicatori:
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Relative Strength Index)
  - Stocastico
- I pattern di inversione tollerano piccole imperfezioni sui minimi o massimi.

### 3. Notifiche di ipercomprato/ipervenduto
- **RSI** :
  - Notifica quando l'RSI esce dalle regioni di ipercomprato o ipervenduto.
- **Stocastico** :
  - Notifica quando lo Stocastico esce dalle regioni di ipercomprato o ipervenduto.

### 4. Notifiche di picchi di volume
- **Volume** :
  - Monitora i picchi di volume su un timeframe dedicato e notifica quando il volume supera la media configurata.

---

### Parametri generali
- **Medie Mobili** :
  - Periodi, metodi e prezzi applicati per le medie veloci, medie e lente.
  - Abilitazione/disabilitazione delle notifiche per i tocchi sulle medie.
- **Momentum** :
  - Periodo e metodo di calcolo.
  - Abilitazione/disabilitazione delle notifiche per i pattern a V.
- **OBV** :
  - Metodo di calcolo e abilitazione/disabilitazione delle notifiche per i pattern a V.
- **RSI** :
  - Periodo, limiti di ipercomprato/ipervenduto e metodo di calcolo.
  - Abilitazione/disabilitazione delle notifiche per incroci e pattern a V.
- **Stocastico** :
  - Parametri %K, %D e Slow, oltre ai limiti di ipercomprato/ipervenduto.
  - Abilitazione/disabilitazione delle notifiche per incroci e pattern a V.
- **Volume** :
  - Timeframe dedicato, periodo e metodo di calcolo.
  - Abilitazione/disabilitazione delle notifiche per picchi di volume.

## Logica di funzionamento

1. **Inizializzazione** :
   - Gli indicatori tecnici vengono configurati e vengono creati gli handle necessari.
   - I buffer vengono inizializzati per memorizzare i dati degli indicatori.

2. **Esecuzione sul tick** :
   - Ad ogni nuovo tick, l'EA verifica se c'è una nuova candela principale o una candela di volume.
   - Per ogni nuova candela :
     - Verifica i tocchi sulle medie mobili.
     - Valuta incroci e pattern di inversione sugli indicatori tecnici.
     - Invia notifiche secondo le condizioni configurate.

3. **Notifiche** :
   - I messaggi di notifica includono il simbolo, il timeframe e l'orario dell'evento.
   - Vengono inviati direttamente al terminale MetaTrader o ai dispositivi mobili connessi.

---

## Conclusione

Con **EXP-Notifies**, non perdi più opportunità per mancanza di tempo, ma non consegni nemmeno il controllo del tuo conto a un robot. **Lui si occupa dell'analisi pesante. Tu prendi la decisione intelligente.**