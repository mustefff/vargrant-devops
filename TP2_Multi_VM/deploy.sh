#!/bin/bash
# =============================================================================
# deploy.sh — Script de gestion du serveur Tomcat 9
# Auteur : srv-web provisioning
# Usage  : ./deploy.sh
# =============================================================================

TOMCAT_SERVICE="tomcat9"
TOMCAT_HOME="/opt/tomcat9"
WEBAPPS_DIR="${TOMCAT_HOME}/webapps"
APP_DIR="/vagrant_app"

# Détecter l'architecture
ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64")

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# Fonctions utilitaires
# =============================================================================

print_banner() {
  clear
  echo -e "${CYAN}${BOLD}"
  echo "╔══════════════════════════════════════════════════╗"
  echo "║       🚀  GESTIONNAIRE TOMCAT 9 — srv-web        ║"
  echo "║          Script de déploiement & contrôle        ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

print_status() {
  local STATUS
  STATUS=$(systemctl is-active "$TOMCAT_SERVICE" 2>/dev/null)
  if [ "$STATUS" = "active" ]; then
    echo -e "  Statut Tomcat : ${GREEN}● RUNNING${NC}"
  else
    echo -e "  Statut Tomcat : ${RED}● STOPPED${NC}"
  fi
  echo ""
}

require_root() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERREUR] Cette action nécessite les droits root.${NC}"
    echo -e "  Relancez avec : ${YELLOW}sudo ./deploy.sh${NC}"
    press_key
    return 1
  fi
  return 0
}

press_key() {
  echo ""
  read -rp "  Appuyez sur [Entrée] pour continuer..."
}

# =============================================================================
# Actions
# =============================================================================

action_start() {
  require_root || return
  echo -e "${BLUE}[→] Démarrage de Tomcat 9...${NC}"
  systemctl start "$TOMCAT_SERVICE"
  sleep 2
  if systemctl is-active --quiet "$TOMCAT_SERVICE"; then
    echo -e "${GREEN}[✓] Tomcat 9 démarré avec succès.${NC}"
  else
    echo -e "${RED}[✗] Échec du démarrage. Voir les logs :${NC}"
    journalctl -u "$TOMCAT_SERVICE" -n 20 --no-pager
  fi
  press_key
}

action_stop() {
  require_root || return
  echo -e "${YELLOW}[→] Arrêt de Tomcat 9...${NC}"
  systemctl stop "$TOMCAT_SERVICE"
  sleep 2
  if ! systemctl is-active --quiet "$TOMCAT_SERVICE"; then
    echo -e "${GREEN}[✓] Tomcat 9 arrêté avec succès.${NC}"
  else
    echo -e "${RED}[✗] Échec de l'arrêt.${NC}"
  fi
  press_key
}

action_restart() {
  require_root || return
  echo -e "${YELLOW}[→] Redémarrage de Tomcat 9...${NC}"
  systemctl restart "$TOMCAT_SERVICE"
  sleep 3
  if systemctl is-active --quiet "$TOMCAT_SERVICE"; then
    echo -e "${GREEN}[✓] Tomcat 9 redémarré avec succès.${NC}"
  else
    echo -e "${RED}[✗] Échec du redémarrage. Voir les logs :${NC}"
    journalctl -u "$TOMCAT_SERVICE" -n 20 --no-pager
  fi
  press_key
}

action_status() {
  echo -e "${BLUE}[→] Statut détaillé de Tomcat 9 :${NC}"
  echo ""
  systemctl status "$TOMCAT_SERVICE" --no-pager
  echo ""
  echo -e "${BLUE}  Ports en écoute :${NC}"
  ss -tlnp | grep -E "8080|8443|8009" || echo "  (aucun port Tomcat détecté)"
  echo ""
  echo -e "${BLUE}  Applications déployées :${NC}"
  if [ -d "$WEBAPPS_DIR" ]; then
    ls -lh "$WEBAPPS_DIR" | grep -v "^total" | awk '{printf "  %-30s %s\n", $9, $5}'
  fi
  press_key
}

action_deploy() {
  require_root || return
  echo -e "${BLUE}[→] Déploiement d'une application WAR${NC}"
  echo ""

  # Lister les WARs disponibles dans APP_DIR="/vagrant_app"
  if [ -d "$APP_DIR" ]; then
    WAR_FILES=("$APP_DIR"/*.war)
    if [ -e "${WAR_FILES[0]}" ]; then
      echo -e "  WARs disponibles dans ${APP_DIR} :"
      select WAR in "${WAR_FILES[@]}" "Annuler"; do
        if [ "$WAR" = "Annuler" ]; then
          echo "  Déploiement annulé."
          press_key
          return
        fi
        if [ -f "$WAR" ]; then
          WAR_NAME=$(basename "$WAR")
          echo -e "  ${YELLOW}Déploiement de : ${WAR_NAME}${NC}"
          # Arrêter d'abord
          systemctl stop "$TOMCAT_SERVICE"
          sleep 1
          cp "$WAR" "$WEBAPPS_DIR/"
          chown tomcat:tomcat "$WEBAPPS_DIR/$WAR_NAME"
          systemctl start "$TOMCAT_SERVICE"
          sleep 2
          echo -e "${GREEN}[✓] ${WAR_NAME} déployé et Tomcat redémarré.${NC}"
          echo -e "  Accès : ${CYAN}http://localhost:8080/${WAR_NAME%.war}${NC}"
          press_key
          return
        fi
      done
    else
      echo -e "${YELLOW}  Aucun fichier WAR trouvé dans ${APP_DIR}.${NC}"
      echo "  Placez votre .war dans le dossier partagé app/ sur l'hôte."
      press_key
      return
    fi
  else
    echo -e "${RED}  Dossier ${APP_DIR} introuvable.${NC}"
    press_key
    return
  fi
}

action_logs() {
  echo -e "${BLUE}[→] Logs Tomcat (${TOMCAT_HOME}/logs/) :${NC}"
  echo ""
  LOG_FILES=("${TOMCAT_HOME}/logs/"*.log "${TOMCAT_HOME}/logs/"*.txt)
  select LOG in "${LOG_FILES[@]}" "Logs systemd (journalctl)" "Retour"; do
    case "$LOG" in
      "Retour") return ;;
      "Logs systemd (journalctl)")
        journalctl -u "$TOMCAT_SERVICE" -n 50 --no-pager
        press_key
        return
        ;;
      *)
        if [ -f "$LOG" ]; then
          echo -e "${YELLOW}=== $(basename "$LOG") ===${NC}"
          tail -n 80 "$LOG"
          press_key
          return
        fi
        ;;
    esac
  done
}

action_java_versions() {
  echo -e "${BLUE}[→] Versions JDK installées :${NC}"
  echo ""
  for V in 8 11 17; do
    JVM_DIR="/usr/lib/jvm/java-${V}-openjdk-${ARCH}/bin/java"
    if [ -f "$JVM_DIR" ]; then
      echo -n "  JDK ${V} : "
      "$JVM_DIR" -version 2>&1 | head -1
    else
      echo -e "  JDK ${V} : ${RED}non trouvé${NC}"
    fi
  done
  echo ""
  echo -e "  Version Java active :"
  java -version 2>&1 | head -1
  echo ""
  echo -e "  Pour changer de JDK : ${YELLOW}sudo update-alternatives --config java${NC}"
  press_key
}

# =============================================================================
# MENU PRINCIPAL
# =============================================================================

main_menu() {
  while true; do
    print_banner
    print_status

    echo -e "${BOLD}  ╔═══════════════════════════════╗${NC}"
    echo -e "${BOLD}  ║         MENU PRINCIPAL        ║${NC}"
    echo -e "${BOLD}  ╚═══════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Démarrer Tomcat"
    echo -e "  ${RED}2)${NC} Arrêter Tomcat"
    echo -e "  ${YELLOW}3)${NC} Redémarrer Tomcat"
    echo -e "  ${BLUE}4)${NC} Statut détaillé"
    echo -e "  ${CYAN}5)${NC} Déployer une application WAR"
    echo -e "  ${CYAN}6)${NC} Consulter les logs"
    echo -e "  ${CYAN}7)${NC} Versions JDK installées"
    echo -e "  ${RED}0)${NC} Quitter"
    echo ""
    read -rp "  Votre choix [0-7] : " CHOICE

    case "$CHOICE" in
      1) action_start ;;
      2) action_stop ;;
      3) action_restart ;;
      4) action_status ;;
      5) action_deploy ;;
      6) action_logs ;;
      7) action_java_versions ;;
      0)
        echo ""
        echo -e "${GREEN}  Au revoir ! 👋${NC}"
        echo ""
        exit 0
        ;;
      *)
        echo -e "${RED}  Option invalide. Veuillez choisir entre 0 et 7.${NC}"
        sleep 1
        ;;
    esac
  done
}

# Lancement
main_menu
