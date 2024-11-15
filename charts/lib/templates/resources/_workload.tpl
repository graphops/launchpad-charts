{{ define "lib.resources.workload" }}
resourceKeys:
  - workload
{{- end }}

{{ define "lib.resources.workload.defaults" }}
{{ print `
apiVersion: v1
kind: Deployment
metadata:
  name: test
  namespace: '{{ .Root.Release.Namespace }}'
spec:
  replicas: 1
` }}
{{- end }}

{{ define "lib.resources.workload.render" }}

{{- end }}
