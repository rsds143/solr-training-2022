{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "datastax-dse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datastax-dse.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "datastax-dse.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
create major version to help chose which yamls to use
*/}}
{{- define "datastax-dse.version" -}}
{{- printf "%s" .Values.image.tag | trunc 3 -}}
{{- end -}}

{{/*
dse path
*/}}
{{- define "datastax-dse.filevg-dse" -}}
{{- printf "files/%s/dse/*" (include "datastax-dse.version" .) -}}
{{- end -}}

{{/*
cass path
*/}}
{{- define "datastax-dse.filevg-cass" -}}
{{- printf "files/%s/cassandra/*" (include "datastax-dse.version" .) -}}
{{- end -}}

{{/*
spark path
*/}}
{{- define "datastax-dse.filevg-spark" -}}
{{- printf "files/%s/spark/*" (include "datastax-dse.version" .) -}}
{{- end -}}
