# Snow Crash - Level 00

## 🎯 Objectif

Passer de l'utilisateur `level00` à `flag00` afin de récupérer le premier jeton (token) d'authentification.

## 🔍 Découverte

1. **Environnement restreint :** Le répertoire personnel (`home`) de `level00` ne contenait aucun fichier visible et les permissions pour la commande `ls` étaient restreintes.
2. **Recherche système :** Une recherche récursive de tous les fichiers appartenant à l'utilisateur cible `flag00` a été effectuée :
```bash
find / -user flag00 2>/dev/null

```


3. **Fichiers suspects :** La recherche a révélé deux fichiers identiques :
* `/usr/sbin/john`
* `/rofs/usr/sbin/john`


4. **Contenu obfusqué :** L'exécution de `cat /usr/sbin/john` a révélé le texte chiffré suivant :
> `cdiiddwpgswtgt`



## 🛠️ Décodage (Méthode CyberChef)
![solve](cyberchef-rot13.png)
Le texte semblait être un simple algorithme de substitution (César). Pour le résoudre :

* **Outil :** [CyberChef](https://gchq.github.io/CyberChef/)
* **Recette :** `ROT13 Brute Force`
* **Input :** `cdiiddwpgswtgt`
* **Résultat :** Avec un décalage (shift) de **11**, le texte devient lisible : **`nottoohardhere`**.

## 🚩 Capture du Flag

1. **Changement d'utilisateur :** Utilisation du mot de passe décodé pour devenir l'utilisateur `flag00`.
```bash
su flag00
# Entrer le mot de passe : nottoohardhere

```


2. **Récupération du Flag :** Exécution de l'utilitaire interne pour générer le token du niveau suivant.
```bash
flag00@SnowCrash:~$ getflag
Check flag.Here is your token : x24ti5gi3x0ol2eh4esiuxias

```
