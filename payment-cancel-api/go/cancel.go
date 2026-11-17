package main

import (
	"bytes"
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
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

// 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 만들어요.
func newIdempotencyKey() string {
	buf := make([]byte, 16)
	rand.Read(buf)
	return hex.EncodeToString(buf)
}

// Cancellation -
type Cancellation struct {
	CancelReason string `json:"cancelReason"`
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

func cancelReqHandler(w http.ResponseWriter, r *http.Request) {
	// 결제 취소는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
	// TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
	// TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요.
	if r.Method == http.MethodGet {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprint(w, `<form method="post" action="/cancel"><button type="submit">결제 취소</button></form>`)
		return
	}
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")

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
	req.Header.Add("Idempotency-Key", newIdempotencyKey())
	resp, err := client.Do(req)

	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	fmt.Fprintf(w, "\n\n== 취소 응답 결과 ==\n")
	writeSummary(w, resp.StatusCode, data, "orderId", "orderName", "method", "status")
}

func main() {
	http.HandleFunc("/cancel", cancelReqHandler)
	log.Fatal(http.ListenAndServe(":9090", nil))
}
