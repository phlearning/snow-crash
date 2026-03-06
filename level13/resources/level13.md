## SnowCrash - Level 13 - Usurpation d'identité via GDB (Registre EAX)

### 1. Analyse de l'existant

Au lancement de l'exécutable `./level13`, le programme nous informe qu'il attend un UID spécifique pour nous délivrer le token.

```bash
level13@SnowCrash:~$ ./level13 
UID 2013 started us but we we expect 4242

```

Notre UID actuel est **2013**, alors que le binaire exige l'UID **4242**. Le binaire possédant le bit **setuid** (STID), une attaque via `LD_PRELOAD` est impossible car l'éditeur de liens dynamique (`ld.so`) ignore cette variable d'environnement pour les binaires privilégiés afin d'éviter l'escalade de privilèges.

### 2. Analyse de la logique binaire

L'utilisation de `gdb` permet d'analyser le code assembleur de la fonction `main` :

```gdb
0x08048595 <+9>:   call   0x8048380 <getuid@plt>
0x0804859a <+14>:  cmp    $0x1092,%eax        ; 0x1092 correspond à 4242
0x0804859f <+19>:  je     0x80485cb <main+63> ; Saut vers ft_des si égal

```

**Points critiques :**

* **Appel Système :** Le programme utilise `getuid()` pour récupérer l'identifiant de l'utilisateur.
* **Registre EAX :** Selon les conventions d'appel x86, la valeur de retour de `getuid()` est stockée dans le registre `%eax`.
* **Vérification :** Le programme compare `%eax` à `0x1092` (4242). Si la condition n'est pas remplie, il affiche un message d'erreur et quitte via `exit()`.
* **Obfuscation :** Si l'UID est correct, il appelle une fonction `ft_des` qui déchiffre une chaîne de caractères codée en dur pour afficher le flag.

### 3. Stratégie d'exploitation

Puisque nous ne pouvons pas modifier notre UID réel, nous allons manipuler la mémoire du processeur en temps réel pendant l'exécution. L'objectif est de laisser `getuid()` s'exécuter normalement, puis d'intercepter le programme juste avant la comparaison pour forcer la valeur `4242` dans le registre `%eax`.

Nous utilisons GDB en mode "batch" pour automatiser cette manipulation sans interaction manuelle.

### 4. Commandes exécutées

#### L'Injection via GDB

Nous utilisons une suite d'instructions pour modifier le flux d'exécution :

1. **`break getuid`** : On s'arrête à l'appel de la fonction.
2. **`finish`** : On laisse la fonction se terminer pour revenir dans le `main`.
3. **`set $eax=4242`** : On écrase manuellement notre véritable UID par celui attendu.
4. **`continue`** : On reprend l'exécution.

```bash
level13@SnowCrash:~$ gdb -batch -ex "break getuid" -ex "run" -ex "finish" -ex "set \$eax=4242" -ex "continue" ./level13

```

#### Résultat de l'exécution

```text
Breakpoint 1, 0xb7ee4cc0 in getuid () from /lib/i386-linux-gnu/libc.so.6
Run till exit from #0  0xb7ee4cc0 in getuid () from /lib/i386-linux-gnu/libc.so.6
0x0804859a in main ()
your token is 2A31L79asukciNyi8uppkEuSx
[Inferior 1 (process 12951) exited with code 050]

```

### 5. Conclusion et Sécurité

Ce niveau démontre que les vérifications basées sur des fonctions système standards (comme `getuid`) peuvent être contournées si un attaquant possède les droits de débogage sur le processus.

**Measures de prévention :**

* **Anti-Debugging :** Utiliser des mécanismes comme `ptrace(PTRACE_TRACEME, ...)` pour empêcher un debugger de s'attacher au processus.
* **Obfuscation de flux :** Éviter les comparaisons directes et triviales (`cmp $0x1092, %eax`) pour des vérifications de sécurité critiques.
* **Vérifications côté noyau :** Pour des privilèges réels, s'appuyer sur les permissions natives du système de fichiers plutôt que sur une vérification logique interne au code utilisateur.

**Token :** `2A31L79asukciNyi8uppkEuSx`
