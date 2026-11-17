<!-- prettier-ignore -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.Base64"%>
<%@ page import="java.util.Base64.Encoder"%>
<%@ page import="java.net.HttpURLConnection"%>
<%@ page import="java.net.URL" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="org.json.simple.parser.JSONParser" %>
<%@ page import="org.json.simple.parser.ParseException" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.Reader" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<%
  /* 결제 취소는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요. */
  /* TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요. */
  /* TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요. */
  if (!"POST".equals(request.getMethod())) { %><form method="post"><button type="submit">결제 취소</button></form><% return; }

  String paymentKey = "";
  String cancelReason = "고객 변심";

  //부분 취소에서만 사용
  String cancelAmount = "300";

  //refundReceiveAccount - 가상계좌 거래에 대해 입금후에 취소하는 경우만 필요
  String bank = "신한";
  String accountNumber = "12345678901234";
  String holderName = "홍길동";
  
  /* TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정에서 읽으세요. */ String secretKey = (System.getenv("TOSS_SECRET_KEY") != null ? System.getenv("TOSS_SECRET_KEY") : "{SECRET_KEY}") + ":";
  
  Encoder encoder = Base64.getEncoder(); 
  byte[] encodedBytes = encoder.encode(secretKey.getBytes("UTF-8"));
  String authorizations = "Basic "+ new String(encodedBytes, 0, encodedBytes.length);
  
  URL url = new URL("https://api.tosspayments.com/v1/payments/" + paymentKey + "/cancel");
  
  HttpURLConnection connection = (HttpURLConnection) url.openConnection();
  connection.setRequestProperty("Authorization", authorizations);
  connection.setRequestProperty("Content-Type", "application/json"); /* 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 보내요. */ connection.setRequestProperty("Idempotency-Key", java.util.UUID.randomUUID().toString());
  connection.setRequestMethod("POST");
  connection.setDoOutput(true);

  JSONObject obj = new JSONObject();
  obj.put("cancelReason", cancelReason);
  obj.put("cancelAmount", cancelAmount);

  JSONObject refundReceiveAccount = new JSONObject();
  refundReceiveAccount.put("bank", bank);
  refundReceiveAccount.put("accountNumber", accountNumber);
  refundReceiveAccount.put("holderName", holderName);

  obj.put("refundReceiveAccount", refundReceiveAccount);
    
  OutputStream outputStream = connection.getOutputStream();
  outputStream.write(obj.toString().getBytes("UTF-8"));
  
  int code = connection.getResponseCode();
  boolean isSuccess = code == 200 ? true : false;
  
  InputStream responseStream = isSuccess? connection.getInputStream(): connection.getErrorStream();
  
  Reader reader = new InputStreamReader(responseStream, StandardCharsets.UTF_8);
  JSONParser parser = new JSONParser();
  JSONObject jsonObject = (JSONObject) parser.parse(reader);
  responseStream.close();
%>

<%!
  /* 응답 값을 HTML 에 넣기 전에 이스케이프해요. */
  private static String h(Object value) {
    if (value == null) return "";
    return value.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<!DOCTYPE html>
<html lang="ko">
  <head>
    <title>취소 성공</title>
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  </head>
  <body>
    <section>
      <% if (isSuccess) { %>
      <h1>취소 성공</h1>
      <p>orderName : <%= h(jsonObject.get("orderName")) %></p>
      <p>method : <%= h(jsonObject.get("method")) %></p>
      <p>cancels -> cancelReason : <% JSONArray cancels = ((JSONArray)jsonObject.get("cancels")); JSONObject cancel = (JSONObject) cancels.iterator().next(); %> <%= h(cancel.get("cancelReason")) %></p>

      <%} else { %>
      <h1>취소 실패</h1>
      <p><%= h(jsonObject.get("message")) %></p>
      <span>에러코드: <%= h(jsonObject.get("code")) %></span>
      <% } %>
    </section>
  </body>
</html>
