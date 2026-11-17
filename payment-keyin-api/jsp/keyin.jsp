<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> <%@ page import="java.util.Base64"%> <%@ page import="java.util.Base64.Encoder"%> <%@ page
import="java.net.HttpURLConnection"%> <%@ page import="java.net.URL" %> <%@ page import="org.json.simple.JSONObject" %> <%@ page import="org.json.simple.JSONArray" %> <%@ page
import="org.json.simple.parser.JSONParser" %> <%@ page import="org.json.simple.parser.ParseException" %> <%@ page import="java.io.OutputStream" %> <%@ page import="java.io.InputStream" %> <%@ page
import="java.io.InputStreamReader" %> <%@ page import="java.io.Reader" %> <%@ page import="java.nio.charset.StandardCharsets" %> <% /* 카드 번호 결제는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요. */ /* TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요. */ /* TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요. */ if (!"POST".equals(request.getMethod())) { %><form method="post"><button type="submit">카드 번호 결제</button></form><% return; } String orderId = "keyin-" +
String.valueOf(System.currentTimeMillis()); String amount = "50000"; String cardNumber = ""; String cardExpirationYear = ""; String cardExpirationMonth = ""; String cardPassword =
""; String customerBirthday = ""; String cardInstallmentPlan = "0"; String customerEmail = "customer@email.com"; String customerName = "박토스"; String orderName = "토스 키인 결제"; /* TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정에서 읽으세요. */ String secretKey = (System.getenv("TOSS_SECRET_KEY") != null ? System.getenv("TOSS_SECRET_KEY") : "{SECRET_KEY}") + ":"; Encoder encoder = Base64.getEncoder(); byte[] encodedBytes = encoder.encode(secretKey.getBytes("UTF-8")); String authorizations = "Basic "+ new
String(encodedBytes, 0, encodedBytes.length); URL url = new URL("https://api.tosspayments.com/v1/payments/key-in"); HttpURLConnection connection = (HttpURLConnection) url.openConnection();
connection.setRequestProperty("Authorization", authorizations); connection.setRequestProperty("Content-Type", "application/json"); /* 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 보내요. */ connection.setRequestProperty("Idempotency-Key", java.util.UUID.randomUUID().toString()); connection.setRequestMethod("POST"); connection.setDoOutput(true);
JSONObject obj = new JSONObject(); obj.put("orderId", orderId); obj.put("amount", amount); obj.put("cardNumber", cardNumber); obj.put("cardExpirationYear", cardExpirationYear);
obj.put("cardExpirationMonth", cardExpirationMonth); obj.put("cardPassword", cardPassword); obj.put("customerBirthday", customerBirthday); obj.put("cardInstallmentPlan", cardInstallmentPlan);
obj.put("customerEmail", customerEmail); obj.put("customerName", customerName); obj.put("orderName", orderName); OutputStream outputStream = connection.getOutputStream();
outputStream.write(obj.toString().getBytes("UTF-8")); int code = connection.getResponseCode(); boolean isSuccess = code == 200 ? true : false; InputStream responseStream = isSuccess?
connection.getInputStream(): connection.getErrorStream(); Reader reader = new InputStreamReader(responseStream, StandardCharsets.UTF_8); JSONParser parser = new JSONParser(); JSONObject jsonObject =
(JSONObject) parser.parse(reader); responseStream.close(); %>

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
    <title>카드 번호 결제</title>
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  </head>
  <body>
    <section>
      <% if (isSuccess) { %>
      <h1>결제 성공</h1>
      <p>orderName : <%= h(jsonObject.get("orderName")) %></p>
      <p>method : <%= h(jsonObject.get("method")) %></p>
      <p>card -> number : <%= h(((JSONObject)jsonObject.get("card")).get("number")) %></p>

      <%} else { %>
      <h1>결제 실패</h1>
      <p><%= h(jsonObject.get("message")) %></p>
      <span>에러코드: <%= h(jsonObject.get("code")) %></span>
      <% } %>
    </section>
  </body>
</html>
