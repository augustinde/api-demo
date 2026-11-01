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

`.github/workflows/ci-cd.yml` :

| Événement | Ce qui se passe |
| --- | --- |
| pull request (dont Renovate) | build de contrôle, rien n'est publié |
| push sur `main` | image `ghcr.io/augustinde/api-demo:sha-<commit>`, déployée en **test** : `https://api-demo-test.augustinde.dev` (namespace `demo`) |
| tag `v1.2.3` | la même image, réétiquetée `v1.2.3`, déployée en **prod** : `https://api-demo.augustinde.dev` (namespace `demo-prod`) |

Mettre en production le commit actuellement en test :

```bash
git tag v1.0.0 && git push origin v1.0.0
```

Le tag doit porter sur un commit déjà construit sur `main`, sinon le job `release` s'arrête.
Authentification par OIDC GitHub derrière Cloudflare Access : aucun jeton Kubernetes n'est stocké chez GitHub.
Le déploiement est ignoré tant que la variable `K8S_API_HOST` n'est pas définie.
Configuration côté GitHub : étapes 0, 10 et 11 de la procédure k3s.
Les dépendances sont suivies par Renovate (`renovate.json`) : correctifs fusionnés automatiquement, le reste à valider.
