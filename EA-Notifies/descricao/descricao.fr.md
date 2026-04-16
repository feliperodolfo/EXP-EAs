# EXP-Notifies

**Votre assistant d'analyse technique qui travaille pour vous – sans ouvrir de positions, sans risques, seulement des alertes intelligentes**

**Recevez des notifications précises sur les modèles de marché et prenez des décisions de trading éclairées – directement sur votre mobile, sans être collé à l'écran de votre ordinateur.**

---

## Description principale

**EXP-Notifies** n'est pas un robot de trading ordinaire. Il a été développé pour **les traders qui veulent garder un contrôle total sur leurs entrées et sorties**, mais qui n'ont pas le temps de surveiller les graphiques toute la journée.

Alors que les robots de trading automatisés exécutent des ordres pour vous (souvent sans contexte), EXP-Notifies **vous alerte uniquement** lorsque des conditions techniques pertinentes se produisent. La décision finale – et la gestion des risques – reste 100% à vous.

---

## Pourquoi choisir un Robot de Notification plutôt qu'un Robot de Trading ?

### ✅ **1. Pas de surprises – vous décidez d'entrer ou non**
Le robot n'ouvre, ne ferme et ne modifie aucune position. Cela élimine le risque d'exécutions indésirables causées par une volatilité anormale ou des défauts dans la logique automatisée.

### ✅ **2. Surveillez plusieurs actifs simultanément**
Alors qu'un trader humain suit 1 ou 2 paires, EXP-Notifies peut surveiller des dizaines d'actifs, de timeframes et d'indicateurs en même temps – et ne vous contacte que lorsque quelque chose de vraiment pertinent se produit.

### ✅ **3. Recevez des alertes sur votre mobile et agissez où que vous soyez**
Les notifications vont directement sur votre MetaTrader 5 sur votre mobile. Que vous soyez au travail, à la salle de sport ou à la maison – lorsque vous recevez une alerte, vous évaluez rapidement le contexte opérationnel du moment et décidez d'ouvrir ou non une position.

### ✅ **4. Une meilleure gestion des risques**
Comme vous analysez chaque signal avant d'agir, vous pouvez filtrer les opérations qui ne correspondent pas à votre situation de marché, vos horaires de trading favorables, votre appétence au risque ou vos conditions de capital. Aucun robot de trading n'offre ce niveau de flexibilité.

### ✅ **5. Idéal pour les traders discrétionnaires**
Si vous avez confiance en votre jugement mais souhaitez économiser des heures d'analyse graphique, EXP-Notifies agit comme un assistant infatigable – détectant les touches sur les moyennes mobiles, les modèles en V (sur RSI, OBV, Momentum et Stochastique), les retournements de surachat/survente et les pics de volume.

---

## Différenciateurs techniques d'EXP-Notifies

- **Entièrement configurable** : périodes, méthodes, limites et timeframes personnalisables pour chaque indicateur.
- **Tolérant aux imperfections** : la détection des modèles en V est conçue pour fonctionner même avec de petites variations au niveau des creux ou des sommets.
- **Focus sur la bougie fermée** : évite les faux signaux intra-barre.
- **Timeframe dédié pour le volume** : analyse séparée des pics de volume sans interférer avec la structure principale du graphique.

---

## Public cible

Cet EA est parfait pour :
- Les traders discrétionnaires qui n'utilisent pas de robots de trading automatisés.
- Les gestionnaires qui veulent des alertes techniques pour plusieurs actifs sans automatiser les exécutions.
- Les débutants qui souhaitent apprendre les modèles de marché grâce à des alertes objectives.
- Les professionnels qui tradent via mobile et ont besoin de signaux fiables.

---

## Fonctionnalités

### 1. Notifications basées sur les Moyennes Mobiles (MAs)
- L'EA surveille trois moyennes mobiles configurables (rapide, moyenne et lente).
- Émet des notifications lorsque le prix touche l'une de ces moyennes mobiles à la fermeture de la bougie.

### 2. Notifications de modèles de retournement (V-Shape)
- Détecte les modèles de retournement en forme de "V" pour les indicateurs suivants :
  - Momentum
  - OBV (On-Balance Volume)
  - RSI (Relative Strength Index)
  - Stochastique
- Les modèles de retournement tolèrent les petites imperfections au niveau des creux ou des sommets.

### 3. Notifications de surachat/survente
- **RSI** :
  - Notifie lorsque le RSI sort des zones de surachat ou de survente.
- **Stochastique** :
  - Notifie lorsque le Stochastique sort des zones de surachat ou de survente.

### 4. Notifications de pics de volume
- **Volume** :
  - Surveille les pics de volume sur un timeframe dédié et notifie lorsque le volume dépasse la moyenne configurée.

---

### Paramètres généraux
- **Moyennes Mobiles** :
  - Périodes, méthodes et prix appliqués pour les moyennes rapides, moyennes et lentes.
  - Activation/désactivation des notifications pour les touches sur les moyennes.
- **Momentum** :
  - Période et méthode de calcul.
  - Activation/désactivation des notifications pour les modèles en V.
- **OBV** :
  - Méthode de calcul et activation/désactivation des notifications pour les modèles en V.
- **RSI** :
  - Période, limites de surachat/survente et méthode de calcul.
  - Activation/désactivation des notifications pour les croisements et les modèles en V.
- **Stochastique** :
  - Paramètres %K, %D et Slow, ainsi que les limites de surachat/survente.
  - Activation/désactivation des notifications pour les croisements et les modèles en V.
- **Volume** :
  - Timeframe dédié, période et méthode de calcul.
  - Activation/désactivation des notifications pour les pics de volume.

## Logique de fonctionnement

1. **Initialisation** :
   - Les indicateurs techniques sont configurés et les handles nécessaires sont créés.
   - Des tampons sont initialisés pour stocker les données des indicateurs.

2. **Exécution sur tick** :
   - À chaque nouveau tick, l'EA vérifie s'il y a une nouvelle bougie principale ou une bougie de volume.
   - Pour chaque nouvelle bougie :
     - Vérifie les touches sur les moyennes mobiles.
     - Évalue les croisements et les modèles de retournement sur les indicateurs techniques.
     - Envoie des notifications selon les conditions configurées.

3. **Notifications** :
   - Les messages de notification incluent le symbole, le timeframe et l'heure de l'événement.
   - Ils sont envoyés directement au terminal MetaTrader ou aux appareils mobiles connectés.

---

## Conclusion

Avec **EXP-Notifies**, vous ne manquez plus d'opportunités par manque de temps, mais vous ne confiez pas non plus le contrôle de votre compte à un robot. **Il s'occupe de l'analyse lourde. Vous prenez la décision intelligente.**