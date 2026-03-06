## SnowCrash - Level 07 - Injection via Variable d'Environnement

### 1. Analyse des fichiers

Dans ce niveau, nous avons un binaire nommé `level07` avec les caractéristiques suivantes :

* **Permissions :** `-rwsr-sr-x` (Bit **SUID** activé).
* **Propriétaire :** `flag07`.
* **Comportement :** Lorsqu'on l'exécute, il affiche simplement "level07" (le nom de l'utilisateur courant, semble-t-il).

### 2. Découverte de la vulnérabilité

En l'absence de code source, l'utilisation de `ltrace` est cruciale pour comprendre comment le programme interagit avec le système :

```bash
level07@SnowCrash:~$ ltrace ./level07
getenv("LOGNAME")                                                                                                                                                                  = "level07"
asprintf(0xbffff754, 0x8048688, 0xbfffff57, 0xb7e5ee55, 0xb7fed280)                                                                                                                = 18
system("/bin/echo level07 "level07
 <unfinished ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                                                                                                                                             = 0

```

**Analyse des appels :**

1. Le programme récupère la valeur de la variable d'environnement **`LOGNAME`**.
2. Il prépare une chaîne de caractères via `asprintf` en utilisant un format non sécurisé : `/bin/echo %s`.
3. Il passe cette chaîne à la fonction **`system()`**.

**La faille :** La fonction `system()` lance un shell (`/bin/sh`) pour exécuter la commande. Si nous modifions le contenu de `LOGNAME` pour y inclure des métacaractères du shell (comme `;`, `&&`, ou `||`), nous pouvons injecter une seconde commande qui sera exécutée avec les droits du propriétaire du binaire (`flag07`).

### 3. Stratégie d'exploitation

L'idée est de redéfinir `LOGNAME` pour qu'elle contienne non pas un nom d'utilisateur, mais une commande malveillante.

Si nous définissons `LOGNAME` comme `; getflag`, la commande finale exécutée par le système sera :
`/bin/echo ; getflag`

Le shell interprétera cela comme deux commandes distinctes :

1. `/bin/echo` (qui n'affiche rien).
2. `getflag` (qui sera exécuté par l'utilisateur effectif du binaire, soit `flag07`).

### 4. Mise en œuvre

```bash
# 1. Modification de la variable d'environnement
level07@SnowCrash:~$ export LOGNAME="; getflag"

# 2. Exécution du binaire SUID
level07@SnowCrash:~$ ./level07

```

**Résultat :**
Le binaire s'exécute, le shell interprète le point-virgule et lance `getflag` :
`Check flag.Here is your token : fiumuikeil55xe9cu4dood66h`

### 5. Conclusion et Sécurité

Ce niveau illustre une vulnérabilité d'**Injection de Commande** indirecte. Le programmeur a fait confiance à une source de données externe (une variable d'environnement) pour construire une commande système.

**Mesures de prévention :**

* **Éviter `system()` :** Utiliser des fonctions de la famille `exec()` (comme `execve`) qui ne font pas appel au shell et traitent les arguments comme des données pures, pas comme du code.
* **Sanitisation :** Si `system()` doit être utilisé, il est impératif de nettoyer la variable d'entrée pour supprimer tout métacaractère shell.
* **Principe de méfiance :** Ne jamais faire confiance aux variables d'environnement (`PATH`, `LOGNAME`, `LD_PRELOAD`, etc.) dans un programme SUID.
