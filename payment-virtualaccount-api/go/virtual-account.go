package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

const secretKey string = "{SECRET_KEY}"

// VirtualAccount -
type VirtualAccount struct {
	OrderId      string `json:"orderId"`
	OrderName    string `json:"orderName"`
	Amount       string `json:"amount"`
	CustomerName string `json:"customerName"`
	Bank         string `json:"bank"`
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

func virtualAccountHandler(w http.ResponseWriter, r *http.Request) {

	fmt.Fprintf(w, "가상계좌 발급 요청 API.\n")

	orderId := "es_test_20220707_001"
	orderName := "토스-슬리퍼 외 2건"
	amount := "200"
	customerName := "프로페서신"
	bank := "국민"

	// Request Parameter json 형태로 셋팅
	va := VirtualAccount{orderId, orderName, amount, customerName, bank}
	pbytes, _ := json.Marshal(va)

	buff := bytes.NewBuffer(pbytes)

	client := &http.Client{
		Transport: nil,
		Jar:       nil,
		Timeout:   0,
	}

	req, err := http.NewRequest("POST", "https://api.tosspayments.com/v1/virtual-accounts", buff)
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
	fmt.Fprintf(w, "\n\n== 가상계좌 발급 요청 응답 결과 ==\n")
	fmt.Fprintf(w, string(data))
}

func main() {
	http.HandleFunc("/", virtualAccountHandler)
	log.Fatal(http.ListenAndServe(":9090", nil))
}
