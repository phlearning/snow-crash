## SnowCrash - Level 03

### 1. Objectif
Exploiter un binaire possédant le bit **SUID** pour exécuter une commande avec les privilèges de l'utilisateur `flag03` et récupérer le flag.

> SUID: Set User Id, le bit SUID permet ici d'exécuter un binaire avec les privilèges du propriétaire.

### 2. Analyse de la vulnérabilité
* **Détection du SUID** : Le fichier `level03` possède les paramètres `-rwsr-sr-x`, ce qui indique qu'il exécute avec les privilèges de son propriétaire (`flag03`).
* **Analyse statique** : La commande `strings level03` a révélé l'appel à une commande système sans chemin absolu: `/usr/bin/env echo Exploit me`.
* **Faille de sécurité** : Puisque `/usr/bin/env` cherche l'exécutable `echo` en utilisant la variable d'environnement `$PATH`, il est possible de détourner cette exécution en plaçant un fichier nommé `echo` dans un répertoire prioritaire.

### 3. Méthodologie d'exploitation
* **Création d'un binaire malveillant** : Création d'un script `/tmp/echo` qui exécute la commande de récupération du flag.
* **Détournement du PATH** : Modification de la variable d'environnement pour privilégier le répertoire `tmp`.
* **Exécution** : Lancement du binaire, qui exécute alors `/tmp/echo` avec les droits `flag03` au lieu du `/bin/echo` système.

### 4. Résultat
L'exécution a permis d'obtenir le token avec les privilèges élevés.

Flag: `qi0maab88jeaj46qoumi7maus`