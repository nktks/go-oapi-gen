// for my sample script
{{- range $k, $v  := .Paths }}
{{- if $v.Post }}
{{- $nep := (NonExplodeParams $v.Post.Parameters) -}}
{{- $c := $v.Post.RequestBody -}}
{{- if $c }}
{{- $d := index $c.Value.Content "application/json" -}}
post(self, '{{ $k }}', {{"{"}}{{- range $i, $n  := $nep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}},{{- json $d.Schema.Value.Example -}})
{{- else }}
post(self, '{{ $k }}', {{"{"}}{{- range $i, $n  := $nep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}}, {})
{{- end }}
{{ end }}
{{- if $v.Get }}
{{- $nep := (NonExplodeParams $v.Get.Parameters) -}}
{{- $ep := (ExplodeParams $v.Get.Parameters) -}}
get(self, '{{ $k }}', {{"{"}}{{- range $i, $n  := $nep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}}, {{"{"}}{{- range $i, $n  := $ep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}})
{{ end }}
{{- if $v.Patch }}
{{- $nep := (NonExplodeParams $v.Patch.Parameters) -}}
{{- $ep := (ExplodeParams $v.Patch.Parameters) -}}
patch(self, '{{ $k }}', {{"{"}}{{- range $i, $n  := $nep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}}, {{"{"}}{{- range $i, $n  := $ep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}})
{{ end }}
{{- if $v.Delete }}
{{- $nep := (NonExplodeParams $v.Delete.Parameters) -}}
{{- $ep := (ExplodeParams $v.Delete.Parameters) -}}
delete(self, '{{ $k }}', {{"{"}}{{- range $i, $n  := $nep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}}, {{"{"}}{{- range $i, $n  := $ep -}}'{{ $n.Value.Name }}':'{{ $n.Value.Name }}',{{- end -}}{{"}"}})
{{ end }}
{{- end }}
