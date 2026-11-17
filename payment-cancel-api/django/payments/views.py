from django.shortcuts import render
from django.views.decorators.http import require_POST
 
import requests, json, base64, time
import os
import uuid

# Create your views here.
def index(request):
  return render(
    request,
    'payments/index.html',
  )

# 결제 취소는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요. CSRF 토큰은 Django 가 검증해요.
@require_POST
def cancelapi(request):
  # TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
  datetime = int(time.time())
  paymentKey = ""
      
  #부분 취소에서만 사용
  cancelAmount = 300
      
  #refundReceiveAccount - 가상계좌 거래에 대해 입금후에 취소하는 경우만 필요
  bank = "국민"
  accountNumber = "12345678901234"
  holderName = "홍길동"
  
  url = "https://api.tosspayments.com/v1/payments/"
  # TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
  secertkey = os.environ.get("TOSS_SECRET_KEY", "{SECRET_KEY}")
  userpass = secertkey + ':'
  encoded_u = base64.b64encode(userpass.encode()).decode()
  
  headers = {
    "Authorization" : "Basic %s" % encoded_u,
    "Content-Type": "application/json",
    # 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 보내요.
    "Idempotency-Key": str(uuid.uuid4()),
  }
  
  params = {
    "cancelReason": "고객 변심",
    "cancelAmount": cancelAmount,
    #"refundReceiveAccount": {
    #    "bank": bank,
    #    "accountNumber": accountNumber,
    #    "holderName": holderName
    #    }
  }
  
  res = requests.post(url+paymentKey+"/cancel", data=json.dumps(params), headers=headers)
  resjson = res.json()

  # 실패 응답은 상태 코드로 나눠 처리해요.
  if res.status_code != 200:
    return render(
      request,
      "payments/cancelapi.html",
      {
        "code": resjson.get("code"),
        "message": resjson.get("message"),
      },
      status=res.status_code,
    )

  orderName = resjson["orderName"]
  method = resjson["method"]
  cancelReason = resjson["cancels"][0]["cancelReason"]
  
  return render(
    request,
    "payments/cancelapi.html",
    {
      "orderName" : orderName,
      "method" : method,
      "cancelReason" : cancelReason,
      
    }
  )