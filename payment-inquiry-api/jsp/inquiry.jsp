<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> <%@ page import="java.util.Base64"%> <%@ page import="java.util.Base64.Encoder"%> <%@ page
import="java.net.HttpURLConnection"%> <%@ page import="java.net.URL" %> <%@ page import="org.json.simple.JSONObject" %> <%@ page import="org.json.simple.JSONArray" %> <%@ page
import="org.json.simple.parser.JSONParser" %> <%@ page import="org.json.simple.parser.ParseException" %> <%@ page import="java.io.OutputStream" %> <%@ page import="java.io.InputStream" %> <%@ page
import="java.io.InputStreamReader" %> <%@ page import="java.io.Reader" %> <%@ page import="java.nio.charset.StandardCharsets" %> <% String paymentKey = ""; /* TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정에서 읽으세요. */ String secretKey = (System.getenv("TOSS_SECRET_KEY") != null ? System.getenv("TOSS_SECRET_KEY") : "{SECRET_KEY}") + ":"; Encoder encoder = Base64.getEncoder(); byte[] encodedBytes = encoder.encode(secretKey.getBytes("UTF-8")); String authorizations = "Basic "+ new
String(encodedBytes, 0, encodedBytes.length); URL url = new URL("https://api.tosspayments.com/v1/payments/" + paymentKey); HttpURLConnection connection = (HttpURLConnection) url.openConnection();
connection.setRequestProperty("Authorization", authorizations); connection.setRequestProperty("Content-Type", "application/json"); connection.setRequestMethod("GET"); int code =
connection.getResponseCode(); boolean isSuccess = code == 200 ? true : false; InputStream responseStream = isSuccess? connection.getInputStream(): connection.getErrorStream(); Reader reader = new
InputStreamReader(responseStream, StandardCharsets.UTF_8); JSONParser parser = new JSONParser(); JSONObject jsonObject = (JSONObject) parser.parse(reader); responseStream.close(); %>

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
    <title>조회 성공</title>
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  </head>
  <body>
    <section>
      <% if (isSuccess) { %>
      <h1>조회 성공</h1>
      <p>orderName : <%= h(jsonObject.get("orderName")) %></p>
      <p>method : <%= h(jsonObject.get("method")) %></p>
      <p>
        <% if(jsonObject.get("method").equals("카드")) { out.println(h(((JSONObject)jsonObject.get("card")).get("number")));} %> <% if(jsonObject.get("method").equals("가상계좌")) {
        out.println(h(((JSONObject)jsonObject.get("virtualAccount")).get("accountNumber")));} %> <% if(jsonObject.get("method").equals("계좌이체")) {
        out.println(h(((JSONObject)jsonObject.get("transfer")).get("bank")));} %> <% if(jsonObject.get("method").equals("휴대폰")) {
        String phone = String.valueOf(((JSONObject)jsonObject.get("mobilePhone")).get("customerMobilePhone")); out.println(h(phone.substring(0, Math.min(3, phone.length())) + "****" + phone.substring(Math.max(0, phone.length() - 4))));} %>
      </p>

      <%} else { %>
      <h1>조회 실패</h1>
      <p><%= h(jsonObject.get("message")) %></p>
      <span>에러코드: <%= h(jsonObject.get("code")) %></span>
      <% } %>
    </section>
  </body>
</html>
