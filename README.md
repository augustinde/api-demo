# api-demo

API Spring Boot 4.1 (Java 21) qui expose une seule route :

```
GET /api/demo  →  [{"id":1,"label":"seed-1","createdAt":"2026-11-01T11:00:00Z"}, …]
```

Elle lit la table `demo` de la base PostgreSQL `app`, créée et remplie par CloudNativePG dans le cluster k3s
(seed de `k3s-lab/helmfile/databases/app.yaml`). L'écran [front-demo](https://github.com/augustinde/front-demo) l'affiche.

## Développement local

Avec la base du cluster exposée sur `localhost:5432` :

```bash
# dans k3s-lab
make db-forward DB=app
make db-creds DB=app          # mot de passe

# dans api-demo
SPRING_DATASOURCE_PASSWORD=<mot de passe> mvn spring-boot:run
curl http://localhost:8080/api/demo
```

## Image

```bash
docker build -t api-demo .
```

Build Maven en deux étapes, exécution sur JRE 21 avec un utilisateur non-root (uid 1000),
compatible avec le Pod Security « restricted » du namespace `demo`.

Sondes Kubernetes : `/actuator/health/liveness` et `/actuator/health/readiness`
(la readiness inclut la connexion à PostgreSQL).

## Déploiement

À chaque push sur `main`, `.github/workflows/ci-cd.yml` :

1. construit l'image et la publie sur `ghcr.io/augustinde/api-demo` (tags `sha-<commit>` et `latest`) ;
2. la déploie sur le cluster k3s-test (namespace `demo`) avec Helm, en s'authentifiant par OIDC GitHub
   derrière Cloudflare Access. Aucun jeton Kubernetes n'est stocké chez GitHub.

Les identifiants de la base sont injectés par le chart depuis le secret `app-app` généré par CloudNativePG.
Le déploiement est ignoré tant que la variable `K8S_API_HOST` n'est pas définie.
Configuration côté GitHub : voir l'étape 0 de la procédure k3s.
