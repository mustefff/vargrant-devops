#!/bin/bash
# =============================================================================
# front_provision.sh — Installation Nginx + React sur server-front
# =============================================================================

set -e

echo "============================================="
echo "  PROVISIONING server-front (React) — Démarrage"
echo "============================================="

apt-get update -qq
apt-get install -y -qq nginx curl net-tools

# Installation Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y -qq nodejs

echo "Build de l'application Frontend React..."
if [ -f "/vagrant_front/package.json" ]; then
    # Copie des fichiers vers un répertoire non synchronisé pour éviter les problèmes de liens symboliques (ERR_MODULE_NOT_FOUND)
    rm -rf /tmp/frontend_build
    mkdir -p /tmp/frontend_build
    cp -r /vagrant_front/* /tmp/frontend_build/
    
    cd /tmp/frontend_build
    rm -rf node_modules package-lock.json
    npm install
    npm run build
    
    rm -rf /var/www/html/*
    cp -r dist/* /var/www/html/ # Vite génère dans "dist", pas "build"
else
    echo "ATTENTION: /vagrant_front/package.json introuvable !"
    echo "<h1>Frontend en cours de construction</h1>" > /var/www/html/index.html
fi

echo "Configuration Nginx reverse proxy..."
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Proxy pour la communication avec le backend (host:8081)
    location /api/ {
        proxy_pass http://10.0.2.2:8081/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

systemctl restart nginx

echo "============================================="
echo "  server-front PRÊT ✓ (UI + Proxy sur port 80)"
echo "============================================="
