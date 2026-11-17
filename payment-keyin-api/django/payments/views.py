from django.shortcuts import render
 
import requests, json, base64, time

# Create your views here.
def index(request):
  return render(
    request,
    'payments/index.html',
  )

def keyinapi(request):
  datetime = int(time.time())
  
  url = "https://api.tosspayments.com/v1/payments/key-in"
  secertkey = "{SECRET_KEY}"
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
    "orderName": "토스 카드정보(키인) 결제",
    "cardNumber": "",
    "cardExpirationYear": "",
    "cardExpirationMonth": "",
    "cardPassword": "",
    "customerIdentityNumber": "",
    "cardInstallmentPlan": "",
  }
  
  res = requests.post(url, data=json.dumps(params), headers=headers)
  resjson = res.json()
  pretty = json.dumps(resjson, indent=4, ensure_ascii=False)

  method = resjson["method"]
  number = resjson["card"]["number"]
  
  return render(
    request,
    "payments/keyinapi.html",
    {
      "res" : pretty,
      "method" : method,
      "number" : number,
      
    }
  )