<%@ Language="VBScript" CODEPAGE="65001"%>


<!DOCTYPE html>

<!--#include file="json2.asp"--> 
<!--#include file="base64.asp"--> 

<%
	
call initCodecs
paymentKey	= ""

' TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정에서 읽으세요.
secretkey = "{SECRET_KEY}:"

url = "https://api.tosspayments.com/v1/payments/" & paymentKey


authorization = "Basic " & base64Encode(secretkey)

set req = Server.CreateObject("MSXML2.ServerXMLHTTP")
req.open "GET", url, false
req.setRequestHeader "Authorization", authorization
req.send ""

set myJSON = JSON.parse(req.responseText)

httpCode = req.status

%>

--
<html lang="ko">
<head>
    <title>조회 성공</title>
    <meta charset="UTF-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
</head>
<body>
<section>
    <%
        if httpCode=200  then %>
        <h1>조회 성공</h1>
        <p>orderName : <%= Server.HTMLEncode(myJSON.orderName & "") %></p>
        <p>method : <%= Server.HTMLEncode(myJSON.method & "") %></p>
        <p>
            <% if myJSON.method = "카드"  then response.write Server.HTMLEncode(myJSON.card.number & "") end if %>
            <% if myJSON.method = "가상계좌"  then response.write Server.HTMLEncode(myJSON.virtualAccount.accountNumber & "") end if %>
            <% if myJSON.method = "계좌이체"  then response.write Server.HTMLEncode(myJSON.transfer.bank & "") end if %>
            <% if myJSON.method = "휴대폰"  then response.write Server.HTMLEncode(Left(myJSON.mobilePhone.customerMobilePhone & "", 3) & "****" & Right(myJSON.mobilePhone.customerMobilePhone & "", 4)) end if %>
            
        </p>
       <%
     else  %>
        <h1>조회 실패</h1>
        <p>에러메시지 :  <%= Server.HTMLEncode(myJSON.message & "") %></p>
        <span>에러코드:  <%= Server.HTMLEncode(myJSON.code & "") %></span>
       <%
    end if
    %>

</section>
</body>
</html>
