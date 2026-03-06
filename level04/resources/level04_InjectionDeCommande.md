## SnowCrash - Level 04 - Injection de Commande via Perl CGI

### 1. Analyse de l'environnement

Dans le répertoire personnel de `level04`, on trouve un script Perl nommé `level04.pl` avec des permissions particulières :

* **Permissions :** `-rwsr-sr-x` (le bit **SUID** est activé).
* **Propriétaire :** `flag04`.

Le bit SUID signifie que peu importe qui exécute ce script, il sera lancé avec les privilèges de l'utilisateur **flag04**.

### 2. Analyse de la vulnérabilité

Le code source du script `level04.pl` est le suivant :

```perl
use CGI qw{param};
sub x {
  $y = $_[0];
  print `echo $y 2>&1`;
}
x(param("x"));

```

Le script fonctionne ainsi :

1. Il récupère un paramètre CGI nommé `x` (généralement via une requête GET ou POST).
2. Il passe ce paramètre à la fonction `x()`, qui le stocke dans `$y`.
3. Il utilise des **backticks** (```) pour exécuter une commande shell : `echo $y 2>&1`.

**La faille :** La variable `$y` est insérée directement dans la commande shell sans aucun nettoyage (*sanitization*). En Perl, tout ce qui se trouve entre backticks est interprété par le shell du système (`/bin/sh`). Un attaquant peut donc "casser" la commande `echo` pour injecter sa propre commande.

### 3. Méthodologie d'exploitation

Le script indique en commentaire qu'il tourne sur `localhost:4747`. Nous devons envoyer une requête HTTP au script en passant une commande malveillante dans le paramètre `x`.

Pour forcer le shell à exécuter `getflag`, nous utilisons la **substitution de commande** `$()`.

* Si nous envoyons `x=$(getflag)`, le shell exécute d'abord ce qui est entre parenthèses.
* La commande finale vue par le système devient : `echo $(getflag) 2>&1`.
* Le résultat de `getflag` est alors renvoyé par le serveur web.

### 4. Exécution de l'attaque

En utilisant `curl`, on forge la requête HTTP vers le service local :

```bash
level04@SnowCrash:~$ curl 'localhost:4747/level04.pl?x=$(getflag)'

```

**Résultat :**
Le serveur répond avec la sortie de la commande `getflag` exécutée en tant que `flag04` :
`Check flag.Here is your token : ne2searoevaevoem4ov4ar8ap`

### 5. Conclusion et Sécurité

Cette vulnérabilité est une **Injection de Commande**. Pour l'éviter, il ne faut jamais passer de variables utilisateur directement à une fonction qui appelle le shell (comme `system`, `exec` ou les backticks).

En Perl, il est préférable d'utiliser la forme "liste" de `system()` ou `exec()`, qui ne passe pas par le shell et traite les arguments comme de simples chaînes de caractères :
`system("/bin/echo", $y);`

