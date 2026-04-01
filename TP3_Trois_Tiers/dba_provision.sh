#!/bin/bash
# =============================================================================
# dba_provision.sh — Installation MySQL Server sur server-dba
# =============================================================================

set -e

echo "============================================="
echo "  PROVISIONING server-dba (MySQL) — Démarrage"
echo "============================================="

apt-get update -qq
apt-get install -y -qq mysql-server net-tools

# Configuration MySQL pour écouter sur toutes les IPs (nécessaire pour VM <-> VM via l'hôte)
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql

# Création Base de données, Utilisateur et Privilèges
echo "Configuration de la base de données..."
mysql -e "CREATE DATABASE IF NOT EXISTS tp3_db;"
mysql -e "CREATE USER IF NOT EXISTS 'tp3_user'@'%' IDENTIFIED BY 'Tp3Pass123!';"
mysql -e "GRANT ALL PRIVILEGES ON tp3_db.* TO 'tp3_user'@'%';"
mysql -e "FLUSH PRIVILEGES;"

# Création d'une table de test et insertion de données
mysql tp3_db -e "CREATE TABLE IF NOT EXISTS messages (id INT AUTO_INCREMENT PRIMARY KEY, content VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
mysql tp3_db -e "INSERT INTO messages (content) VALUES ('Message initialisé depuis server-dba !');"

echo "============================================="
echo "  server-dba PRÊT ✓ (MySQL sur port 3306)"
echo "============================================="
