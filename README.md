# TP DevOps - Virtualisation avec Vagrant
 
**Technos : Vagrant, QEMU (Architecture ARM), Ubuntu, Tomcat 9, MySQL**

Ce projet contient trois travaux pratiques (TP) visant à maîtriser la virtualisation et l'automatisation du déploiement.

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



## Commandes Utiles

- `vagrant ssh [vm_name]` : Pour entrer dans une machine.
- `vagrant halt` : Pour éteindre les machines après les tests.
- `vagrant destroy -f` : Pour supprimer les machines et libérer l'espace disque.
