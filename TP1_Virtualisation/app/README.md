# srv-web — Application Web Java (dossier partagé)

Ce dossier est **partagé** entre votre machine hôte et la VM Vagrant (`srv-web`).

## Comment déployer votre propre application

1. Placez votre fichier `.war` dans ce dossier (`srv-web/app/`)
2. Dans la VM (`vagrant ssh`), lancez `sudo ~/deploy.sh`
3. Choisissez l'option **5) Déployer une application WAR**

L'application sera automatiquement copiée dans `/opt/tomcat9/webapps/` et Tomcat sera redémarré.

## Accès

- Accès au dossier dans la VM : `/vagrant_app/`
