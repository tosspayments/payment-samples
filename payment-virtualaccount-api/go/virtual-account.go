package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
)

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
	// 가상계좌 발급은 버튼을 눌러 POST 로 요청할 때만 실행해요.
	if r.Method == http.MethodGet {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprint(w, `<form method="post" action="/virtual-account"><button type="submit">가상계좌 발급</button></form>`)
		return
	}
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")

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
	fmt.Fprintf(w, "\n\n== 가상계좌 발급 요청 응답 결과 ==\n")
	writeSummary(w, resp.StatusCode, data, "orderId", "orderName", "status", "virtualAccount.bank", "virtualAccount.accountNumber", "virtualAccount.dueDate")
}

func main() {
	http.HandleFunc("/virtual-account", virtualAccountHandler)
	log.Fatal(http.ListenAndServe(":9090", nil))
}
