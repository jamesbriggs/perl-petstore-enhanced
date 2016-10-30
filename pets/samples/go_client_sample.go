///bin/true; exec /usr/bin/env go run "$0" "$@"

// Program: go_client_sample.go
// Purpose: Go language sample client program for Perl Petstore Enhanced API Server
// Copyright: James Briggs USA 2016
// Env: Go
// Returns: exit status is non-zero on failure
// Usage: go run go_client_sample.go
// Notes: first do, source ../set.sh
// Also: this project looks nice too: https://github.com/parnurzeal/gorequest
// See: for http status code methods, see https://golang.org/pkg/net/http/

package main

import (
        "bytes"
        "encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
        "net/http/httputil"
	"os"
        "strconv"
	"time"
)

func debug(data []byte, err error) {
    if err == nil {
       fmt.Printf("%s\n\n", data)
    } else {
       log.Fatalf("%s\n\n", err)
    }
}

// global variables for communicating with callback redirect function redirectPolicyFunc()
var g_username = "";
var g_password = "";

func redirectPolicyFunc(req *http.Request, via []*http.Request) error {
   req.SetBasicAuth(g_username, g_password)
   return nil
}

func main() {

   type Pet struct { // if you want to understand this, see https://golang.org/pkg/encoding/json/#Marshal
      Name string `json:"name"`
   }

   username := os.Getenv("PETS_USER")
   password := os.Getenv("PETS_PASSWORD")

   admin_username := os.Getenv("PETS_ADMIN_USER")
   admin_password := os.Getenv("PETS_ADMIN_PASSWORD")

   domain   := os.Getenv("PETS_DOMAIN")
   base_url := os.Getenv("PETS_BASE_URL")
   scheme   := os.Getenv("PETS_SCHEME")

   Debug    := (os.Getenv("PETS_DEBUG") == "1")

   // see https://golang.org/pkg/time/ for how time casts work
   timeout, err := strconv.Atoi(os.Getenv("PETS_TIMEOUT"))
   if err != nil {
      log.Fatal(err)
   }

   url := scheme + domain + base_url

   client := &http.Client{
      Timeout: time.Duration(timeout) * time.Second,
      CheckRedirect: redirectPolicyFunc,
   }

   g_username = username
   g_password = password

   {
      fmt.Printf("%s\n", "Get list of pets")

      req, err := http.NewRequest("GET", url + "/pets", nil)
      req.SetBasicAuth(g_username, g_password)

      if Debug { debug(httputil.DumpRequestOut(req, true)) }

      res, err := client.Do(req)

      if err != nil {
         log.Fatal(err)
         debug(httputil.DumpResponse(res, true))
      } else {
         defer res.Body.Close()
         if Debug { debug(httputil.DumpResponse(res, true)) }
         body, err := ioutil.ReadAll(res.Body)
         if err == nil {
            fmt.Printf("%s\n", body)
         }
      }
   }

   {
      fmt.Printf("%s\n", "Get one pet")

      req, err := http.NewRequest("GET", url + "/pets/1", nil)
      req.SetBasicAuth(g_username, g_password)
      if Debug { debug(httputil.DumpRequestOut(req, true)) }

      res, err := client.Do(req)

      if err != nil {
         log.Fatal(err)
         debug(httputil.DumpResponse(res, true))
      } else {
         defer res.Body.Close()
         if Debug { debug(httputil.DumpResponse(res, true)) }
         body, err := ioutil.ReadAll(res.Body)
         if err == nil {
            fmt.Printf("%s\n", body)
         }
      }
   }

   {
      fmt.Printf("%s\n", "Add one pet")

//    to avoid using the the overly-complicated "encoding/json" marshaling
//    var data = []byte(`{"name":"zebra"}`)

      m := Pet{Name: "zebra"}
      b, err := json.Marshal(m)
      data := bytes.NewBuffer(b)

      req, err := http.NewRequest("PUT", url + "/pets", data)

      req.Header.Set("Content-Type", "application/json")
      req.SetBasicAuth(g_username, g_password)
      if Debug { debug(httputil.DumpRequestOut(req, true)) }

      res, err := client.Do(req)
      if err != nil {
         log.Fatal(err)
         debug(httputil.DumpResponse(res, true))
      } else {
         defer res.Body.Close()
         if Debug { debug(httputil.DumpResponse(res, true)) }
         body, err := ioutil.ReadAll(res.Body)
         if err == nil {
            fmt.Printf("%s\n", body)
         }
      }
      location := res.Header.Get("Location")
      if Debug { debug(httputil.DumpResponse(res, true)) }

      fmt.Printf("%s %d %s\n", "HTTP status code is", res.StatusCode, location)

      if (err == nil) && (res.StatusCode == http.StatusCreated) {
         fmt.Printf("%s\n", "Try to delete new pet")

         req, err = http.NewRequest("DELETE", location, nil)
         req.SetBasicAuth(g_username, g_password)
         if Debug { debug(httputil.DumpRequestOut(req, true)) }

         res, err = client.Do(req)

         if err != nil {
            log.Fatal(err)
            debug(httputil.DumpResponse(res, true))
          } else {
            defer res.Body.Close()
            if Debug { debug(httputil.DumpResponse(res, true)) }
            body, err := ioutil.ReadAll(res.Body)
            fmt.Printf("%s %d\n", "HTTP status code is", res.StatusCode)
            if (err == nil && res.StatusCode == http.StatusOK) {
               fmt.Printf("%s\n", body)
            }
         }
      }
   }

   // Admin requests, so switch to admin credentials

   g_username = admin_username
   g_password = admin_password

   {
      fmt.Printf("%s\n", "Do health check")

      req, err := http.NewRequest("GET", url + "/admin/ping", nil)
      req.SetBasicAuth(g_username, g_password)
      if Debug { debug(httputil.DumpRequestOut(req, true)) }

      res, err := client.Do(req)

      if err != nil {
         log.Fatal(err)
         debug(httputil.DumpResponse(res, true))
      } else {
         defer res.Body.Close()
         if Debug { debug(httputil.DumpResponse(res, true)) }
         body, err := ioutil.ReadAll(res.Body)
         if err == nil {
            fmt.Printf("%s\n", body)
         }
      }
   }

   os.Exit(0);
}

