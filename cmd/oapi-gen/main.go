package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"github.com/Masterminds/sprig"
	"github.com/getkin/kin-openapi/openapi3"
)

func main() {
	var (
		o string
		t string
	)
	flags := flag.NewFlagSet("", flag.ContinueOnError)
	flags.StringVar(&o, "o", "", "openapi yaml or json file path")
	flags.StringVar(&t, "t", "", "template file path")
	if err := flags.Parse(os.Args[1:]); err != nil {
		flags.Usage()
		return
	}
	if o == "" || t == "" {
		flags.Usage()
		return
	}
	body, err := loadOpenAPI(o)
	if err != nil {
		panic(err)
	}
	funcMap := sprig.GenericFuncMap()
	funcMap["NonExplodeParams"] = func(params openapi3.Parameters) *openapi3.Parameters {
		nep := openapi3.Parameters{}
		for _, p := range params {
			if p.Value.Explode != nil && *p.Value.Explode {
				continue
			}
			nep = append(nep, p)
		}
		return &nep

	}
	funcMap["ExplodeParams"] = func(params openapi3.Parameters) *openapi3.Parameters {
		nep := openapi3.Parameters{}
		for _, p := range params {
			if p.Value.Explode != nil && *p.Value.Explode {
				nep = append(nep, p)
			}
		}
		return &nep

	}
	funcMap["paramsToJSON"] = func(params *openapi3.Parameters) string {
		b := "{"
		for i, v := range *params {
			if i == len(*params)-1 {
				b = fmt.Sprintf("%s\"%s\":\"%s\"", b, v.Value.Name, v.Value.Name)
			} else {
				b = fmt.Sprintf("%s\"%s\":\"%s\",", b, v.Value.Name, v.Value.Name)
			}
		}
		b = b + "}"
		return b
	}
	funcMap["json"] = func(i interface{}) string {
		b, err := json.Marshal(i)
		if err != nil {
			panic(err)
		}
		return string(b)
	}
	b, err := read(t)
	if err != nil {
		panic(err)
	}

	tpl := template.Must(template.New(t).Funcs(template.FuncMap(funcMap)).Parse(string(b)))
	tpl.Execute(os.Stdout, *body)
}
func read(file string) ([]byte, error) {
	b, err := ioutil.ReadFile(file)
	if err != nil {
		return nil, err
	}
	return b, nil
}
func loadOpenAPI(filePath string) (*openapi3.Swagger, error) {
	data, err := read(filePath)
	if err != nil {
		return nil, err
	}

	var swagger *openapi3.Swagger
	ext := filepath.Ext(filePath)
	ext = strings.ToLower(ext)
	switch ext {
	case ".yaml", ".yml":
		swagger, err = openapi3.NewSwaggerLoader().LoadSwaggerFromData(data)
	case ".json":
		swagger = &openapi3.Swagger{}
		err = json.Unmarshal(data, swagger)
	default:
		return nil, fmt.Errorf("%s is not a supported extension, use .yaml, .yml or .json", ext)
	}
	if err != nil {
		return nil, err
	}
	return swagger, nil
}
