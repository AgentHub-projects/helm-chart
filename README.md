# agenthub-gateway Helm chart

Deploy `agenthub-gateway` with Agent Sandbox RBAC, shared config, sandbox templates, and a Traefik `IngressRoute`.

```sh
helm install agenthub-gateway . \
  --namespace agenthub \
  --create-namespace \
  --set gateway.image=agenthub-gateway \
  --set gateway.tag=v0.1.0-beta.61 \
  --set ingressRoute.entryPoint=web \
  --set sandboxTemplates.sandbox.image=registry.k8s.io/e2e-test-images/echoserver:2.5 \
  --set sandboxTemplates.agent.image=agentadaptor:latest \
  --set appConfig.agentadaptor.port=8080 \
  --set appConfig.agentadaptor.workspaceRoot=/workspace \
  --set appConfig.agentadaptor.codexApiKey="$CODEX_API_KEY" \
  --set appConfig.agentadaptor.anthropicApiKey="$ANTHROPIC_API_KEY" \
  --set appConfig.postgres.host=postgresql.postgresql.svc.cluster.local \
  --set appConfig.postgres.port=5432 \
  --set appConfig.postgres.password=agenthub \
  --set appConfig.sandbox.namespace=sandbox \
  --set appConfig.sandbox.agentselector=agent \
  --set appConfig.sandbox.sandboxselector=sandbox
```

Gateway mounts its own `config.yaml` from the release ConfigMap at `/etc/agenthub-gateway/config.yaml`. `appConfig.agentadaptor` is excluded from that gateway ConfigMap.

The chart also creates two `SandboxTemplate` resources in the sandbox namespace: one labeled `sandbox: sandbox`, and one labeled `agent: agent`.

Gateway resolves agent and sandbox templates with `appConfig.sandbox.agentselector` and `appConfig.sandbox.sandboxselector`.

The `agent` template mounts a separate `agentadaptor` ConfigMap at `/etc/agentadaptor/config.json`. It is rendered from `appConfig.agentadaptor`. `agentType` and `role` are injected after startup through `/init`; they are not Helm config. API keys can be declared as `appConfig.agentadaptor.codexApiKey` and `appConfig.agentadaptor.anthropicApiKey`; they are rendered into that separate ConfigMap, so do not commit real values to git.

Each template has a matching `SandboxWarmPool` controlled by `sandboxTemplates.<name>.warmPool.replicas`.

The Traefik `IngressRoute` has fixed routes for `/socket.io` and `/filesystem`, both forwarding to the same gateway Service.
