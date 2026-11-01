#!/usr/bin/env bash
# Plugin d'identification kubectl/helm pour GitHub Actions.
# Demande à GitHub un jeton OIDC (audience = celle attendue par k3s) et le renvoie au
# format ExecCredential. kubectl/helm le rappellent automatiquement avant expiration :
# un `helm --wait` de plusieurs minutes survit à la durée de vie courte du jeton (~5 min).
#
# Prérequis du job : permissions: id-token: write
# Usage (dans le kubeconfig) : github-oidc-credential.sh <audience>
set -euo pipefail

AUDIENCE="${1:?audience requise (ex. k3s-test)}"
: "${ACTIONS_ID_TOKEN_REQUEST_URL:?Jeton OIDC indisponible : ajouter permissions: id-token: write au job}"
: "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:?Jeton OIDC indisponible}"

TOKEN=$(curl -fsS \
  -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
  "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=${AUDIENCE}" | jq -r '.value')

# Marge de sécurité : on annonce une expiration à 4 minutes pour forcer un renouvellement à temps
EXPIRES=$(date -u -d '+4 minutes' +%Y-%m-%dT%H:%M:%SZ)

jq -cn --arg token "$TOKEN" --arg exp "$EXPIRES" \
  '{apiVersion: "client.authentication.k8s.io/v1", kind: "ExecCredential",
    status: {token: $token, expirationTimestamp: $exp}}'
