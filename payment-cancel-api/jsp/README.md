# payment-cancel-api/jsp

JSP를 이용한 결제 취소 샘플 코드입니다.

## 준비하기

- [Java](https://www.oracle.com/kr/java/technologies/downloads/)
- [Apache Tomcat](https://tomcat.apache.org/download-90.cgi)

## 실행하기

1. `/payment-cancel-api/jsp` 폴더를 Tomcat의 `webapp` 폴더에 넣어주세요.

2. `/cancel.jsp` 파일에 테스트하고 싶은 `paymentKey` 를 넣고, 시크릿 키는 `TOSS_SECRET_KEY` 환경 변수로 넣으세요.

3. Tomcat을 실행하고 http://localhost:{PORT_NUMBER}/jsp/cancel.jsp 에서 샘플 프로젝트를 확인하세요.
