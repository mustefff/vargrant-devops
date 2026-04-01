#!/bin/bash
# =============================================================================
# back_provision.sh — Installation JDK 17 et API sur server-back
# =============================================================================

set -e

echo "============================================="
echo "  PROVISIONING server-back (API) — Démarrage"
echo "============================================="

apt-get update -qq
apt-get install -y -qq openjdk-17-jdk maven curl net-tools

ARCH=$(dpkg --print-architecture)

echo "JAVA_HOME=\"/usr/lib/jvm/java-17-openjdk-${ARCH}\"" >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-${ARCH}"

echo "Build de l'Application Spring Boot..."
cd /vagrant_back
if [ -f "pom.xml" ]; then
    mvn clean package -DskipTests
else
    echo "ATTENTION: pom.xml introuvable !"
fi

JAR_FILE=$(find /vagrant_back/target -name "*.jar" -not -name "*plain.jar" | head -n 1)

echo "Configuration du service systemd..."
cat > /etc/systemd/system/backend.service <<EOF
[Unit]
Description=Backend Spring Boot API
After=network.target

[Service]
User=root
ExecStart=/usr/bin/java -jar ${JAR_FILE:-/vagrant_back/target/demo-0.0.1-SNAPSHOT.jar}
SuccessExitStatus=143
Restart=always
Environment="SPRING_DATASOURCE_URL=jdbc:mysql://10.0.2.2:3307/tp3_db"
Environment="SPRING_DATASOURCE_USERNAME=tp3_user"
Environment="SPRING_DATASOURCE_PASSWORD=Tp3Pass123!"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable backend
systemctl restart backend || true

echo "============================================="
echo "  server-back PRÊT ✓ (API sur port 8080)"
echo "============================================="
