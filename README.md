# agenthub-gateway Helm chart

Deploy `agenthub-gateway` and the AgentHub Fullstack frontend/backend with Agent Sandbox RBAC, shared config, sandbox templates, and a Traefik `IngressRoute`.

```sh
helm install agenthub-gateway . \
  --namespace agenthub \
  --create-namespace \
  --set appConfig.gateway.image=agenthub-gateway \
  --set appConfig.gateway.tag=v0.1.0-beta.61 \
  --set ingressRoute.entryPoint=web \
  --set sandboxTemplates.sandbox.image=registry.k8s.io/e2e-test-images/echoserver:2.5 \
  --set sandboxTemplates.agent.image=agentadaptor:latest \
  --set appConfig.agentadaptor.port=8080 \
  --set appConfig.agentadaptor.openCodeModel=anthropic/claude-sonnet-4-5 \
  --set appConfig.agentadaptor.claudeApiKey="$CLAUDE_API_KEY" \
  --set appConfig.agentadaptor.anthropicApiKey="$ANTHROPIC_API_KEY" \
  --set appConfig.agentadaptor.anthropicBaseUrl="$ANTHROPIC_BASE_URL" \
  --set appConfig.agentadaptor.imageGenerationModel=gemini-3.1-flash-image-preview \
  --set appConfig.postgres.host=postgresql.postgresql.svc.cluster.local \
  --set appConfig.postgres.port=5432 \
  --set appConfig.postgres.password=agenthub \
  --set appConfig.sandbox.namespace=sandbox \
  --set appConfig.sandbox.agentselector=agent \
  --set appConfig.sandbox.sandboxselector=sandbox
```

Gateway mounts its own `config.yaml` from the release ConfigMap at `/etc/agenthub-gateway/config.yaml`. `appConfig.agentadaptor` is excluded from that gateway ConfigMap.

The Fullstack backend gets non-secret environment variables from `fullstack.backend.configEnv` and secrets from `fullstack.backend.secretEnv`. If `fullstack.backend.databaseUrl` is empty, the chart derives `DATABASE_URL` from `appConfig.postgres`. If `DOWNSTREAM_ORCHESTRATOR_WS_URL` is empty, it is rendered as the in-cluster gateway URL. OSS settings are rendered from `appConfig.oss`.

The Fullstack frontend image serves only the static Next.js build through Nginx. API and realtime routing are handled by the chart's Traefik `IngressRoute`. The frontend realtime Socket.IO path is `/api/socket.io`, leaving the gateway ACP `/socket.io` route unchanged.

The chart also creates two `SandboxTemplate` resources in the sandbox namespace: one labeled `sandbox: sandbox`, and one labeled `agent: agent`.

Gateway resolves agent and sandbox templates with `appConfig.sandbox.agentselector` and `appConfig.sandbox.sandboxselector`.

When `pullSecret` is set, the same image pull secret is referenced by the gateway Deployment and both sandbox templates. Because Kubernetes secrets are namespaced, create the secret in the release namespace and in `appConfig.sandbox.namespace` if sandbox or agent images are private.

The `sandbox` template always runs the workspace sidecar. Fixed sidecar runtime settings live in a ConfigMap, the Pod mounts a shared `/sandbox` volume, and Pod labels are exposed through downward API at `/etc/podmeta`. The sidecar restores the MinIO workspace into its local `/workspace/sessions/${session_id}` source path, then projects it to `/sandbox/views/workspace`; the sandbox image uses `/sandbox/views/workspace/repo` and `/sandbox/views/workspace/worktrees` as its defaults.

`sandboxTemplates.sandbox.terminationGracePeriodSeconds` controls how long Kubernetes waits before killing the Pod. `sandboxTemplates.sandbox.sidecar.flushTimeoutSeconds` should stay lower than that value, so the sidecar can finish or fail its MinIO flush before kubelet sends `SIGKILL`.

The `agent` template mounts a separate `agentadaptor` ConfigMap at `/etc/agentadaptor/config.json`. It is rendered from `appConfig.agentadaptor`, plus Aliyun OSS settings from `appConfig.oss` for image previews. `agentType` and `role` are injected after startup through `/init`; they are not Helm config. API keys, relay settings, and image generation settings, including `appConfig.agentadaptor.claudeApiKey`, `appConfig.agentadaptor.anthropicApiKey`, `appConfig.agentadaptor.anthropicBaseUrl`, and `appConfig.agentadaptor.imageGenerationModel`, are rendered into that ConfigMap. `claudeApiKey` is used by the main Claude/opencode model first; if it is empty, the adaptor falls back to `anthropicApiKey` for compatibility.

Create the key in Anthropic Console: https://console.anthropic.com/settings/keys

Each template has a matching `SandboxWarmPool` controlled by `sandboxTemplates.<name>.warmPool.replicas`.

The Traefik `IngressRoute` keeps `/socket.io` and `/filesystem` on the gateway Service, adds `/api` for the Fullstack backend, and sends `/` to the Fullstack frontend.
