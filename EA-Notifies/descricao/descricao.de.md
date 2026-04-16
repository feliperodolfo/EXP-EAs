# EXP-Notifies

**Ihr technischer Analyse-Assistent, der für Sie arbeitet – ohne Positionen zu eröffnen, ohne Risiken, nur intelligente Benachrichtigungen**

**Erhalten Sie präzise Benachrichtigungen über Marktmuster und treffen Sie bewusste Handelsentscheidungen – direkt auf Ihrem Handy, ohne an den Computerbildschirm gefesselt zu sein.**

---

## Hauptbeschreibung

**EXP-Notifies** ist kein gewöhnlicher Handelsroboter. Er wurde für **Trader entwickelt, die die volle Kontrolle über ihre Ein- und Ausstiege behalten möchten**, aber keine Zeit haben, den ganzen Tag Charts zu überwachen.

Während automatisierte Handelsroboter Aufträge für Sie ausführen (oft ohne Kontext), **warnt EXP-Notifies Sie nur**, wenn relevante technische Bedingungen auftreten. Die endgültige Entscheidung und das Risikomanagement bleiben zu 100% bei Ihnen.

---

## Warum einen Benachrichtigungsroboter anstelle eines Handelsroboters wählen?

### ✅ **1. Keine Überraschungen – Sie entscheiden, ob Sie einsteigen oder nicht**
Der Roboter eröffnet, schließt oder modifiziert keine Positionen. Dies eliminiert das Risiko unerwünschter Ausführungen, die durch anormale Volatilität oder Fehler in der automatisierten Logik verursacht werden.

### ✅ **2. Überwachen Sie mehrere Assets gleichzeitig**
Während ein menschlicher Trader 1-2 Paare verfolgt, kann EXP-Notifies Dutzende von Assets, Zeitrahmen und Indikatoren gleichzeitig überwachen – und kontaktiert Sie nur, wenn wirklich etwas Relevantes passiert.

### ✅ **3. Erhalten Sie Alarme auf Ihrem Handy und handeln Sie von überall**
Benachrichtigungen gehen direkt an Ihr MetaTrader 5 auf dem Handy. Ob Sie bei der Arbeit, im Fitnessstudio oder zu Hause sind – wenn Sie einen Alarm erhalten, bewerten Sie schnell den aktuellen Marktkontext und entscheiden, ob Sie eine Position eröffnen.

### ✅ **4. Besseres Risikomanagement**
Da Sie jedes Signal vor dem Handeln analysieren, können Sie Trades herausfiltern, die nicht zu Ihrer aktuellen Marktsituation, Ihren bevorzugten Handelszeiten, Ihrer Risikobereitschaft oder Ihren Kapitalbedingungen passen. Kein Handelsroboter bietet dieses Maß an Flexibilität.

### ✅ **5. Ideal für diskretionäre Trader**
Wenn Sie Ihrem eigenen Urteil vertrauen, aber Stunden der Chartanalyse sparen möchten, fungiert EXP-Notifies als unermüdlicher Assistent – der Berührungen von gleitenden Durchschnitten, V-förmige Muster (auf RSI, OBV, Momentum und Stochastic), Überkauft-/Überverkauft-Umkehrungen und Volumenspitzen erkennt.

---

## Technische Unterschiede von EXP-Notifies

- **Vollständig konfigurierbar**: Perioden, Methoden, Grenzen und Zeitrahmen für jeden Indikator anpassbar.
- **Unvollkommenheitstolerant**: Die Erkennung von V-förmigen Mustern wurde entwickelt, um auch bei kleinen Abweichungen an Tiefs oder Hochs zu funktionieren.
- **Fokus auf Kerzenschluss**: Vermeidet falsche Intra-Bar-Signale.
- **Dedizierter Zeitrahmen für Volumen**: Getrennte Analyse von Volumenspitzen ohne Beeinträchtigung der Hauptchartstruktur.

---

## Zielgruppe

Dieser EA ist perfekt für:
- Diskre tionäre Trader, die keine automatisierten Handelsroboter verwenden.
- Manager, die technische Alarme für mehrere Assets ohne Automatisierung von Ausführungen wünschen.
- Anfänger, die Marktmuster mit objektiven Alarmen erlernen möchten.
- Profis, die per Handy handeln und zuverlässige Signale benötigen.

---

## Funktionen

### 1. Benachrichtigungen über gleitende Durchschnitte (MAs)
- Der EA überwacht drei konfigurierbare gleitende Durchschnitte (schnell, mittel, langsam).
- Sendet Benachrichtigungen, wenn der Preis einen dieser gleitenden Durchschnitte bei Kerzenschluss berührt.

### 2. Benachrichtigungen über V-förmige Umkehrmuster
- Erkennt V-förmige Umkehrmuster für die folgenden Indikatoren:
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Relative Strength Index)
  - Stochastic
- Umkehrmuster sind tolerant gegenüber kleinen Unvollkommenheiten an Tiefs oder Hochs.

### 3. Benachrichtigungen über Überkaufte/Überverkaufte Zonen
- **RSI**:
  - Benachrichtigt, wenn der RSI überkaufte oder überverkaufte Zonen verlässt.
- **Stochastic**:
  - Benachrichtigt, wenn der Stochastic überkaufte oder überverkaufte Zonen verlässt.

### 4. Benachrichtigungen über Volumenspitzen
- **Volumen**:
  - Überwacht Volumenspitzen in einem dedizierten Zeitrahmen und benachrichtigt, wenn das Volumen den konfigurierten Durchschnitt überschreitet.

---

### Allgemeine Parameter
- **Gleitende Durchschnitte**:
  - Perioden, Methoden und angewendete Preise für schnelle, mittlere und langsame Durchschnitte.
  - Aktivierung/Deaktivierung von Benachrichtigungen für MA-Berührungen.
- **Momentum**:
  - Periode und Berechnungsmethode.
  - Aktivierung/Deaktivierung von Benachrichtigungen für V-förmige Muster.
- **OBV**:
  - Berechnungsmethode und Aktivierung/Deaktivierung von Benachrichtigungen für V-förmige Muster.
- **RSI**:
  - Periode, Überkauft/Überverkauft-Grenzen und Berechnungsmethode.
  - Aktivierung/Deaktivierung von Benachrichtigungen für Überschneidungen und V-förmige Muster.
- **Stochastic**:
  - %K-, %D- und Slow-Parameter sowie Überkauft/Überverkauft-Grenzen.
  - Aktivierung/Deaktivierung von Benachrichtigungen für Überschneidungen und V-förmige Muster.
- **Volumen**:
  - Dedizierter Zeitrahmen, Periode und Berechnungsmethode.
  - Aktivierung/Deaktivierung von Benachrichtigungen für Volumenspitzen.

## Funktionslogik

1. **Initialisierung**:
   - Technische Indikatoren werden konfiguriert und die erforderlichen Handles werden erstellt.
   - Puffer werden initialisiert, um die Indikatordaten zu speichern.

2. **OnTick-Ausführung**:
   - Bei jedem neuen Tick prüft der EA, ob eine neue Hauptkerze oder Volumenkerze vorliegt.
   - Für jede neue Kerze:
     - Prüft Berührungen der gleitenden Durchschnitte.
     - Bewertet Überschneidungen und Umkehrmuster bei technischen Indikatoren.
     - Sendet Benachrichtigungen gemäß den konfigurierten Bedingungen.

3. **Benachrichtigungen**:
   - Die Benachrichtigungsnachrichten enthalten Symbol, Zeitrahmen und Ereigniszeit.
   - Sie werden direkt an das MetaTrader-Terminal oder verbundene mobile Geräte gesendet.

---

## Fazit

Mit **EXP-Notifies** verpassen Sie keine Gelegenheiten mehr aufgrund von Zeitmangel, aber Sie geben auch nicht die Kontrolle über Ihr Konto an einen Roboter ab. **Er kümmert sich um die schwere Analyse. Sie treffen die intelligente Entscheidung.**