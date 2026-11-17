from django.shortcuts import render
 
import requests, json, base64, time

# Create your views here.
def index(request):
  return render(
    request,
    'payments/index.html',
  )

def vaapi(request):
  datetime = int(time.time())
  
  url = "https://api.tosspayments.com/v1/virtual-accounts"
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
    "customerName": "박토스",
    "orderName": "토스 가상계좌 결제",
    "bank": "국민",
    "validHours": 72,
    "virtualAccountCallbackUrl": "https://webhook.site/8f1dca13-02e7-41d6-a6bb-9c217a73d4a8",
    "customerMobilePhone": "01000001234",
    "useEscrow": False  
  }
  
  res = requests.post(url, data=json.dumps(params), headers=headers)
  resjson = res.json()
  pretty = json.dumps(resjson, indent=4)

  accountNumber = resjson["virtualAccount"]["accountNumber"]
  bank = resjson["virtualAccount"]["bank"]
  
  return render(
    request,
    "payments/vaapi.html",
    {
      "res" : pretty,
      "accountNumber" : accountNumber,
      "bank" : bank,
      
    }
  )