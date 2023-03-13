/*
Copyright 2018 Kubedge

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"flag"
	"log"
	"net/http"
	"path/filepath"
	"strings"
)

var (
	listen = flag.String("listen", ":8080", "listen address")
	dir    = flag.String("dir", "webapp2", "directory to serve")
	prefix = flag.String("p", "/", "prefix path under")
)

func sayHello(w http.ResponseWriter, r *http.Request) {
	message := r.URL.Path
	message = strings.TrimPrefix(message, "/")
	message = "Hello " + message
	w.Write([]byte(message))
}

func main() {
	flag.Parse()

	var err error
	*dir, err = filepath.Abs(*dir)
	if err != nil {
		log.Fatalln(err)
	}
	log.Printf("serving %s as %s on %s", *dir, *prefix, *listen)

	// http.HandleFunc("/", sayHello)
	// if err := http.ListenAndServe(":8080", nil); err != nil {
	//		panic(err)
	// }

	http.Handle(*prefix, http.StripPrefix(*prefix, http.FileServer(http.Dir(*dir))))

	logger := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s %s", r.RemoteAddr, r.Method, r.URL)
		http.DefaultServeMux.ServeHTTP(w, r)
	})

	// err := http.ListenAndServe(*listen, http.FileServer(http.Dir(*dir)))
	err = http.ListenAndServe(*listen, logger)
	if err != nil {
		log.Fatalln(err)
	}
}
