#!/bin/bash
# =============================================================================
# provision.sh — Provisioning automatique de srv-web
# JDK 8, 11, 17 + Tomcat 9 + déploiement application web Java
# =============================================================================

set -e  # Arrêt en cas d'erreur

echo "============================================="
echo "  PROVISIONING srv-web — Démarrage"
echo "============================================="

# --- Mise à jour du système ---
echo "[1/6] Mise à jour apt..."
apt-get update -qq
apt-get upgrade -y -qq

# --- Installation de utilitaires ---
echo "[2/6] Installation des utilitaires..."
apt-get install -y -qq wget curl unzip net-tools software-properties-common

# =============================================================================
# INSTALLATION JDK 8, 11, 17
# =============================================================================
echo "[3/6] Installation des JDKs..."

# JDK 8
apt-get install -y openjdk-8-jdk
echo "  ✓ JDK 8 installé"

# JDK 11
apt-get install -y openjdk-11-jdk
echo "  ✓ JDK 11 installé"

# JDK 17
apt-get install -y openjdk-17-jdk
echo "  ✓ JDK 17 installé"

# Détecter l'architecture (amd64, arm64, etc.)
ARCH=$(dpkg --print-architecture)

# Définir JDK 17 comme version par défaut
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-${ARCH}/bin/java
update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-${ARCH}/bin/javac

echo "  → Version Java par défaut :"
java -version

# Variables JAVA_HOME dans /etc/environment
echo "JAVA_HOME=\"/usr/lib/jvm/java-17-openjdk-${ARCH}\"" >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-${ARCH}"

# =============================================================================
# INSTALLATION TOMCAT 9
# =============================================================================
echo "[4/6] Installation de Tomcat 9..."

TOMCAT_VERSION="9.0.87"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_DIR="/opt/tomcat9"

# Créer un utilisateur système tomcat
if ! id -u tomcat > /dev/null 2>&1; then
  useradd -r -m -U -d "$TOMCAT_DIR" -s /bin/false tomcat
fi

# Téléchargement et extraction
wget -q "$TOMCAT_URL" -O /tmp/apache-tomcat.tar.gz
mkdir -p "$TOMCAT_DIR"
tar -xzf /tmp/apache-tomcat.tar.gz -C "$TOMCAT_DIR" --strip-components=1
rm /tmp/apache-tomcat.tar.gz

# Permissions
chown -R tomcat:tomcat "$TOMCAT_DIR"
chmod +x "$TOMCAT_DIR"/bin/*.sh

# Configuration des utilisateurs Tomcat (manager/admin)
cat > "$TOMCAT_DIR/conf/tomcat-users.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <user username="admin" password="Admin@123" roles="manager-gui,manager-script,admin-gui,admin-script"/>
</tomcat-users>
EOF

# Autoriser l'accès au Manager depuis toute IP
sed -i 's|allow="127\\.0\\.0\\.1"|allow=".*"|g' \
  "$TOMCAT_DIR/webapps/manager/META-INF/context.xml" 2>/dev/null || true
sed -i 's|allow="127\\.0\\.0\\.1"|allow=".*"|g' \
  "$TOMCAT_DIR/webapps/host-manager/META-INF/context.xml" 2>/dev/null || true

# Créer le service systemd
cat > /etc/systemd/system/tomcat9.service <<EOF
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-${ARCH}"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Xms512m -Xmx1024m"
Environment="CATALINA_HOME=${TOMCAT_DIR}"
Environment="CATALINA_BASE=${TOMCAT_DIR}"
Environment="CATALINA_PID=${TOMCAT_DIR}/temp/tomcat.pid"

ExecStart=${TOMCAT_DIR}/bin/startup.sh
ExecStop=${TOMCAT_DIR}/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat9
systemctl start tomcat9
echo "  ✓ Tomcat 9 démarré et activé au boot"

# =============================================================================
# DÉPLOIEMENT DE L'APPLICATION WEB JAVA
# =============================================================================
echo "[5/6] Déploiement de l'application web Java..."

APP_WAR="/vagrant_app/monapp.war"
WEBAPPS_DIR="${TOMCAT_DIR}/webapps"

if [ -f "$APP_WAR" ]; then
  cp "$APP_WAR" "$WEBAPPS_DIR/"
  chown tomcat:tomcat "$WEBAPPS_DIR/monapp.war"
  echo "  ✓ monapp.war déployé depuis /vagrant_app/"
else
  # Créer une application de démonstration si aucun WAR n'est fourni
  echo "  → WAR non trouvé, création d'une app de démo..."
  mkdir -p /tmp/demoapp/WEB-INF
  cat > /tmp/demoapp/index.jsp <<'JSPEOF'
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>srv-web — Application Java</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
    }
    .card {
      background: rgba(255,255,255,0.08);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255,255,255,0.15);
      border-radius: 20px;
      padding: 50px 60px;
      text-align: center;
      max-width: 600px;
      box-shadow: 0 25px 50px rgba(0,0,0,0.4);
    }
    .logo { font-size: 60px; margin-bottom: 20px; }
    h1 { font-size: 2.2rem; margin-bottom: 10px; color: #e94560; }
    .subtitle { color: #aaa; font-size: 1rem; margin-bottom: 30px; }
    .info-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 15px;
      margin-top: 30px;
    }
    .info-item {
      background: rgba(233,69,96,0.15);
      border: 1px solid rgba(233,69,96,0.3);
      border-radius: 10px;
      padding: 15px;
    }
    .info-label { font-size: 0.75rem; color: #e94560; text-transform: uppercase; letter-spacing: 1px; }
    .info-value { font-size: 1rem; font-weight: bold; margin-top: 5px; }
    .badge {
      display: inline-block;
      background: #e94560;
      color: #fff;
      padding: 5px 15px;
      border-radius: 20px;
      font-size: 0.85rem;
      margin-top: 20px;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">🚀</div>
    <h1>Application Web Java</h1>
    <p class="subtitle">Déployée sur Tomcat 9 — srv-web</p>

    <div class="info-grid">
      <div class="info-item">
        <div class="info-label">Serveur</div>
        <div class="info-value">srv-web</div>
      </div>
      <div class="info-item">
        <div class="info-label">Serveur d'applications</div>
        <div class="info-value">Apache Tomcat 9</div>
      </div>
      <div class="info-item">
        <div class="info-label">JDK</div>
        <div class="info-value">OpenJDK 17</div>
      </div>
      <div class="info-item">
        <div class="info-label">IP Privée</div>
        <div class="info-value">192.168.56.10</div>
      </div>
    </div>

    <% 
      String javaVersion = System.getProperty("java.version");
      String serverInfo = application.getServerInfo();
    %>
    <div class="info-grid" style="margin-top:15px;">
      <div class="info-item">
        <div class="info-label">Java Version</div>
        <div class="info-value"><%= javaVersion %></div>
      </div>
      <div class="info-item">
        <div class="info-label">Tomcat Info</div>
        <div class="info-value"><%= serverInfo %></div>
      </div>
    </div>

    <span class="badge">✓ Déployée avec succès</span>
  </div>
</body>
</html>
JSPEOF

  cat > /tmp/demoapp/WEB-INF/web.xml <<'WEBEOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">
  <display-name>MonApp - Application Java Demo</display-name>
  <welcome-file-list>
    <welcome-file>index.jsp</welcome-file>
  </welcome-file-list>
</web-app>
WEBEOF

  # Packager en WAR
  apt-get install -y -qq zip
  cd /tmp/demoapp && zip -r /tmp/monapp.war . -q
  cp /tmp/monapp.war "$WEBAPPS_DIR/"
  chown tomcat:tomcat "$WEBAPPS_DIR/monapp.war"
  echo "  ✓ Application de démo déployée : monapp.war"
fi

# Copier le script deploy.sh dans la VM
# (avec QEMU/rsync, /vagrant n'est pas monté — on copie depuis le répertoire courant)
if [ -f /vagrant/deploy.sh ]; then
  cp /vagrant/deploy.sh /home/vagrant/deploy.sh
elif [ -f /tmp/deploy.sh ]; then
  cp /tmp/deploy.sh /home/vagrant/deploy.sh
fi
chmod +x /home/vagrant/deploy.sh 2>/dev/null || true
chown vagrant:vagrant /home/vagrant/deploy.sh 2>/dev/null || true
echo "  ✓ deploy.sh disponible dans /home/vagrant/"

# =============================================================================
# RÉSUMÉ FINAL
# =============================================================================
echo ""
echo "============================================="
echo "  PROVISIONING TERMINÉ ✓"
echo "============================================="
echo ""
echo "  JDK 8  → /usr/lib/jvm/java-8-openjdk-${ARCH}"
echo "  JDK 11 → /usr/lib/jvm/java-11-openjdk-${ARCH}"
echo "  JDK 17 → /usr/lib/jvm/java-17-openjdk-${ARCH} (défaut)"
echo "  Tomcat 9 → /opt/tomcat9 (port 8080)"
echo ""
echo "  Accès Tomcat   : http://192.168.56.10:8080"
echo "  Application    : http://192.168.56.10:8080/monapp"
echo "  Tomcat Manager : http://192.168.56.10:8080/manager/html"
echo "                   login: admin / Admin@123"
echo ""
echo "  Script déploiement : ~/deploy.sh"
echo "============================================="
