# Snow Crash

> 🇬🇧 [English version](README.md) · 📖 [Glossaire](GLOSSARY.fr.md)

Introduction à la sécurité Linux du cursus 42. On dispose d'une VM (l'ISO `SnowCrash`) et on démarre en tant que `level00`. Chaque niveau contient une faiblesse permettant de devenir `flagXX`, d'exécuter `getflag` et d'obtenir le token qui sert de mot de passe à l'utilisateur `levelXX` suivant. Il y a **15 niveaux** (00 à 14).

> ⚠️ **Attention spoilers :** chaque write-up `levelXX/resources/levelXX.md` contient le token et la solution complète.

## Installation

```bash
./vm.sh   # télécharge l'ISO, crée et configure la VM (SSH sur le port 4242)
```

Puis connexion à un niveau (la commande exacte de chacun est dans `levelXX/resources/connect.md`) :

```bash
ssh -p 4242 levelXX@<ip-vm>
```

## Structure du dépôt

```
levelXX/
├── flag          # token du niveau suivant
└── resources/
    ├── levelXX.md    # write-up
    └── connect.md    # infos de connexion
```

## Niveaux

| Niveau | Vulnérabilité | Technique |
|--------|---------------|-----------|
| 00 | Chiffrement faible | Trouver un fichier appartenant à `flag00` avec `find` ; chiffre ROT cassé avec CyberChef (ROT13 brute force) |
| 01 | Hash de mot de passe dans `/etc/passwd` | Casser le hash DES legacy avec John the Ripper |
| 02 | Identifiants en clair dans une capture réseau | Lire un `.pcap` (Wireshark / `xxd`) et reconstruire le mot de passe en gérant les caractères backspace |
| 03 | Binaire SUID appelant une commande sans chemin absolu | `PATH` hijacking avec un faux `echo` dans `/tmp` |
| 04 | Command injection dans un script Perl CGI | Injecter une commande shell via le paramètre `x` (backticks) |
| 05 | Répertoire inscriptible exécuté par un cron job | Déposer un script dans `/opt/openarenaserver/`, exécuté par `flag05` toutes les 2 minutes |
| 06 | `preg_replace` avec le modificateur `/e` (PHP) | Exécution de code via `[x ${`getflag`}]` |
| 07 | Binaire SUID qui fait confiance à une variable d'environnement | Injecter une commande via `LOGNAME` (trouvé avec `ltrace`) |
| 08 | Contrôle d'accès basé sur le nom du fichier | Contourner la vérification `token` avec un lien symbolique |
| 09 | Algorithme d'obfuscation faible | Inverser l'algorithme "ajouter l'index à chaque octet" pour décoder le fichier `token` |
| 10 | Race condition (TOCTOU) | Échanger un symlink entre `access()` et `open()` pendant qu'un listener sur le port 6969 reçoit le fichier |
| 11 | Command injection dans un serveur Lua | `io.popen("echo "..pass.." \| sha1sum")` exploité via netcat sur le port 5151 |
| 12 | Command injection dans un script Perl CGI (port 4646) | Contourner la mise en majuscules et le filtrage des espaces avec un script et du shell globbing |
| 13 | Vérification d'UID dans un binaire SUID | Falsifier la valeur de retour de `getuid()` (registre `EAX`) dans GDB |
| 14 | Protections anti-debug dans `getflag` | Contourner le check `ptrace` et la vérification d'UID dans GDB pour obtenir le token de `flag14` |

## Outils utilisés

`find`, `strings`, `ltrace`, `gdb`, `scp`, `nc` (netcat), `curl`, John the Ripper, Wireshark, CyberChef.

## Enseignements clés

- Toujours utiliser des chemins absolus et assainir les variables d'environnement dans les programmes privilégiés.
- Ne jamais construire une commande shell en concaténant une entrée utilisateur.
- Ne pas compter sur l'obscurité ou des chiffrements faibles pour protéger des secrets.
- Vérifier les permissions des fichiers et répertoires lus ou exécutés par des jobs privilégiés.
- Éviter les schémas check-then-use sur le filesystem (`access()` puis `open()`).
