package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"time"
)

// struct 정의
type datas struct {
	Data    string `json:"data"`
	Version string `json:"version"`
}

func Index(wr http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		fmt.Println("requested: /")
		hostname, _ := os.Hostname()
		d1 := datas{Data: "Welcome! " + hostname, Version: "v3.0"}
		res, _ := json.Marshal(d1)
		fmt.Fprintln(wr, string(res))
		fmt.Println(string(res))
	}
}

func main() {
	pid := os.Getpid()
	fmt.Println("pid", pid)

	server := &http.Server{Addr: ":8080"}

	http.HandleFunc("/", Index)

	go func() {
		if err := server.ListenAndServe(); err != nil {
			// handle err
		}
	}()

	// Setting up signal capturing
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt)

	// Waiting for SIGINT (kill -2)
	<-stop

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	fmt.Println("exit")
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		// handle err
	}

	// Wait for ListenAndServe goroutine to close.
}
