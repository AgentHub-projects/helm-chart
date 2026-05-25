# agenthub-gateway Helm chart

Deploy `agenthub-gateway` with Agent Sandbox RBAC, shared config, sandbox templates, and a Traefik `IngressRoute`.

```sh
helm install agenthub-gateway . \
  --namespace agenthub \
  --create-namespace \
  --set gateway.image=agenthub-gateway \
  --set gateway.tag=v0.1.0-beta.61 \
  --set ingressRoute.entryPoint=web \
  --set sandboxTemplates.sandbox.image=sandbox-runtime:latest \
  --set sandboxTemplates.agent.image=agent-runtime:latest \
  --set appConfig.postgres.host=mysql.mysql.svc.cluster.local \
  --set appConfig.postgres.port=3306 \
  --set appConfig.postgres.password=agenthub \
  --set appConfig.sandbox.namespace=agenthub
```

`appConfig` is rendered as a whole into the shared `config.yaml` ConfigMap and mounted at `/etc/agenthub-gateway/config.yaml`, matching the gateway Docker CMD.

The chart also creates two `SandboxTemplate` resources in the sandbox namespace: one labeled `sandbox: sandbox`, and one labeled `agent: agent`.

The Traefik `IngressRoute` has fixed routes for `/socket.io` and `/filesystem`, both forwarding to the same gateway Service.
