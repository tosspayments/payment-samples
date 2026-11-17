package main

import (
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

var paymentKey string = ""

const secretKey string = "{SECRET_KEY}"

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

func inquiryHandler(w http.ResponseWriter, r *http.Request) {

	fmt.Fprintf(w, "거래 조회 API.\n")

	client := &http.Client{
		Transport: nil,
		Jar:       nil,
		Timeout:   0,
	}

	req, err := http.NewRequest("GET", "https://api.tosspayments.com/v1/payments/"+paymentKey, nil)
	req.Header.Add("Authorization", "Basic "+basicAuth(secretKey, ""))
	req.Header.Add("Content-Type", "application/json")
	resp, err := client.Do(req)

	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(data))
	fmt.Fprintf(w, "\n\n== 거래 조회 결과 ==\n")
	fmt.Fprintf(w, string(data))
}

func main() {
	http.HandleFunc("/", inquiryHandler)
	log.Fatal(http.ListenAndServe(":9090", nil))
}
