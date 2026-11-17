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

var paymentKey string = ""

const secretKey string = "{SECRET_KEY}"

// Cancellation -
type Cancellation struct {
	CancelReason string `json:"cancelReason"`
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

func cancelReqHandler(w http.ResponseWriter, r *http.Request) {

	fmt.Fprintf(w, "결제 취소.\n")
	cancelReason := "결제 취소 사유를 넣으세요."

	// Request Parameter json 형태로 셋팅
	cancellation := Cancellation{cancelReason}
	pbytes, _ := json.Marshal(cancellation)

	buff := bytes.NewBuffer(pbytes)

	client := &http.Client{
		Transport: nil,
		Jar:       nil,
		Timeout:   0,
	}

	req, err := http.NewRequest("POST", "https://api.tosspayments.com/v1/payments/"+paymentKey+"/cancel", buff)
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
	fmt.Fprintf(w, "\n\n== 취소 응답 결과 ==\n")
	fmt.Fprintf(w, string(data))
}

func main() {
	http.HandleFunc("/", cancelReqHandler)
	log.Fatal(http.ListenAndServe(":9090", nil))
}
