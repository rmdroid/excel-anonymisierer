#!/usr/bin/env bash
#
# KI-Anonymisierer Excel — Einrichtung
#
#   curl -fsSL https://raw.githubusercontent.com/rmdroid/excel-anonymisierer/main/install.sh | bash
#
# oder nach dem Klonen:  ./install.sh
#
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/rmdroid/excel-anonymisierer:latest}"
DIR="${ANONYMIZER_DIR:-$HOME/ki-anonymisierer-excel}"
PORT="${PORT:-9999}"
MEMORY="${MEMORY:-4G}"

say()  { printf '%s\n' "$*"; }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[33m%s\033[0m\n' "$*"; }
die()  { printf '\033[31m%s\033[0m\n' "$*" >&2; exit 1; }

step "KI-Anonymisierer Excel"
say  "Excel-Dateien anonymisieren, vollstaendig auf diesem Rechner."

# ---------------------------------------------------------------- Vorbedingungen
step "Voraussetzungen pruefen"

command -v docker >/dev/null 2>&1 \
  || die "Docker wurde nicht gefunden. Docker Desktop installieren: https://docs.docker.com/get-docker/"

docker info >/dev/null 2>&1 \
  || die "Docker laeuft nicht. Bitte Docker Desktop starten und erneut versuchen."

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  die "docker compose fehlt. Es gehoert zu Docker Desktop dazu."
fi

say "  Docker  $(docker --version | cut -d' ' -f3 | tr -d ,)"

if command -v lsof >/dev/null 2>&1 && lsof -Pi ":$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  die "Port $PORT ist belegt. Mit PORT=9998 ./install.sh einen anderen waehlen."
fi

# Das Sprachmodell braucht beim Laden gut 2 GB.
TOTAL=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)
if [ "$TOTAL" -gt 0 ] && [ "$TOTAL" -lt 4000000000 ]; then
  warn ""
  warn "  Docker stehen nur $((TOTAL/1024/1024/1024)) GB zur Verfuegung, empfohlen sind 4 GB."
  warn "  In Docker Desktop unter Settings > Resources mehr zuteilen."
  warn ""
fi

# ---------------------------------------------------------------- Lizenz
step "Lizenzschluessel"
say "  Ohne Schluessel ist nichts freigeschaltet. Einen Testzugang fuer"
say "  7 Tage gibt es unter rm@kostenmanager.net."
say "  Der Schluessel laesst sich auch spaeter in der Oberflaeche eintragen."
say ""

KEY="${LICENSE_KEY:-}"
if [ -z "$KEY" ] && [ -t 0 ]; then
  read -rp "Schluessel (KIX1..., leer = spaeter): " KEY
fi

# ---------------------------------------------------------------- Einrichten
step "Einrichten in $DIR"
mkdir -p "$DIR"
cd "$DIR"

cat > docker-compose.yml <<COMPOSE
services:
  excel:
    image: ${IMAGE}
    container_name: ki-anonymisierer-excel
    restart: unless-stopped

    # Nur von diesem Rechner erreichbar. Ohne das "127.0.0.1:" davor
    # veroeffentlicht Docker den Port im gesamten Netzwerk.
    ports:
      - "127.0.0.1:${PORT}:9999"

    env_file: .env

    # Lizenz und Profile. Das Sprachmodell steckt im Abbild.
    volumes:
      - data:/data

    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL

    deploy:
      resources:
        limits:
          memory: ${MEMORY}

volumes:
  data:
COMPOSE

if [ ! -f .env ]; then
  {
    echo "# Lizenzschluessel. Alternativ in der Oberflaeche eintragen."
    echo "# Ein Schluessel hier hat Vorrang vor dem in der Oberflaeche."
    if [ -n "$KEY" ]; then echo "LICENSE_KEY=$KEY"; else echo "# LICENSE_KEY=KIX1...."; fi
  } > .env
  chmod 600 .env
  say "  .env angelegt"
else
  warn "  .env bleibt unveraendert"
fi

# ---------------------------------------------------------------- Starten
step "Abbild laden (rund 2,2 GB, nur beim ersten Mal)"
if [ "${SKIP_PULL:-0}" != "1" ]; then
  docker pull "$IMAGE"
else
  say "  uebersprungen (SKIP_PULL=1)"
fi

step "Starten"
$COMPOSE up -d

printf '  Warte auf Bereitschaft '
READY=0
for _ in $(seq 1 90); do
  if curl -fsS "http://127.0.0.1:${PORT}/api/health" >/dev/null 2>&1; then READY=1; break; fi
  printf '.'
  sleep 1
done
printf '\n'

if [ "$READY" != "1" ]; then
  warn "  Die Anwendung antwortet noch nicht."
  warn "  Fortschritt:  docker logs -f ki-anonymisierer-excel"
  exit 0
fi

step "Fertig"
say "  Oberflaeche      http://localhost:${PORT}"
say "  Verzeichnis      $DIR"
say ""
say "  Beenden        cd $DIR && $COMPOSE down"
say "  Starten        cd $DIR && $COMPOSE up -d"
say "  Aktualisieren  cd $DIR && $COMPOSE pull && $COMPOSE up -d"
say ""
say "  Nutzungsbedingungen: EULA.md"
