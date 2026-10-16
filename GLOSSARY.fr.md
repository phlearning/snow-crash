# Glossaire

🇬🇧 [English version](GLOSSARY.md) · [Retour au README](README.fr.md)

Les termes techniques sont volontairement conservés en anglais.

| Terme | Définition |
|-------|------------|
| **Anti-debug** | Techniques utilisées par un programme pour détecter et refuser l'analyse (ex. `ptrace(PTRACE_TRACEME)`). |
| **CGI** | Common Gateway Interface : permet à un serveur web d'exécuter un script pour répondre à une requête. |
| **Command injection** | Faire exécuter à un programme des commandes shell choisies par l'attaquant via une entrée non assainie. |
| **Cron job** | Tâche planifiée exécutée périodiquement par le système. |
| **CyberChef** | Outil web d'encodage, décodage et opérations cryptographiques. |
| **EAX** | Registre x86 contenant la valeur de retour d'une fonction. |
| **`getflag`** | Binaire qui affiche le token de l'utilisateur `flagXX` courant. |
| **GDB** | Debugger GNU, utilisé pour inspecter et modifier un programme à l'exécution. |
| **Globbing** | Expansion des jokers du shell (`*`, `?`), utile pour contourner des filtres de caractères. |
| **John the Ripper** | Outil de cassage de mots de passe. |
| **`ltrace`** | Trace les appels de bibliothèque d'un programme (ex. `getenv`, `system`). |
| **`LD_PRELOAD`** | Variable d'environnement pour charger une bibliothèque en premier ; ignorée pour les binaires SUID. |
| **`PATH` hijacking** | Placer un faux exécutable dans un répertoire cherché en premier par `$PATH`. |
| **`ptrace`** | Appel système utilisé par les debuggers ; aussi utilisé par les programmes pour les détecter. |
| **Race condition** | Bug dont le résultat dépend du timing entre des opérations concurrentes. |
| **ROT13 / chiffre de César** | Chiffrement par substitution simple qui décale les lettres d'une valeur fixe. |
| **SUID** | Bit Set User ID : le binaire s'exécute avec les privilèges de son propriétaire. |
| **Symlink** | Lien symbolique : fichier qui pointe vers un autre chemin. |
| **`strings`** | Affiche les chaînes imprimables trouvées dans un binaire. |
| **TOCTOU** | Time-Of-Check to Time-Of-Use : course entre une vérification et l'utilisation d'une ressource. |
| **Token** | Ici, la valeur renvoyée par `getflag`, utilisée comme mot de passe du niveau suivant. |
| **Wireshark / pcap** | Analyseur réseau et son format de fichier de capture de paquets. |
