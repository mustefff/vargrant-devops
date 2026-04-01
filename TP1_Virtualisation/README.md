# TP1 - Virtualisation et Serveur Web

Ce projet correspond au premier travail pratique. L'objectif est de maitriser les concepts de base de la virtualisation avec Vagrant et QEMU, en deployant de maniere automatisee un serveur Web Java (Tomcat 9) tournant sous Ubuntu 22.04 LTS.

## Structure du projet

```text
TP1_Virtualisation/
├── Vagrantfile            # Fichier de configuration definissant les caracteristiques de la VM srv-web
├── provision.sh           # Script d'automatisation executant l'installation des JDKs et de Tomcat
├── deploy.sh              # Interface interactive pour la gestion du serveur Tomcat (service, logs, deploiments)
└── app/                   # Repertoire partage hote-invite contenant l'application de demonstration (monapp.war)
```

## Description de l'Architecture

L'environnement se base sur une architecture serveur isolee :

1. **srv-web** : Une unique machine virtuelle configuree sous Ubuntu. 
   - Elle embarque trois versions de Java (JDK 8, 11 et 17).
   - Elle heberge le service Apache Tomcat 9.
   - Le port 8080 du serveur Web Tomcat est redirige (Port Forwarding) vers le port 8080 de l'hote.

## Etapes de deploiement et de lancement

### 1. Demarrage de l'environnement

Ouvrez un terminal, placez-vous dans le dossier `TP1_Virtualisation` et executez la commande suivante :

```bash
cd TP1_Virtualisation
vagrant up
```

Le processus est entierement decrit par le `Vagrantfile`. Vagrant va cloner l'image du systeme d'exploitation, configurer le reseau, puis lancer automatiquement `provision.sh` qui installera tous les paquets requis.

### 2. Validation de l'installation

Afin de valider la reussite complete du TP1, veuillez executer les commandes ci-dessous pour realiser les captures d'ecran demandees.

---

### [CAPTURE_ECRAN_1 : vagrant up et status]

**Commande a taper sur votre machine (Hote) :**
```bash
vagrant status
```

*Justification du resultat attendu : L'affichage doit indiquer que la machine "srv-web" est a l'etat "running". Cette capture prouve que le processus initial de creation de la VM (le vagrant up) et le provisioning systeme (installation logicielle) se sont deroules sans erreur et que la machine est active.*

---

### [CAPTURE_ECRAN_2 : Menu deploy.sh - Option 7]

**Commandes a taper sur votre machine (Hote) :**
```bash
# 1. Se connecter en SSH a la machine
vagrant ssh

# 2. Lancer le script de gestion Tomcat en sudo
sudo ~/deploy.sh

# 3. Dans le menu interactif qui s'affiche, tapez le chiffre 7 et faites Entree.
```

*Justification du resultat attendu : La selection de l'option 7 execute un scan du systeme validant l'installation simultanee de trois kits de developpement Java (JDK 8, 11 et 17), prouvant ainsi la bonne execution des etapes de "provision.sh". Cela demontre la flexibilite de l'environnement serveur virtalise pour accueillir de multiples systemes applicatifs.*

**Pour sortir du script et de la machine (Commandes a taper ensuite) :**
```bash
# Appuyez sur Entree pour revenir au menu
# Tapez 0 pour quitter l'outil Tomcat
exit
```

---

### [CAPTURE_ECRAN_3 : Acces Navigateur monapp]

**Action a faire sur votre machine (Hote) :**
Ouvrez votre navigateur web et allez a l'adresse suivante :
```text
http://localhost:8080/monapp
```
*(Attention, Tomcat demande quelques secondes apres le provisionnement pour s'initialiser totalement. Si le lien ne repond pas de suite, rafraichissez la page).*

*Justification du resultat attendu : L'affichage correct de l'application de demonstration confirme que le port 8080 de la machine virtuelle est fonctionnellement relie a l'hote via le port forwarding QEMU, que le service Tomcat 9 tourne activement, et que le repertoire partage "app/" a ete synchronise correctement, permettant le deploiment de "monapp.war".*

---

## Arret et nettoyage

**Pour arreter la machine virtuelle une fois les tests termines :**
```bash
vagrant halt
```

**Pour la detruire totalement et liberer votre disque :**
```bash
vagrant destroy -f
```
