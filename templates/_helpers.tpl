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
{{- if .Values.gateway.tag -}}
{{- printf "%s:%s" .Values.gateway.image .Values.gateway.tag -}}
{{- else -}}
{{- .Values.gateway.image -}}
{{- end -}}
{{- end }}
