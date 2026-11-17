from django.shortcuts import render
 
import requests, json, base64, time

# Create your views here.
def index(request):
  return render(
    request,
    'payments/index.html',
  )

def inquiryapi(request):
  paymentKey = ""
  
  url = "https://api.tosspayments.com/v1/payments/"
  secertkey = "{SECRET_KEY}"
  userpass = secertkey + ':'
  encoded_u = base64.b64encode(userpass.encode()).decode()
  
  headers = {
    "Authorization" : "Basic %s" % encoded_u,
    "Content-Type": "application/json"
  }
  
  res = requests.get(url+paymentKey, headers=headers)
  resjson = res.json()
  pretty = json.dumps(resjson, indent=4, ensure_ascii=False)
  
  return render(
    request,
    "payments/inquiryapi.html",
    {
      "res" : pretty,
      
    }
  )