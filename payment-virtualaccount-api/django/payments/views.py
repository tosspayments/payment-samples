from django.http import HttpResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
 
import requests, json, base64, time
import os

# Create your views here.
def index(request):
  return render(
    request,
    'payments/index.html',
  )

@require_POST
def vaapi(request):
  datetime = int(time.time())
  
  url = "https://api.tosspayments.com/v1/virtual-accounts"
  # TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
  secertkey = os.environ.get("TOSS_SECRET_KEY", "{SECRET_KEY}")
  userpass = secertkey + ':'
  encoded_u = base64.b64encode(userpass.encode()).decode()
  
  headers = {
    "Authorization" : "Basic %s" % encoded_u,
    "Content-Type": "application/json"
  }
  
  params = {
    "orderId": datetime,
    "amount": 50000,
    "customerEmail": "customer@email.com",
    "customerName": "박토스",
    "orderName": "토스 가상계좌 결제",
    "bank": "국민",
    "validHours": 72,
    # TODO: 입금 결과를 받을 가맹점 서버 주소를 넣으세요. 아래 va_callback 이 받는 예시예요.
    "virtualAccountCallbackUrl": "{VIRTUAL_ACCOUNT_CALLBACK_URL}",
    "customerMobilePhone": "01000001234",
    "useEscrow": False  
  }
  
  res = requests.post(url, data=json.dumps(params), headers=headers)
  resjson = res.json()

  # 실패 응답은 상태 코드로 나눠 처리해요.
  if res.status_code != 200:
    return render(
      request,
      "payments/vaapi.html",
      {
        "code": resjson.get("code"),
        "message": resjson.get("message"),
      },
      status=res.status_code,
    )

  # TODO: 응답의 secret 을 주문과 함께 서버에 저장하세요. 입금 콜백을 확인할 때 써요.
  accountNumber = resjson["virtualAccount"]["accountNumber"]
  bank = resjson["virtualAccount"]["bank"]
  
  return render(
    request,
    "payments/vaapi.html",
    {
      "accountNumber" : accountNumber,
      "bank" : bank,
      
    }
  )


# 가상계좌 입금 콜백을 받는 예시예요. 토스페이먼츠 서버가 보내는 요청이라 CSRF 토큰이 없어요.
@csrf_exempt
@require_POST
def va_callback(request):
  body = json.loads(request.body)
  orderId = body.get("orderId")

  # TODO: 발급할 때 저장한 secret 과 콜백의 secret 이 같은지 확인하고, 다르면 처리하지 마세요.
  # 예시)
  # if body.get("secret") != find_saved_secret(orderId):
  #   return HttpResponse(status=400)

  # TODO: 결제 조회 API 로 결제 상태를 다시 확인한 뒤 주문 상태를 바꾸세요.
  # 예시)
  # payment = requests.get("https://api.tosspayments.com/v1/payments/orders/" + orderId, headers=headers).json()
  # if payment["status"] == "DONE":
  #   mark_order_paid(orderId)

  return HttpResponse(status=200)
