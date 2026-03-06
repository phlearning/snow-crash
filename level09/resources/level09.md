## SnowCrash - Level 09 - Rétro-ingénierie d'un algorithme d'obfuscation

### 1. Analyse de l'environnement

Dans le répertoire personnel de `level09`, nous trouvons deux fichiers :

* **`level09`** : Un binaire avec le bit **SUID** (propriétaire `flag09`).
* **`token`** : Un fichier contenant une chaîne de caractères obfusquée. Contrairement au niveau précédent, ce fichier est lisible par notre utilisateur.

### 2. Étude du comportement du binaire

En testant le binaire avec des entrées simples, on identifie rapidement une transformation de type "décalage par index" :

```bash
level09@SnowCrash:~$ ./level09 aaaaa
abcde
level09@SnowCrash:~$ ./level09 00000
01234

```

**L'algorithme identifié :**
Pour chaque caractère à la position $i$ dans la chaîne, le programme ajoute la valeur de l'index $i$ à sa valeur ASCII :
$Output[i] = Input[i] + i$

### 3. Obstacles à l'analyse

* **Anti-Reverse :** Une tentative d'analyse avec `ltrace` échoue car le binaire utilise `ptrace` pour détecter s'il est surveillé. S'il détecte un traçage, il s'arrête avec le message : *"You should not reverse this"*.
* **Caractères non-imprimables :** Le fichier `token` contient des caractères dont la valeur ASCII dépasse 127 suite au décalage. Une commande `cat` affiche donc des symboles étranges car le terminal ne peut pas les interpréter graphiquement.

### 4. Stratégie d'exploitation

Le fichier `token` est le résultat de cet algorithme appliqué au mot de passe de `flag09`. Pour retrouver le texte original, il faut inverser l'opération :
$Original[i] = Token[i] - i$

Nous utilisons un script Python pour manipuler les valeurs numériques des octets sans nous soucier de leur affichage.

### 5. Script de décodage (Version longue)

```python
# 1. Lecture du contenu brut du fichier token
# On utilise .strip() pour enlever le saut de ligne final potentiel
content = open('/home/user/level09/token', 'r').read().strip()

res = ""

# 2. Boucle sur chaque caractère de la chaîne
for i in range(len(content)):
    # ord(c) récupère la valeur ASCII (ex: 'b' -> 98)
    # On soustrait l'index i (ex: 98 - 1 = 97)
    # chr() transforme la valeur résultante en caractère (ex: 97 -> 'a')
    res += chr(ord(content[i]) - i)

# 3. Affichage du mot de passe décodé
print(res)

```

### 6. Obtention du Flag

1. **Exécution du script :** Le décodage nous donne le mot de passe : `f3iji1ju5yuevaus41q1afiuq`.
2. **Changement d'utilisateur :**
```bash
level09@SnowCrash:~$ su flag09
Password: [f3iji1ju5yuevaus41q1afiuq]

```


3. **Récupération du token final :**
```bash
flag09@SnowCrash:~$ getflag
Check flag.Here is your token : s5cAJpM8ev6XHw998pRWG728z

```



### 7. Conclusion

* **Obfuscation vs Chiffrement :** L'algorithme utilisé ici n'est pas du chiffrement (car il ne repose sur aucune clé secrète), mais de l'**obfuscation**. La sécurité d'un tel système repose uniquement sur la méconnaissance de l'algorithme par l'attaquant. Une fois le motif découvert (ici, le décalage par index), la protection devient nulle.
* **Protections Anti-Analyse (Anti-Debugging) :** L'utilisation de `ptrace` montre comment un développeur peut tenter d'empêcher l'utilisation d'outils d'analyse dynamique comme `ltrace` ou `gdb`. C'est une technique courante dans les malwares pour ralentir les analystes de sécurité.
* **Manipulation de Données Binaires :** Le challenge souligne l'importance de savoir manipuler les flux de données au niveau des **octets** (bytes). L'utilisation d'outils textuels classiques (`cat`, `strings`) est limitée par l'encodage du terminal, tandis qu'un script (Python/C) permet de traiter la donnée brute de manière fiable.

**En résumé :** La réussite de ce niveau repose sur la capacité à observer un comportement récurrent, à ignorer les protections de surface pour comprendre la logique sous-jacente, et à automatiser le processus de "dé-obfuscation" par le code.

