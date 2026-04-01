# TP3 - Deploiement d'une Architecture 3-Tiers avec Vagrant

Ce projet consiste a deployer une architecture 3-Tiers complete (Frontend, Backend, et Base de donnees) de maniere automatisee en utilisant Vagrant et QEMU sur des machines virtuelles distantes.

## Structure du projet

```text
TP3_Trois_Tiers/
├── Vagrantfile            # Configuration des trois machines virtuelles
├── dba_provision.sh       # Script d'installation de la base de donnees (MySQL)
├── back_provision.sh      # Script d'installation de l'API (Java/Spring Boot)
├── front_provision.sh     # Script d'installation de l'interface (React/Nginx)
├── backend/               # Code source de l'application Spring Boot (Maven)
└── frontend/              # Code source de l'application React
```

## Description de l'Architecture

L'environnement met en place trois machines Ubuntu :

1. **server-dba** : Heberge le serveur MySQL. La base de donnees `tp3_db` est creee et configuree. Port redirige vers l'hote : 3307.
2. **server-back** : Heberge l'API REST developpee en Spring Boot (Java 17). Elle se connecte au serveur `server-dba` pour lire et ecrire des donnees. L'application tourne sur le port 8080. Port redirige vers l'hote : 8081.
3. **server-front** : Heberge l'interface utilisateur React buildée, et servie par un serveur web Nginx qui agit egalement comme un *Reverse Proxy* pour router les requetes vers le Backend. Port redirige vers l'hote : 8082.

## Etapes de deploiement et de lancement

### 1. Demarrage de l'environnement

Assurez-vous d'avoir installe Vagrant et le plugin `vagrant-qemu` (necessaire pour l'architecture ARM, comme les Mac Apple Silicon).

Ouvrez un terminal, placez-vous dans le dossier `TP3_Trois_Tiers` et lancez la commande suivante :

```bash
cd TP3_Trois_Tiers
vagrant up
```

L'installation est entierement automatisee par le Vagrantfile.
- Vagrant cree d'abord **server-dba** et installe MySQL.
- Ensuite, Vagrant cree **server-back**, installe Java JDK 17, recupere les sources Spring Boot, les compile avec Maven et lance un service systemd.
- Enfin, Vagrant cree **server-front**, installe Node.js et Nginx, compile le projet React, et le deploie sur Nginx.

### 2. Validation de l'installation

Une fois l'execution terminee, voici les commandes exactes que vous devez taper dans votre terminal pour effectuer les verifications et realiser les captures d'ecran.

---

### [CAPTURE_ECRAN_1 : vagrant status]

**Commande a taper sur votre machine (Hote) :**
```bash
vagrant status
```

*Justification du resultat attendu : Cette capture montre les trois machines virtuelles "server-dba", "server-back" et "server-front" a l'etat "running". Cela prouve que le deploiement global des machines via QEMU s'est effectue sans erreurs critiques et que les ressources sont allouees.*

---

### [CAPTURE_ECRAN_2 : Connexion MySQL sur server-dba]

**Commandes a taper sur votre machine (Hote) :**
```bash
# 1. Se connecter en SSH a la machine dba
vagrant ssh server-dba

# 2. Une fois dans la machine, taper la commande de connexion MySQL :
mysql -u tp3_user -pTp3Pass123! tp3_db

# 3. Verifier la donnee dans la table :
SELECT * FROM messages;

# 4. Quitter MySQL et la VM
exit
exit
```

*Justification du resultat attendu : Les commandes ci-dessus prouvent que l'utilisateur MySQL est bien configure, que la base "tp3_db" est operationnelle, et que la table a ete correctement initialisee.*

---

### [CAPTURE_ECRAN_3 : Test de l'API Backend via curl]

**Commande a taper sur votre machine (Hote) :**
```bash
curl -s http://localhost:8081/api/messages
```

*Justification du resultat attendu : La commande curl renvoie un tableau JSON contenant 'Message initialise depuis server-dba !'. Cela certifie que l'API Java a demarre avec succes sur "server-back" et qu'elle a reussi a se connecter a la base de donnees "server-dba" pour recuperer le message.*

---

### [CAPTURE_ECRAN_4 : Acces a l'interface Frontend]

**Action a faire sur votre machine (Hote) :**
Ouvrez votre navigateur web (Chrome, Firefox, Safari) et allez a l'adresse suivante :
```text
http://localhost:8082
```

*Justification du resultat attendu : L'affichage reussi de l'application React avec la liste des messages prouve que tout le flux reseau fonctionne : (1) Le frontend est bien mis en ligne par Nginx, (2) le navigateur fait une requete vers l'API via le reverse proxy Nginx, et (3) la boucle complete (React -> Nginx -> Spring Boot -> MySQL) est operationnelle.*

---

## Arret et nettoyage de l'environnement

**Pour arreter les machines une fois les tests termines et les captures realisees :**
```bash
vagrant halt
```

**Pour supprimer completement l'architecture et liberer l'espace disque :**
```bash
vagrant destroy -f
```

