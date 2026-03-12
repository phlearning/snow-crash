# Snow Crash - Level 01

## 🎯 Objective

Exploiter une vulnérabilité dans la gestion des mots de passe système pour obtenir les privilèges de l'utilisateur `flag01`.

## 🔍 Discovery

1. **Inspection du fichier des mots de passe :** Sous Linux, `/etc/passwd` contient normalement les informations des utilisateurs. Sur ce système, le hash du mot de passe de `flag01` y est directement exposé au lieu d'être caché dans `/etc/shadow`.
```bash
cat /etc/passwd | grep flag01

```


2. **Extraction du Hash :** * **Entrée trouvée :** `flag01:42hDRfypTqqnw:3001:3001::/home/flag/flag01:/bin/bash`
* **Hash identifié :** `42hDRfypTqqnw` (Format DES/crypt).



## 🛠️ Cracking (John the Ripper)

Pour retrouver le mot de passe en clair, nous utilisons une attaque par force brute ou par dictionnaire sur le hash extrait.

1. **Préparation :** Créer un fichier local contenant le hash.
```bash
echo "flag01:42hDRfypTqqnw" > /tmp/hash01

```


2. **Attaque :** Utilisation de l'outil **John the Ripper**.
```bash
john /tmp/hash01

```


3. **Résultat :** Le hash est cassé instantanément.
* **Password :** `abcdefg`



## 🚩 Capture

1. **Changement d'utilisateur :**
```bash
su flag01
# Password: abcdefg

```


2. **Récupération du Token :**
```bash
getflag

```


> **Token :** `f2av5il02puano7naaf6adaaf`
