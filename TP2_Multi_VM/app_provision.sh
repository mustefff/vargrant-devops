#!/bin/bash
# =============================================================================
# app_provision.sh — Installation JDKs + Tomcat 9 sur srv-app
# =============================================================================

set -e

echo "============================================="
echo "  PROVISIONING srv-app — Démarrage"
echo "============================================="

apt-get update -qq
apt-get install -y -qq wget curl unzip net-tools software-properties-common

# Installation JDK 8, 11, 17
apt-get install -y openjdk-8-jdk openjdk-11-jdk openjdk-17-jdk

# Détection ARCH auto (pour éviter l'erreur de chemin amd64/arm64)
ARCH=$(dpkg --print-architecture)

# Définir JDK 17 par défaut
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-${ARCH}/bin/java
update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-${ARCH}/bin/javac

echo "JAVA_HOME=\"/usr/lib/jvm/java-17-openjdk-${ARCH}\"" >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-${ARCH}"

# Installation Tomcat 9
TOMCAT_VERSION="9.0.87"
TOMCAT_DIR="/opt/tomcat9"
useradd -r -m -U -d "$TOMCAT_DIR" -s /bin/false tomcat || true
wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -O /tmp/tomcat.tar.gz
mkdir -p "$TOMCAT_DIR"
tar -xzf /tmp/tomcat.tar.gz -C "$TOMCAT_DIR" --strip-components=1
chown -R tomcat:tomcat "$TOMCAT_DIR"
chmod +x "$TOMCAT_DIR"/bin/*.sh

# Service systemd Tomcat
cat > /etc/systemd/system/tomcat9.service <<EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-${ARCH}"
Environment="CATALINA_HOME=${TOMCAT_DIR}"
Environment="CATALINA_BASE=${TOMCAT_DIR}"
ExecStart=${TOMCAT_DIR}/bin/startup.sh
ExecStop=${TOMCAT_DIR}/bin/shutdown.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat9
systemctl start tomcat9

# Déploiement de l'application (créée juste après)
if [ -f /vagrant_app/monapp-db.war ]; then
  cp /vagrant_app/monapp-db.war "${TOMCAT_DIR}/webapps/"
  chown tomcat:tomcat "${TOMCAT_DIR}/webapps/monapp-db.war"
fi

# Copie du script deploy.sh
if [ -f /vagrant/deploy.sh ]; then
  cp /vagrant/deploy.sh /home/vagrant/deploy.sh
  chmod +x /home/vagrant/deploy.sh
  chown vagrant:vagrant /home/vagrant/deploy.sh
fi

echo "============================================="
echo "  srv-app PRÊT ✓ (Tomcat sur port 8080)"
echo "============================================="
