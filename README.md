# TP DevOps - Virtualisation avec Vagrant

**Auteur : [Ton Nom]**  
**Technos : Vagrant, QEMU (Architecture ARM), Ubuntu, Tomcat 9, MySQL**

Ce projet contient deux travaux pratiques (TP) visant à maîtriser la virtualisation et l'automatisation du déploiement.

---

## Structure du Projet

- `TP1_Virtualisation/` : Serveur web monolithique (Java + Tomcat).
- `TP2_Multi_VM/` : Architecture distribuée (App Java + Base de données MySQL).
- `TP3_Trois_Tiers/` : Architecture 3-Tiers complète (Frontend React + Backend Spring Boot + Base MySQL).

---

## Prérequis

- [Vagrant](https://www.vagrantup.com/) installé.
- Plugin [vagrant-qemu](https://github.com/overmind88/vagrant-qemu) (nécessaire pour les Mac Apple Silicon M1-M4).

  ```bash
  vagrant plugin install vagrant-qemu
  ```

---

## TP1 - Virtualisation & Serveur Web (srv-web)

Le but est de créer un serveur Ubuntu automatisé avec plusieurs versions de Java et Tomcat 9.

### Lancement

```bash
cd TP1_Virtualisation
vagrant up
```

### [CAPTURE_ECRAN_1 : vagrant up TP1]

*Justification : Cette capture prouve que le provisioning automatique (JDK 8/11/17 + Tomcat) s'est déroulé sans erreur.*

### [CAPTURE_ECRAN_2 : Menu deploy.sh - Option 7]

*Justification : Affiche les 3 versions de JDK installées sur le serveur, validant la gestion des environnements multiples.*

### [CAPTURE_ECRAN_3 : Accès Navigateur monapp]

*Justification : Preuve que le serveur Tomcat est accessible depuis l'hôte (port 8080) et que l'app démo est déployée sur <http://localhost:8080/monapp/>.*

---

## TP2 - Automatisation & Multi-VM (srv-app & srv-db)

Mise en place d'une architecture client-serveur : une VM applicative connectée à une VM de base de données.

### Lancement TP2

```bash
cd TP2_Multi_VM
vagrant up
```

### [CAPTURE_ECRAN_4 : vagrant status TP2]

*Justification : Montre les deux machines `srv-app` et `srv-db` en cours d'exécution simultanément.*

### [CAPTURE_ECRAN_5 : Connexion MySQL sur srv-db]

*Justification : Capture de l'interface `mysql>` sur `srv-db`, prouvant que la base `appdb` et l'utilisateur `appuser` sont configurés.*

### [CAPTURE_ECRAN_6 : Test de Connexion JDBC (Navigateur)]

*Justification : Capture du bandeau vert "Connexion RÉUSSIE" sur [http://localhost:8080/monapp-db/](http://localhost:8080/monapp-db/), validant l'interconnexion sécurisée entre les deux VMs via le réseau virtuel.*

---

## TP3 - Architecture 3-Tiers (server-front, server-back, server-dba)

Déploiement automatisé d'une architecture complète avec Frontend, API Backend et Base de données.

- **server-dba** : Base de données MySQL (Port mappé : 3307)
- **server-back** : API REST Spring Boot sous Java 17 (Port mappé : 8081)
- **server-front** : Interface Web React servie par Nginx avec Reverse Proxy (Port mappé : 8082)

### Lancement TP3

```bash
cd TP3_Trois_Tiers
vagrant up
```

L'installation est entièrement automatisée. À la fin du processus :

1. L'API Spring Boot se connectera à la base de données via le réseau hôte.
2. Le frontend React sera compilé et mis en ligne sur Nginx.

### Vérification

- **Frontend UI** : Ouvrez [http://localhost:8082](http://localhost:8082) dans le navigateur pour tester l'interface.
- **Backend API** : Testez [http://localhost:8081/api/messages](http://localhost:8081/api/messages).
- **Base de données** : Connexion via `mysql -h 127.0.0.1 -P 3307 -u tp3_user -pTp3Pass123! tp3_db`.

---

## 🚀 Commandes Utiles

- `vagrant ssh [vm_name]` : Pour entrer dans une machine.
- `vagrant halt` : Pour éteindre les machines après les tests.
- `vagrant destroy -f` : Pour supprimer les machines et libérer l'espace disque.
