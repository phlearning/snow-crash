## SnowCrash - Level 02

### 1. Objectif

Récupérer le mot de passe de l'utilisateur `flag02` en analysant une capture réseau (`pcap`) obtenue depuis la machine cible, afin de s'authentifier et d'extraire le token final.

### 2. Méthodologie

* **Récupération des données** : Le fichier a été récupéré via `scp` depuis la machine distante :
`scp -P 4242 level02@192.168.56.102:/home/user/level02/level02.pcap ./log.pcap`
* **Gestion des permissions** : Suite au transfert, le fichier a été rendu lisible par l'utilisateur courant :
`chmod 644 log.pcap`
* **Analyse du flux** :
* Utilisation de la commande `xxd log.pcap` pour examiner le contenu hexadécimal brut.
* Identification d'une session interactive où le mot de passe est transmis caractère par caractère après le prompt `Password:`.


* **Traitement des caractères de contrôle** :
* Détection de la séquence hexadécimale `7f` correspondant au caractère **Backspace (DEL)**.
* Nettoyage manuel des erreurs de frappe (backspaces) pour reconstruire la chaîne réelle.

### 3. Preuve technique (Méthode Wireshark)

Si on fait Follow TCP stream sur Wireshark on a ceci:
```
..%..%..&..... ..#..'..$..&..... ..#..'..$.. .....#.....'........... .38400,38400....#.SodaCan:0....'..DISPLAY.SodaCan:0......xterm.........."........!........"..".....b........b....	B.
..............................1.......!.."......"......!..........."........"..".............	..
.....................
Linux 2.6.38-8-generic-pae (::ffff:10.1.1.2) (pts/10)

..wwwbugs login: l.le.ev.ve.el.lX.X
..
Password: ft_wandr...NDRel.L0L
.
..
Login incorrect
wwwbugs login: 
```

L'utilisation du format hexdump a permis d'inspecter les paquets bruts. Contrairement à l'affichage textuel qui interprète les caractères, l'affichage hexadécimal a révélé la présence explicite du code `7f` (la touche *Backspace*), confirmant les erreurs de frappe de l'utilisateur :

```hex
000000D6  00 0d 0a 50 61 73 73 77  6f 72 64 3a 20            ...Passw ord: 
000000B9  66                                                 f
000000BA  74                                                 t
000000BB  5f                                                 _
000000BC  77                                                 w
000000BD  61                                                 a
000000BE  6e                                                 n
000000BF  64                                                 d
000000C0  72                                                 r
000000C1  7f                                                 .
000000C2  7f                                                 .
000000C3  7f                                                 .
000000C4  4e                                                 N
000000C5  44                                                 D
000000C6  52                                                 R
000000C7  65                                                 e
000000C8  6c                                                 l
000000C9  7f                                                 .
000000CA  4c                                                 L
000000CB  30                                                 0
000000CC  4c                                                 L
000000CD  0d                                                 .
000000E3  00 0d 0a                                           ...
000000E6  01                                                 .
000000E7  00 0d 0a 4c 6f 67 69 6e  20 69 6e 63 6f 72 72 65   ...Login  incorre
000000F7  63 74 0d 0a 77 77 77 62  75 67 73 20 6c 6f 67 69   ct..wwwb ugs logi
00000107  6e 3a 20                                           n: 

...

```

* **`7f`** : Caractère ASCII pour *Backspace*.
* **Nettoyage** : La suppression logique des octets `7f` et des caractères qu'ils effacent a permis de reconstruire le mot de passe valide : `ft_waNDReL0L`.

### 4. Solution

* **Mot de passe identifié** : `ft_waNDReL0L`
* **Commande de validation** :
1. `su flag02`
2. Entrée du mot de passe : `ft_waNDReL0L`
3. `getflag`



### 5. Flag (Token)

`kooda2puivaav1idi4f57q8iq`
