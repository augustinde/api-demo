#!/usr/bin/env bash
# Écrit le kubeconfig d'un job GitHub Actions : API joignable sur 127.0.0.1:<port>
# (extrémité locale de `cloudflared access tcp`), identité fournie par OIDC.
# Aucun secret dans ce fichier : le jeton est demandé à GitHub à chaque besoin.
#
# Usage : write-kubeconfig.sh <ca-base64> <audience> <namespace> [port]
set -euo pipefail

CA="${1:?certificat CA k3s en base64 requis (variable GitHub K8S_CA_DATA)}"
AUDIENCE="${2:?audience requise}"
NAMESPACE="${3:?namespace requis}"
PORT="${4:-16443}"
PLUGIN="$(cd "$(dirname "$0")" && pwd)/github-oidc-credential.sh"
OUT="${KUBECONFIG:-$HOME/.kube/config}"

chmod +x "$PLUGIN"
mkdir -p "$(dirname "$OUT")"
umask 077
cat > "$OUT" <<EOF
apiVersion: v1
kind: Config
clusters:
  - name: k3s
    cluster:
      server: https://127.0.0.1:${PORT}
      certificate-authority-data: ${CA}
users:
  - name: github-oidc
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1
        command: ${PLUGIN}
        args: ["${AUDIENCE}"]
        interactiveMode: Never
contexts:
  - name: github
    context:
      cluster: k3s
      user: github-oidc
      namespace: ${NAMESPACE}
current-context: github
EOF
echo "Kubeconfig OIDC écrit : $OUT"
