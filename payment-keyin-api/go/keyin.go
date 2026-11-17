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

// Approval -
type Approval struct {
	OrderId             string `json:"orderId"`
	OrderName           string `json:"orderName"`
	Amount              string `json:"amount"`
	CardNumber          string `json:"cardNumber"`
	CardExpirationYear  string `json:"cardExpirationYear"`
	CardExpirationMonth string `json:"cardExpirationMonth"`
	CardPassword        string `json:"cardPassword"`
	CustomerBirthday    string `json:"customerBirthday"`
	CardInstallmentPlan string `json:"cardInstallmentPlan"`
	TaxFreeAmount       string `json:"taxFreeAmount"`
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

func cancelReqHandler(w http.ResponseWriter, r *http.Request) {

	fmt.Fprintf(w, "keyin 결제 API.\n")

	orderId := "es_test_20220707_001"
	orderName := "토스-슬리퍼 외 2건"
	amount := "200"
	cardNumber := ""
	cardExpirationYear := ""
	cardExpirationMonth := ""
	cardPassword := ""
	customerBirthday := ""
	cardInstallmentPlan := "0"
	taxFreeAmount := "0"

	// Request Parameter json 형태로 셋팅
	approval := Approval{orderId, orderName, amount, cardNumber, cardExpirationYear, cardExpirationMonth, cardPassword, customerBirthday, cardInstallmentPlan, taxFreeAmount}
	pbytes, _ := json.Marshal(approval)

	buff := bytes.NewBuffer(pbytes)

	client := &http.Client{
		Transport: nil,
		Jar:       nil,
		Timeout:   0,
	}

	req, err := http.NewRequest("POST", "https://api.tosspayments.com/v1/payments/key-in/", buff)
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
	fmt.Fprintf(w, "\n\n== keyin 카드 결제 응답 결과 ==\n")
	fmt.Fprintf(w, string(data))
}

func main() {
	http.HandleFunc("/", cancelReqHandler)
	log.Fatal(http.ListenAndServe(":9090", nil))
}
