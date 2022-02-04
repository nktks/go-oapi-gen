/*
 * for my sample k6 script
 */

import http from "k6/http";
import exec from "k6/execution";
import crypto from 'k6/crypto';
import { group, check, sleep } from "k6";
import { SharedArray } from "k6/data";
import { Trend } from "k6/metrics";
import { URL } from 'https://jslib.k6.io/url/1.0.0/index.js';
{{ $server := index .Servers 0 }}
const BASE_URL = "{{ $server.URL }}";
// Sleep duration between successive requests.
// You might want to edit the value of this variable or remove calls to the sleep function on the script.
const SLEEP_DURATION = 0.1;

// data for each vu
const data = new SharedArray("my dataset", function(){
    const ids = [
//        {'id':1, 'session':'session', 'name':'name1'},
    ];
    return ids;
});

export const options = {
  scenarios :{
    "use-all-the-data": {
      executor: "shared-iterations",
      vus: data.length,
      iterations: data.length,
      maxDuration: "30s"
    }
  }
}

const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')
function generateRandomString(length) {
  var b = crypto.randomBytes(length)
  var bb = new Uint8Array(b);
  return bb.reduce((p, i) => p + chars[(i % chars.length)], '')
}

function resolve_path(path, params) {
  for(const key in params) {
    path = path.replace('{'+key+'}', params[key])
  }
  return path
}

{{- range $k, $v  := .Paths }}
{{- $camelPath := (regexReplaceAll "/|{|}" $k "") | camelcase  }}
{{- if $v.Post }}
{{- if not $v.Post.Deprecated }}
var post{{ $camelPath }}Latency = new Trend("post{{ $k }}");
{{- end }}
{{- end }}

{{- if $v.Get }}
{{- if not $v.Get.Deprecated }}
var get{{ $camelPath }}Latency = new Trend("get:{{ $k }}");
{{- end }}
{{- end }}

{{- if $v.Patch }}
{{- if not $v.Patch.Deprecated }}
var patch{{ $camelPath }}Latency = new Trend("patch:{{ $k }}");
{{- end }}
{{- end }}

{{- if $v.Delete }}
{{- if not $v.Delete.Deprecated }}
var delete{{ $camelPath }}Latency = new Trend("delete:{{ $k }}");
{{- end }}
{{- end }}

{{- end }}
{
{{- range $k, $v  := .Paths }}
{{- $camelPath := (regexReplaceAll "/|{|}" $k "") | camelcase  }}

{{- if $v.Post }}
{{- if not $v.Post.Deprecated }}
{{- $nep := (NonExplodeParams $v.Post.Parameters) }}
{{- with $c := $v.Post.RequestBody }}
{{- with $d := index $c.Value.Content "application/json" }}

    group("post:{{ $k }}", () => {
        let url = resolve_path(BASE_URL + `{{ $k }}`, {{ $nep | paramsToJSON }});
        // TODO: edit the parameters of the request body.
        let body = {{ if $d.Schema.Value.Example }}{{ json $d.Schema.Value.Example }}{{ else }}{}{{ end }};
        var item = data[exec.scenario.iterationInTest];
{{- if $v.Post.Security }}
        let options = {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${item.session}`
          }
        };
{{- else }}
        let options = {
          headers: {
            "Content-Type": "application/json"
          }
        };
{{- end }}
        let request = http.post(url, body, options);
        post{{ $camelPath }}Latency.add(request.timings.duration);
        check(request, {
            "OK": (r) => r.status === 200
        });
        check(request, {
            "エラーレスポンス": (r) => r.status === 200
        });
        sleep(SLEEP_DURATION);
    });
{{- end }}
{{- end }}
{{- end }}
{{- end }}


{{- if $v.Get }}
{{- if not $v.Get.Deprecated }}
{{- $nep := (NonExplodeParams $v.Get.Parameters) }}
{{- $ep := (ExplodeParams $v.Get.Parameters) }}

    group("get:{{ $k }}", () => {
        let url = new URL(resolve_path(BASE_URL + `{{ $k }}`, {{ $nep | paramsToJSON }}));
{{- range $i, $n  := $ep }}
        url.searchParams.append('{{ $n.Value.Name }}', '{{ $n.Value.Name }}');
{{- end }}
        var item = data[exec.scenario.iterationInTest];
{{- if $v.Get.Security }}
        const options = {
          headers: {
            Authorization: `Bearer ${item.session}`
          }
        };
{{- else }}
        let options = {};
{{- end }}

        let request = http.get(url.toString(), options);
        get{{ $camelPath }}Latency.add(request.timings.duration);
        check(request, {
            "ok": (r) => r.status === 200
        });
        check(request, {
            "エラーレスポンス": (r) => r.status === 200
        });
        sleep(SLEEP_DURATION);
    });
{{- end }}
{{- end }}

{{- if $v.Patch }}
{{- if not $v.Patch.Deprecated }}
{{- $nep := (NonExplodeParams $v.Patch.Parameters) }}
{{- with $c := $v.Patch.RequestBody }}
{{- with $d := index $c.Value.Content "application/json" }}

    group("patch:{{ $k }}", () => {
        let url = resolve_path(BASE_URL + `{{ $k }}`, {{ $nep | paramsToJSON }});
        // TODO: edit the parameters of the request body.
        let body = {{ if $d.Schema.Value.Example }}{{ json $d.Schema.Value.Example }}{{ else }}{}{{ end }};
        var item = data[exec.scenario.iterationInTest];
{{- if $v.Patch.Security }}
        let options = {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${item.session}`
          }
        };
{{- else }}
        let options = {
          headers: {
            "Content-Type": "application/json"
          }
        };
{{- end }}
        let request = http.patch(url, body, options);
        patch{{ $camelPath }}Latency.add(request.timings.duration);
        check(request, {
            "OK": (r) => r.status === 200
        });
        check(request, {
            "エラーレスポンス": (r) => r.status === 200
        });
        sleep(SLEEP_DURATION);
    });
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- if $v.Delete }}
{{- if not $v.Delete.Deprecated }}
{{- $nep := (NonExplodeParams $v.Delete.Parameters) }}
{{- with $c := $v.Delete.RequestBody }}
{{- with $d := index $c.Value.Content "application/json" }}

    group("delete:{{ $k }}", () => {
        let url = resolve_path(BASE_URL + `{{ $k }}`, {{ $nep | paramsToJSON }});
        // TODO: edit the parameters of the request body.
        let body = {{ if $d.Schema.Value.Example }}{{ json $d.Schema.Value.Example }}{{ else }}{}{{ end }};
        var item = data[exec.scenario.iterationInTest];
{{- if $v.Delete.Security }}
        let options = {
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${item.session}`
          }
        };
{{- else }}
        let options = {
          headers: {
            "Content-Type": "application/json"
          }
        };
{{- end }}
        let request = http.del(url, body, options);
        delete{{ $camelPath }}Latency.add(request.timings.duration);
        check(request, {
            "OK": (r) => r.status === 200
        });
        check(request, {
            "エラーレスポンス": (r) => r.status === 200
        });
        sleep(SLEEP_DURATION);
    });
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- end }}