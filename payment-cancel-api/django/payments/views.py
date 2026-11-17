from django.shortcuts import render
 
import requests, json, base64, time

# Create your views here.
def index(request):
  return render(
    request,
    'payments/index.html',
  )

def cancelapi(request):
  datetime = int(time.time())
  paymentKey = ""
      
  #부분 취소에서만 사용
  cancelAmount = 300
      
  #refundReceiveAccount - 가상계좌 거래에 대해 입금후에 취소하는 경우만 필요
  bank = "국민"
  accountNumber = "12345678901234"
  holderName = "홍길동"
  
  url = "https://api.tosspayments.com/v1/payments/"
  secertkey = "{SECRET_KEY}"
  userpass = secertkey + ':'
  encoded_u = base64.b64encode(userpass.encode()).decode()
  
  headers = {
    "Authorization" : "Basic %s" % encoded_u,
    "Content-Type": "application/json"
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
  pretty = json.dumps(resjson, indent=4, ensure_ascii=False)

  orderName = resjson["orderName"]
  method = resjson["method"]
  cancelReason = resjson["cancels"][0]["cancelReason"]
  
  return render(
    request,
    "payments/cancelapi.html",
    {
      "res" : pretty,
      "orderName" : orderName,
      "method" : method,
      "cancelReason" : cancelReason,
      
    }
  )