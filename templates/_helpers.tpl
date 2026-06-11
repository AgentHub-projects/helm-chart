{{/*
Expand the chart name.
*/}}
{{- define "agenthub-gateway.name" -}}
agenthub-gateway
{{- end }}

{{/*
Create a release-aware name.
*/}}
{{- define "agenthub-gateway.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Chart label.
*/}}
{{- define "agenthub-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "agenthub-gateway.labels" -}}
helm.sh/chart: {{ include "agenthub-gateway.chart" . }}
app.kubernetes.io/name: {{ include "agenthub-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "agenthub-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "agenthub-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Namespace where Agent Sandbox extension resources live.
*/}}
{{- define "agenthub-gateway.sandboxNamespace" -}}
{{- .Values.appConfig.sandbox.namespace | default .Release.Namespace -}}
{{- end }}

{{/*
Gateway container image.
*/}}
{{- define "agenthub-gateway.image" -}}
{{- if .Values.appConfig.gateway.tag -}}
{{- printf "%s:%s" .Values.appConfig.gateway.image .Values.appConfig.gateway.tag -}}
{{- else -}}
{{- .Values.appConfig.gateway.image -}}
{{- end -}}
{{- end }}

{{/*
ConfigMap used by the sandbox sidecar and sandbox container.
*/}}
{{- define "agenthub-gateway.sidecarConfigMapName" -}}
{{- printf "%s-sidecar" (include "agenthub-gateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Fullstack frontend resource name.
*/}}
{{- define "agenthub-gateway.fullstackFrontendName" -}}
{{- printf "%s-frontend" (include "agenthub-gateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Fullstack backend resource name.
*/}}
{{- define "agenthub-gateway.fullstackBackendName" -}}
{{- printf "%s-backend" (include "agenthub-gateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Fullstack backend ConfigMap name.
*/}}
{{- define "agenthub-gateway.fullstackBackendConfigMapName" -}}
{{- printf "%s-backend-env" (include "agenthub-gateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Fullstack backend Secret name.
*/}}
{{- define "agenthub-gateway.fullstackBackendSecretName" -}}
{{- printf "%s-backend-secret" (include "agenthub-gateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Fullstack frontend container image.
*/}}
{{- define "agenthub-gateway.fullstackFrontendImage" -}}
{{- if .Values.fullstack.frontend.tag -}}
{{- printf "%s:%s" .Values.fullstack.frontend.image .Values.fullstack.frontend.tag -}}
{{- else -}}
{{- .Values.fullstack.frontend.image -}}
{{- end -}}
{{- end }}

{{/*
Fullstack backend container image.
*/}}
{{- define "agenthub-gateway.fullstackBackendImage" -}}
{{- if .Values.fullstack.backend.tag -}}
{{- printf "%s:%s" .Values.fullstack.backend.image .Values.fullstack.backend.tag -}}
{{- else -}}
{{- .Values.fullstack.backend.image -}}
{{- end -}}
{{- end }}

{{/*
Fullstack backend DATABASE_URL, defaulting to the chart's shared Postgres config.
*/}}
{{- define "agenthub-gateway.fullstackDatabaseUrl" -}}
{{- if .Values.fullstack.backend.databaseUrl -}}
{{- .Values.fullstack.backend.databaseUrl -}}
{{- else -}}
{{- printf "postgresql://%s:%s@%s:%v/%s?schema=public" .Values.appConfig.postgres.username .Values.appConfig.postgres.password .Values.appConfig.postgres.host .Values.appConfig.postgres.port .Values.appConfig.postgres.database -}}
{{- end -}}
{{- end }}
