package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
)

var paymentKey string = ""

// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
var secretKey = envOrDefault("TOSS_SECRET_KEY", "{SECRET_KEY}")

func envOrDefault(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

// 응답 전체 대신 화면에 필요한 필드만 보여 줘요. 중첩 필드는 "virtualAccount.accountNumber" 처럼 적어요.
func writeSummary(w http.ResponseWriter, statusCode int, data []byte, fields ...string) {
	var result map[string]interface{}
	if err := json.Unmarshal(data, &result); err != nil {
		fmt.Fprintf(w, "응답을 읽지 못했어요.\n")
		return
	}
	if statusCode != http.StatusOK {
		fmt.Fprintf(w, "code: %v\nmessage: %v\n", result["code"], result["message"])
		return
	}
	for _, field := range fields {
		var value interface{} = result
		for _, key := range strings.Split(field, ".") {
			object, ok := value.(map[string]interface{})
			if !ok {
				value = nil
				break
			}
			value = object[key]
		}
		fmt.Fprintf(w, "%s: %v\n", field, value)
	}
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

func inquiryHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")

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
	fmt.Fprintf(w, "\n\n== 거래 조회 결과 ==\n")
	writeSummary(w, resp.StatusCode, data, "orderId", "orderName", "method", "status")
}

func main() {
	http.HandleFunc("/", inquiryHandler)
	log.Fatal(http.ListenAndServe(":9090", nil))
}
