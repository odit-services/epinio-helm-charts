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
{{- include "directus.fullname" . | trunc 45 | trimSuffix "-" }}-db
{{- end }}

{{- define "directus.backupbucket.name" -}}
{{- include "directus.fullname" . | trunc 45 | trimSuffix "-" }}-backup
{{- end }}

{{- define "directus.backupbucket.secret" -}}
{{- include "directus.backupbucket.name" . }}-s3creds
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "directus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "directus.domain" -}}
{{- if .Values.ingress.domain }}{{- .Values.ingress.domain }}{{- else }}{{ include "directus.releasename" . }}.{{ .Values.ingress.parentDomain }}{{- end }}
{{- end }}

{{- define "directus.url" -}}
https://{{ include "directus.domain" . }}
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
Common labels
*/}}
{{- define "directus.backup.labels" -}}
helm.sh/chart: {{ include "directus.chart" . }}
{{ include "directus.backup.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "directus.backup.selectorLabels" -}}
app.kubernetes.io/name: "{{ include "directus.name" . }}-backup"
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

{{/*
Renders a liveness or readiness probe for the directus container.
Directus 12 requires authentication for /server/health, so the public /server/ping is used by default.
Usage: include "directus.probe" (dict "root" . "probe" .Values.livelinessProbe)
*/}}
{{- define "directus.probe" -}}
{{- $probe := .probe -}}
{{- $url := printf "http://127.0.0.1:%v%v" .root.Values.service.port ($probe.path | default "/server/ping") -}}
exec:
  command:
    - /bin/sh
    - -c
    - {{ printf "wget -qO- '%s' | grep -q '%s' && exit 0 || exit 1" $url ($probe.expectedResponse | default "pong") | quote }}
initialDelaySeconds: {{ $probe.initialDelaySeconds | default 10 }}
periodSeconds: {{ $probe.periodSeconds | default 10 }}
timeoutSeconds: {{ $probe.timeoutSeconds | default 5 }}
failureThreshold: {{ $probe.failureThreshold | default 3 }}
{{- end }}

{{/*
This function validates replica count rules
*/}}
{{- define "directus.backup.postgresMethod" -}}
{{- dig "postgres" "method" "appleboy" .Values.backup | toString | lower }}
{{- end }}

{{/*
Converts the shared backup.schedule (5-field cron for appleboy) to a 6-field cron for CNPG ScheduledBackup.
- descriptors starting with "@" are passed through
- 5-field crons get "0 " prepended (seconds=0)
- 6-field crons are passed through
*/}}
{{- define "directus.backup.cnpgSchedule" -}}
{{- $schedule := .Values.backup.schedule | toString | trim -}}
{{- if hasPrefix "@" $schedule -}}
{{- $schedule -}}
{{- else -}}
{{- $fields := splitList " " $schedule -}}
{{- $count := len $fields -}}
{{- if eq $count 5 -}}
{{- printf "0 %s" $schedule -}}
{{- else -}}
{{- $schedule -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "validate.values" -}}
{{- $method := include "directus.backup.postgresMethod" . -}}
{{- if and .Values.backup.enabled (not (or (eq $method "appleboy") (eq $method "cnpg-plugin"))) -}}
{{- fail "backup.postgres.method must be either \"appleboy\" or \"cnpg-plugin\"" -}}
{{- end -}}
{{- if eq .Values.chartValidation.disableAccessmodeValidation false}}
{{- if and (gt (int .Values.replicaCount) 1) (and (eq .Values.persistence.enabled true) (ne .Values.persistence.accessMode "ReadWriteMany")) -}}
{{- fail "Multiple replicas is only allowed for RWX volumes if persistence is enabled" -}}
{{- end -}}
{{- end -}}
{{- if eq .Values.chartValidation.disableDatabaseValidation false}}
{{- if and (gt (int .Values.replicaCount) 1) (eq .Values.postgres.enabled false) -}}
{{- fail "Multiple replicas is only allowed when postgres is the database" -}}
{{- end -}}
{{- if and (not .Values.postgres.image) (not .Values.postgres.majorVersion) -}}
{{- fail "You have to set major version and optionally image version " -}}
{{- end -}}
{{- end -}}
{{- end -}}