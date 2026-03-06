## SnowCrash - Level 08 - Contournement de restriction par Lien Symbolique (Symlink)

### 1. Analyse de l'existant

Dans le répertoire personnel de `level08`, on trouve :

* **`level08`** : Un binaire avec le bit **SUID** (propriétaire `flag08`).
* **`token`** : Un fichier appartenant à `flag08`. Il est illisible pour notre utilisateur actuel, mais contient probablement une information clé.

### 2. Étude du binaire

En testant le binaire, on remarque qu'il attend un nom de fichier en argument pour en afficher le contenu. Cependant, il refuse d'ouvrir le fichier s'il s'appelle "token" :

```bash
level08@SnowCrash:~$ ./level08 token
You may not access 'token'

```

L'utilisation de `ltrace` révèle le mécanisme de protection :
`strstr("token", "token") = "token"`

Le programme utilise la fonction `strstr` pour vérifier si la chaîne de caractères **"token"** est présente dans le nom du fichier passé en argument. Si c'est le cas, il bloque l'accès par mesure de "sécurité".

### 3. La faille

La faille réside dans le fait que le programme valide le **nom du chemin** (le texte de l'argument) plutôt que l'objet réel (l'**inode**) sur le disque.

Puisque le binaire possède le bit SUID `flag08`, il a techniquement les droits de lecture sur le fichier `/home/user/level08/token`. Il suffit donc de lui présenter ce même fichier sous un nom qui ne contient pas le mot "token".

### 4. Stratégie d'exploitation

On utilise un **lien symbolique** (`symlink`), qui agit comme un alias vers le fichier original.

1. **Création du lien :** On crée un lien nommé `pwn` dans `/tmp` qui pointe vers le fichier `token`.
```bash
level08@SnowCrash:~$ ln -s /home/user/level08/token /tmp/pwn

```


2. **Exécution :** On passe ce lien au binaire.
```bash
level08@SnowCrash:~$ ./level08 /tmp/pwn
quif5eloekouj29ke0vouxean

```



**Pourquoi ça marche ?**

* `strstr("/tmp/pwn", "token")` retourne `NULL`, donc la condition de sécurité est remplie.
* Le binaire ouvre `/tmp/pwn`, le système suit le lien vers le fichier `token`.
* Le binaire s'exécutant avec les privilèges de `flag08`, il parvient à lire et afficher le contenu.

### 5. Obtention du Flag

Le texte récupéré (`quif5eloekouj29ke0vouxean`) n'est pas le flag, mais le **mot de passe** de l'utilisateur `flag08`.

1. **Changement d'utilisateur :**
```bash
level08@SnowCrash:~$ su flag08
Password: [quif5eloekouj29ke0vouxean]

```


2. **Récupération du token final :**
```bash
flag08@SnowCrash:~$ getflag
Check flag.Here is your token : 25749xKZ8L7DkSCwJkT9dyv6f

```



### 6. Conclusion et Sécurité

Cette vulnérabilité montre qu'une liste noire (blacklist) basée sur des noms de fichiers est inefficace.

**Mesures de prévention :**

* **Vérification des droits réels :** Utiliser la fonction `access()` pour vérifier si l'utilisateur réel (et non effectif) a le droit de lire le fichier.
* **Utilisation d'UID/GID :** Ne pas se fier aux entrées utilisateur pour la sécurité, mais vérifier les métadonnées des fichiers ou les permissions système.
