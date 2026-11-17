<%@ Language="VBScript" CODEPAGE="65001"%>

<!DOCTYPE html>

<!--#include file="json2.asp"-->
<!--#include file="base64.asp"-->
<!-- prettier-ignore -->
<%
	
call initCodecs
paymentKey	= "" 
cancelReason	= "고객 변심"

cancelAccount	= 300

bank = "신한"
accountNumber = "12345678901234"
holderName = "홍길동"

secretkey = "{SECRET_KEY}:"

url = "https://api.tosspayments.com/v1/payments/" & paymentKey & "/cancel"

data = "{""cancelReason"" : """ & cancelReason & """, ""cancelAccount"" : """ & cancelAccount & """," &_
    """refundReceiveAccount"" : {""bank"" : """ & bank & """," &_
    """accountNumber"" : """ & accountNumber & """, ""holderName"" : """ & holderName & """}}"

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
    <title>취소 성공</title>
    <meta charset="UTF-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  </head>
  <body>
    <section>
      <% if httpCode=200 then %>
      <h1>취소 성공</h1>
      <p>결과 데이터 : <%= req.responseText %></p>
      <p>orderName : <%= myJSON.orderName%></p>
      <p>method : <%= myJSON.method%></p>
      <p>method : <%= myJSON.cancels.get(0).cancelReason%></p>

      <% else %>
      <h1>결제 실패</h1>
      <p>에러메시지 : <%= myJSON.message%></p>
      <span>에러코드: <%= myJSON.code%></span>
      <% end if %>
    </section>
  </body>
</html>
