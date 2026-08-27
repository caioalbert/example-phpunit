#!/usr/bin/env bash
set -euo pipefail

SONAR_HOST_URL="${SONAR_HOST_URL:-http://127.0.0.1:9000}"
SONAR_SCANNER_IMAGE="${SONAR_SCANNER_IMAGE:-sonarsource/sonar-scanner-cli:12.1}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${SONAR_TOKEN:-}" ]]; then
  echo "Defina SONAR_TOKEN com um token de analise do SonarQube." >&2
  exit 1
fi

for report in build/logs/clover.xml build/logs/junit.xml; do
  if [[ ! -f "${PROJECT_DIR}/${report}" ]]; then
    echo "Relatorio ausente: ${report}. Execute 'docker compose run --rm tests' primeiro." >&2
    exit 1
  fi
done

if ! curl --fail --silent --show-error --max-time 10 "${SONAR_HOST_URL}/api/system/status" >/dev/null; then
  echo "SonarQube indisponivel em ${SONAR_HOST_URL}." >&2
  exit 1
fi

docker run --rm \
  --network host \
  --env SONAR_HOST_URL \
  --env SONAR_TOKEN \
  --env SONAR_USER_HOME=/tmp/.sonar \
  --volume "${PROJECT_DIR}:/app" \
  --workdir /app \
  "${SONAR_SCANNER_IMAGE}"
