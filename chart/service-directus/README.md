# Service-Directus

This is a Helm chart for deploying Directus as a service in Epinio or standalone in a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.28+
- Helm 3.0+ or Epinio 1.11.0+
- Traefik Ingress Controller
- Cert Manager
- CloudNativePG

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm upgrade --install my-release oci://ghcr.io/odit-services/epinio-service-directus
```

### Values

The following table lists the configurable parameters of the Directus chart and their default values.

| Parameter                           | Description                                                                      | Default                               |
| ----------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------- |
| `image.repository`                  | Image repository                                                                 | `directus/directus`                   |
| `image.tag`                         | Image tag                                                                        | `latest`                              |
| `image.pullPolicy`                  | Image pull policy                                                                | `IfNotPresent`                        |
| `image.pullSecrets`                 | Image pull secrets                                                               | `[]`                                  |
|                                     |                                                                                  |                                       |
| `replicaCount`                      | Count of directus pods                                                           | `1`                                   |
| `strategy.type`                     | Update strategy (Recreate, RollingUpdate)                                        | `Recreate`                            |
| `strategy.rollingUpdate`            | RollingUpdate config (not for Recreate)                                          | `{"maxSurge":1, "maxUnavailable": 1}` |
|                                     |                                                                                  |                                       |
| `service.type`                      | Service type (ClusterIP, LoadBalancer, NodePort)                                 | `ClusterIP`                           |
| `service.port`                      | Service port                                                                     | `8055`                                |
|                                     |                                                                                  |                                       |
| `persistence.enabled`               | Enable persistence for directus (Uploads, SQLite, Extensions)                    | `true`                                |
| `persistence.storageClass`          | Storage class for persistence                                                    | `hcloud-volumes`                      |
| `persistence.size`                  | Size of the volume for persistence                                               | `10Gi`                                |
| `persistence.accessMode`            | Access mode for the volume (ReadWriteOnce, ReadWriteMany)                        | `ReadWriteOnce`                       |
| `persistence.extensions`            | Include the extension directory in the volume                                    | `true`                                |
|                                     |                                                                                  |                                       |
| `ingress.parentDomain`              | Use this to generate a subdomain based on the release name and the parent domain | `~`                                   |
| `ingress.domain`                    | Use this to set a fixed domain for the ingress (instead of a generated one)      | `~`                                   |
| `ingress.clusterIssuer`             | Use this to set the cert-manager cluster issuer for the ingress                  | `letsencrypt-prod`                    |
|                                     |                                                                                  |                                       |
| `auth.admin.email`                  | Admin email for the directus instance                                            | `demo@odit.services`                  |
| `auth.admin.password`               | Admin password for the directus instance                                         | `epiniodemo`                          |
| `auth.secret`                       | The directus secret used for encryption                                          | `lab`                                 |
|                                     |                                                                                  |                                       |
| `extraEnv`                          | Extra environment variables to set in the directus deployment                    | `[]`                                  |
| `extraEnvFrom`                      | Extra environment variables to set from secrets in the directus deployment       | `[]`                                  |
|                                     |                                                                                  |                                       |
| `postgres.enabled`                  | Use a postgres database (via CloudNativePG) instead of sqlite                    | `false`                               |
| `postgres.majorVersion`             | Major version of the postgres database to use (14, 15, 16, ...)                  | `16`                                  |
| `postgres.instances`                | Number of postgres replicas to run (odd number)                                  | `1`                                   |
| `postgres.persistence.size`         | Size of the volume for the postgres database (for each replica)                  | `10Gi`                                |
| `postgres.persistence.storageClass` | Storage class for the postgres database                                          | `hcloud-volumes`                      |
|                                     |                                                                                  |                                       |
| `backup.enabled`                    | Enable backups for the directus instance                                         | `false`                               |
| `backup.schedule`                   | Schedule for the backups (cron expression)                                       | `0 */6 * * *` (every 6 hours)         |
| `backup.retention`                  | Retention period for the backups (in days)                                       | `7`                                   |
| `backup.target`                     | Target for the backups (currently only supports s3 through s3ops)                | `s3ops`                               |
| `backup.s3ops.serverRef.name`       | Name of the s3 server ressource                                                  | `s3ops`                               |
| `backup.s3ops.serverRef.namespace`  | Namespace of the s3 server ressource                                             | `default`                             |
|                                     |                                                                                  |                                       |
| `livenessProbe.enable`              | Liveness probe enable/disable                                                    | `true`                                |
| `readynessProbe.enable`             | Readiness probe enable/disable                                                   | `true`                                |
|                                     |                                                                                  |                                       |
| `serviceAccount.create`             | Create a service account for all created ressources                              | `false`                               |
