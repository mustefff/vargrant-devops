#!/bin/bash
# =============================================================================
# db_provision.sh — Installation MySQL Server sur srv-db
# =============================================================================

set -e

echo "============================================="
echo "  PROVISIONING srv-db (MySQL) — Démarrage"
echo "============================================="

apt-get update -qq
apt-get install -y -qq mysql-server net-tools

# Configuration MySQL pour écouter sur toutes les IPs (nécessaire pour QEMU)
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql

# Création Base de données, Utilisateur et Privilèges
echo "Configuration de la base de données..."
mysql -e "CREATE DATABASE IF NOT EXISTS appdb;"
mysql -e "CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'AppPass123!';"
mysql -e "GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'%';"
mysql -e "FLUSH PRIVILEGES;"

# Création d'une table de test
mysql appdb -e "CREATE TABLE IF NOT EXISTS messages (id INT AUTO_INCREMENT PRIMARY KEY, content VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
mysql appdb -e "INSERT INTO messages (content) VALUES ('Connexion réussie depuis srv-db !');"

echo "============================================="
echo "  srv-db PRÊT ✓ (MySQL sur port 3306)"
echo "============================================="
