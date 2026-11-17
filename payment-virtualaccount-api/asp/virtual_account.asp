<%@ Language="VBScript" CODEPAGE="65001"%>


<!DOCTYPE html>

<!--#include file="json2.asp"--> 
<!--#include file="base64.asp"--> 

<%
' 가상계좌 발급은 버튼을 눌러 POST 로 요청할 때만 실행해요.
If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
%>
<form method="post"><button type="submit">가상계좌 발급</button></form>
<%
  Response.End
End If
	
call initCodecs

path = "http://127.0.0.1/Samples"

timestamp = right("0" & hour(now),2) &  right("0" & minute(now),2) &  right("0" & second(now),2)

orderId = "virtualaccount-" & timestamp
amount	= 50000 
customerEmail = "customer@email.com"
customerName = "박토스"
orderName = "토스 가상계좌 결제"
bank = "국민"
validHours = 72
virtualAccountCallbackUrl = path & "/va_callback.asp"
customerMobilePhone = "01000001234"
useEscrow ="false"

types = "소득공제"
registrationNumber  = "01000001234"

' TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정에서 읽으세요.
secretkey = "{SECRET_KEY}:"

url = "https://api.tosspayments.com/v1/virtual-accounts"

' 요청 본문은 문자열을 이어 붙이지 말고 JSON 으로 직렬화하세요.
set cashReceipt = JSON.parse("{}")
cashReceipt.set "type", types
cashReceipt.set "registrationNumber", registrationNumber
set body = JSON.parse("{}")
body.set "orderId", orderId
body.set "amount", amount
body.set "customerEmail", customerEmail
body.set "customerName", customerName
body.set "orderName", orderName
body.set "bank", bank
body.set "validHours", validHours
body.set "virtualAccountCallbackUrl", virtualAccountCallbackUrl
body.set "customerMobilePhone", customerMobilePhone
body.set "useEscrow", useEscrow
body.set "cashReceipt", cashReceipt
data = JSON.stringify(body)


authorization = "Basic " & base64Encode(secretkey)

set req = Server.CreateObject("MSXML2.ServerXMLHTTP")
req.open "POST", url, false
req.setRequestHeader "Authorization", authorization
req.setRequestHeader "Content-Type", "application/json;charset=UTF-8"
req.send data


set myJSON = JSON.parse(req.responseText)

httpCode = req.status

%>


<html lang="ko">
<head>
    <title>결제 성공</title>
    <meta charset="UTF-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
</head>
<body>
<section>
    <%
        if httpCode=200  then %>
        <h1>결제 성공</h1>
        <p>orderName : <%= Server.HTMLEncode(myJSON.orderName & "") %></p>
        <p>method : <%= Server.HTMLEncode(myJSON.method & "") %></p>
        <p>virtualAccount -> accountNumber :  <%= Server.HTMLEncode(myJSON.virtualAccount.accountNumber & "") %></p>
        <p>virtualAccount -> bank :  <%= Server.HTMLEncode(myJSON.virtualAccount.bank & "") %></p>
       <%
     else  %>
        <h1>결제 실패</h1>
        <p>에러메시지 :  <%= Server.HTMLEncode(myJSON.message & "") %></p>
        <span>에러코드:  <%= Server.HTMLEncode(myJSON.code & "") %></span>
       <%
    end if
    %>

</section>
</body>
</html>
