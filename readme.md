# UTILISATION
Recherche sur la gestion de plusieurs webcams en live depuis plusieurs endroits du monde.

# TODO
- tester le rmfp sur Amazon
- tester le stop/start de l'instance EC2
- tester le chargement d'une image d'instance
- tester un vrai fichier air
- tester depuis des servers vraiment distant

# DONE
- tester le rtmp sur amazon avec plusieurs webcam et changement de vidéo alternativement
- créer le compte Amazon

# CONNEXION
1. https://aws.amazon.com/fr/
2. csablons@megalo-company.com
3. orange

# ACTIVER LE MOT DE PASSE VIA PUTTY
1. Lancer Putty
2. À gauche, sélectionner Connection/SSH/Auth
3. À droite, Browse
4. Sélectionner la clé .pem fournie par Amazon lors de la création du keyPair, Putty proposera d'en créer une copie convertie en .ppk
5. À gauche, sélectionner Session
6. À droite,
    - Host Name : le DNS public de l'instance
    - Port : 22
    - Connection type : SSH
7. Open
8. La première fois une popup s'ouvre pour donner un avertissement, choisissez Oui
9. Le login est demandé : amsadmin
10. Saisissez un mot de passe
11. Confirmez le mot de passe

# OBTENIR FTP ACCÈS (recquiert d'avoir 'Activer le mot de passe via Putty')
1. Ouvrir FileZilla
2. Éditions/Paramètres...
3. À gauche, sélectionner Connexion/SFTP
4. À droite, Ajouter une clé privée...
5. Sélectionner la clé .pem fournie par Amazon lors de la création du keyPair, FileZilla proposera d'en créer une copie convertie en .ppk
6. Fermer ensuite la fenêtre de Paramètres...
7. Fichier/Gestionnaire de Sites
8. Nouveau site
9. À droite, 
    - Hôte : le DNS public de l'instance
    - Port : 22
    - Protocole : SFTP - SSH File Transfer Protocol
    - Type d'authentification : Normale
    - Identifiant : amsadmin
    - Mot de passe : Le mot de passe que vous avez défini dans Putty
10. Connexion et là c'est bon

# REDÉMARRER ADOBE MEDIA SERVER (recquiert d'avoir 'Activer le mot de passe via Putty')
- http://help.adobe.com/en_US/adobemediaserver/install/WS5b3ccc516d4fbf351e63e3d119ed5bf6c6-7fedInstallConfigure.2.3.html
1. Se connecter via putty
2. Se déplacer dans '/opt/adobe/ams'
3. sudo ./server restart (pour redémarrer le serveur AMS)
3. sudo ./adminserver restart (pour redémarrer l'administrateur d'utilisateur)

# UTILS
Tarifs des servers (cliquer sur "Manual Launch") les tarifs seront à droite :
- https://aws.amazon.com/marketplace/ordering/ref=dtl_psb_continue?ie=UTF8&productId=978a7296-c806-4f52-9a7e-5a0d5a0b1166&region=eu-west-1