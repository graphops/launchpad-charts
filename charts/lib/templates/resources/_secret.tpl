{{ define "lib.resources.secret" }}
resourceKeys:
  - secret
  - secrets
{{- end }}

{{ define "lib.resources.secret.defaults" }}
{{ print `
apiVersion: v1
kind: Secret
metadata:
  name: test
  namespace: '{{ .Root.Release.Namespace }}'
type: Opaque
data: {}
` }}
{{- end }}
