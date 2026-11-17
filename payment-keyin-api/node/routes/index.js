var express = require("express");
var got = require("got");
var uuid = require("uuid").v4;

var router = express.Router();

// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
var secretKey = process.env.TOSS_SECRET_KEY || "{SECRET_KEY}";

// 카드 번호 결제는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
router.get("/keyin", function (req, res) {
  res.send('<form method="post" action="/keyin"><button type="submit">카드 번호 결제</button></form>');
});

router.post("/keyin", function (req, res) {
  // TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
  // TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요.
  let orderId = "keyin-" + uuid();
  let amount = 50000;
  let cardNumber = "";
  let cardExpirationYear = "";
  let cardExpirationMonth = "";
  let cardPassword = "";
  let customerBirthday = "";
  let cardInstallmentPlan = 0;
  let customerEmail = "customer@email.com";
  let customerName = "박토스";
  let orderName = "토스 키인 결제";

  got
    .post("https://api.tosspayments.com/v1/payments/key-in", {
      headers: {
        Authorization: "Basic " + Buffer.from(secretKey + ":").toString("base64"),
        "Content-Type": "application/json",
        // 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 보내요.
        "Idempotency-Key": uuid(),
      },
      json: {
        orderId: orderId,
        amount: amount,
        cardNumber: cardNumber,
        cardExpirationYear: cardExpirationYear,
        cardExpirationMonth: cardExpirationMonth,
        cardPassword: cardPassword,
        customerBirthday: customerBirthday,
        cardInstallmentPlan: cardInstallmentPlan,
        customerEmail: customerEmail,
        customerName: customerName,
        orderName: orderName,
      },
      responseType: "json",
    })
    .then(function (response) {
      res.render("keyin", {
        isSuccess: true,
        responseJson: response.body,
      });
    })
    .catch(function (error) {
      res.render("keyin", {
        isSuccess: false,
        responseJson: error.response.body,
      });
    });
});

module.exports = router;
