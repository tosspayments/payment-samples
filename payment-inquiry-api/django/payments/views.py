from django.shortcuts import render
 
import requests, json, base64, time
import os

# Create your views here.
def index(request):
  return render(
    request,
    'payments/index.html',
  )

def inquiryapi(request):
  paymentKey = ""
  
  url = "https://api.tosspayments.com/v1/payments/"
  # TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
  secertkey = os.environ.get("TOSS_SECRET_KEY", "{SECRET_KEY}")
  userpass = secertkey + ':'
  encoded_u = base64.b64encode(userpass.encode()).decode()
  
  headers = {
    "Authorization" : "Basic %s" % encoded_u,
    "Content-Type": "application/json"
  }
  
  res = requests.get(url+paymentKey, headers=headers)
  resjson = res.json()

  # 실패 응답은 상태 코드로 나눠 처리해요.
  if res.status_code != 200:
    return render(
      request,
      "payments/inquiryapi.html",
      {
        "code": resjson.get("code"),
        "message": resjson.get("message"),
      },
      status=res.status_code,
    )
  
  return render(
    request,
    "payments/inquiryapi.html",
    {
      "orderId": resjson.get("orderId"),
      "orderName": resjson.get("orderName"),
      "status": resjson.get("status"),
      "method": resjson.get("method"),
      "totalAmount": resjson.get("totalAmount"),
    }
  )