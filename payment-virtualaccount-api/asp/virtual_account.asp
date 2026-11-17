<%@ Language="VBScript" CODEPAGE="65001"%>


<!DOCTYPE html>

<!--#include file="json2.asp"--> 
<!--#include file="base64.asp"--> 

<%
	
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

secretkey = "{SECRET_KEY}:"

url = "https://api.tosspayments.com/v1/virtual-accounts"

data = "{""orderId"" : """ & orderId & """, ""amount"" : " & amount & "," &_
    """customerEmail"" : """ & customerEmail & """, ""customerName"" : """ & customerName & """," &_
    """orderName"" : """ & orderName & """, ""bank"" : """ & bank & """," &_
    """validHours"" : """ & validHours & """, ""virtualAccountCallbackUrl"" : """ & virtualAccountCallbackUrl & """," &_
    """customerMobilePhone"" : """ & customerMobilePhone & """, ""useEscrow"" : """ & useEscrow & """," &_
    """cashReceipt"" : {""type"" : """ & types &""",""registrationNumber"" : """ & registrationNumber & """}}"


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
        <p>결과 데이터 : <%= req.responseText %></p>
        <p>orderName : <%= myJSON.orderName%></p>
        <p>method : <%= myJSON.method%></p>
        <p>virtualAccount -> accountNumber :  <%= myJSON.virtualAccount.accountNumber%></p>
        <p>virtualAccount -> bank :  <%= myJSON.virtualAccount.bank%></p>
       <%
     else  %>
        <h1>결제 실패</h1>
        <p>에러메시지 :  <%= myJSON.message%></p>
        <span>에러코드:  <%= myJSON.code%></span>
       <%
    end if
    %>

</section>
</body>
</html>
