# Hubot Kubernetes Bot
Hubot bot that communicates with the Kubernetes environment where the bot is running.

Uses config mounted in the Hubot pod as described in https://kubernetes.io/docs/tasks/run-application/access-api-from-pod/#directly-accessing-the-rest-api

To allow Hubot to access resources in other namespaces, run the Hubot pod with a service account that has permission to do that.

### Configuration:
- `HUBOT_K8S_DEFAULT_NAMESPACE` - Default namespace in Kubernetes
- `HUBOT_K8S_CONSOLE` - URL of the web console

### Commands:

All commands operate in the currently selected namespace and context. All commands with label selectors accept it in the form `label=value`.

#### Display Current Kubernetes Namespace
> k8s namespace|ns

#### Switching Kubernetes Namespace
> k8s namespace|ns `<namespace>`

#### List Deployments
> k8s deployments|deploy [`<labelSelector>`]

#### List Services
> k8s services|svc [`<labelSelector>`]

#### List Cron Jobs
> k8s cronjobs [`<labelSelector>`]

#### List Jobs
> k8s jobs [`<labelSelector>`]

#### Get logs from a pod
> k8s logs|log `<pod name>`
