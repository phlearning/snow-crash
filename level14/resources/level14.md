## SnowCrash - Level 14 - Reverse Engineering et Contournement d'Anti-Debug

### 1. Analyse de l'existant

Pour ce dernier niveau, aucun fichier n'est présent dans le répertoire personnel. L'objectif est d'extraire le token final en analysant le binaire `/bin/getflag`. Ce programme est chargé de distribuer les tokens de tous les niveaux en vérifiant l'UID de l'appelant.

### 2. Analyse des protections

Le binaire `getflag` est protégé par plusieurs mécanismes sophistiqués pour empêcher l'analyse et la manipulation :

* **Anti-Debug (ptrace) :** Le programme utilise `ptrace` (PTRACE_TRACEME) pour détecter si un debugger est attaché. Si c'est le cas, il affiche `"You should not reverse this"` et s'arrête.
* **Vérification de l'UID :** Il appelle `getuid()` et compare le résultat à une liste d'UID codés en dur dans une structure de type `switch`.
* **Anti-Tampering :** Il surveille les cartes mémoire (`/proc/self/maps`) pour détecter l'injection de bibliothèques via `LD_PRELOAD`.
* **Canaris (Stack Cookies) :** Une protection contre le dépassement de pile déclenche un `stack smashing detected` en cas de corruption du flux d'exécution.

### 3. Stratégie d'exploitation

L'analyse de l'assembleur (`disas main`) nous indique que l'UID correspondant à **flag14** est **3014** (`0xbc6`).

Pour contourner toutes les protections d'un coup, nous utilisons **GDB** pour réaliser un "hold-up" sur le flux d'exécution. L'idée est de :

1. Interrompre le programme au tout début (`main`).
2. Injecter manuellement l'UID cible dans le registre `%eax`.
3. Forcer un saut (`jump`) par-dessus les fonctions d'initialisation et de sécurité, directement au moment où le programme traite l'UID.

L'adresse cible pour le saut est **`0x08048b02`**, située juste après l'appel à `getuid`.

### 4. Commandes exécutées

Nous utilisons GDB en mode batch pour automatiser l'injection :

```bash
level14@SnowCrash:~$ gdb -batch \
     -ex "break main" \
     -ex "run" \
     -ex "set \$eax=3014" \
     -ex "jump *0x08048b02" \
     /bin/getflag

```

**Détails de l'injection :**

* **`set $eax=3014`** : On simule le fait que `getuid()` a renvoyé l'UID de flag14.
* **`jump *0x08048b02`** : On déplace le pointeur d'instruction après les vérifications `ptrace` et `LD_PRELOAD`.

### 5. Résultat

Le programme court-circuite ses propres sécurités, déchiffre le token via sa fonction interne `ft_des` et l'affiche avant que le mécanisme de protection de la pile ne finisse par tuer le processus.

```text
7QiHafiNa3HVozsaXkawuYrTstxbpABHD8CPnHJ
*** stack smashing detected ***: /bin/getflag terminated

```

**Token final :** `7QiHafiNa3HVozsaXkawuYrTstxbpABHD8CPnHJ`

### 6. Conclusion et Sécurité

Ce niveau ultime combine plusieurs concepts de **Reverse Engineering**. Il démontre que même avec des protections anti-debug et d'intégrité, un attaquant ayant le contrôle de l'environnement d'exécution (le debugger) peut manipuler les registres et le pointeur d'instruction pour forcer le programme à révéler ses secrets.

**Mesures de prévention :**

* **Obfuscation de code :** Rendre la logique de déchiffrement beaucoup plus difficile à isoler.
* **Chiffrement statique :** Ne pas stocker tous les tokens dans un seul binaire universel.
* **Vérification croisée :** Utiliser des vérifications de sécurité dispersées tout au long de l'exécution plutôt qu'uniquement au début.
