{{/*
Expand the name of the chart.
*/}}
{{- define "directus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "directus.releasename" -}}
{{- default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "directus.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified name for the database.
This is the fullname truncated to 50 characters and with the suffix "-db" appended.
*/}}
{{- define "directus.dbname" -}}
{{- include "directus.fullname" . | trunc 50 | trimSuffix "-" }}-db
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "directus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "directus.domain" -}}
{{- if .Values.ingress.domain }}
{{- .Values.ingress.domain }}
{{- else }}
{{ include "directus.releasename" . }}.{{ .Values.ingress.parentDomain }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "directus.labels" -}}
helm.sh/chart: {{ include "directus.chart" . }}
{{ include "directus.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "directus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "directus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "directus.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "directus.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}