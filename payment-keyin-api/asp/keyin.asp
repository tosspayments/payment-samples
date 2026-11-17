<%@ Language="VBScript" CODEPAGE="65001"%>


<!DOCTYPE html>

<!--#include file="json2.asp"-->
<!--#include file="base64.asp"-->
<%
' 카드 번호 결제는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
' TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
' TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요.
If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
%>
<form method="post"><button type="submit">카드 번호 결제</button></form>
<%
  Response.End
End If

' 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 만들어요.
Function NewIdempotencyKey()
  Dim i, key
  Randomize
  For i = 1 To 32
    key = key & Hex(Int(Rnd * 16))
  Next
  NewIdempotencyKey = key
End Function
%>

<%
	
call initCodecs

path = "http://127.0.0.1/Samples"

timestamp = right("0" & hour(now),2) &  right("0" & minute(now),2) &  right("0" & second(now),2)

orderId = "virtualaccount-" & timestamp
amount	= 50000 
cardNumber = ""
cardExpirationYear = ""
cardExpirationMonth = ""
cardPassword = ""
customerBirthday = ""
cardInstallmentPlan = 0
customerEmail = "customer@email.com"
customerName = "박토스"
orderName = "토스 키인 결제"


' TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정에서 읽으세요.
secretkey = "{SECRET_KEY}:"

url = "https://api.tosspayments.com/v1/payments/key-in"

' 요청 본문은 문자열을 이어 붙이지 말고 JSON 으로 직렬화하세요.
set body = JSON.parse("{}")
body.set "orderId", orderId
body.set "amount", amount
body.set "cardNumber", cardNumber
body.set "cardExpirationYear", cardExpirationYear
body.set "cardExpirationMonth", cardExpirationMonth
body.set "cardPassword", cardPassword
body.set "customerBirthday", customerBirthday
body.set "cardInstallmentPlan", cardInstallmentPlan
body.set "customerEmail", customerEmail
body.set "customerName", customerName
body.set "orderName", orderName
data = JSON.stringify(body)


authorization = "Basic " & base64Encode(secretkey)

set req = Server.CreateObject("MSXML2.ServerXMLHTTP")
req.open "POST", url, false
req.setRequestHeader "Authorization", authorization
req.setRequestHeader "Content-Type", "application/json;charset=UTF-8"
req.setRequestHeader "Idempotency-Key", NewIdempotencyKey()
req.send data


set myJSON = JSON.parse(req.responseText)

httpCode = req.status

%>


<html lang="ko">

<head>
    <title>결제 성공</title>
    <meta charset="UTF-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
</head>

<body>
    <section>
        <%
        if httpCode=200  then %>
        <h1>결제 성공</h1>
        <p>orderName : <%= Server.HTMLEncode(myJSON.orderName & "") %></p>
        <p>method : <%= Server.HTMLEncode(myJSON.method & "") %></p>
        <p>card -> number : <%= Server.HTMLEncode(myJSON.card.number & "") %></p>
        <%
     else  %>
        <h1>결제 실패</h1>
        <p>에러메시지 : <%= Server.HTMLEncode(myJSON.message & "") %></p>
        <span>에러코드: <%= Server.HTMLEncode(myJSON.code & "") %></span>
        <%
    end if
    %>

    </section>
</body>

</html>