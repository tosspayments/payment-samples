var express = require("express");
var got = require("got");
var uuid = require("uuid").v4;

var router = express.Router();

// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
var secretKey = process.env.TOSS_SECRET_KEY || "{SECRET_KEY}";

router.get("/", function (req, res) {
  res.redirect("/cancel");
});

// 결제 취소는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
router.get("/cancel", function (req, res) {
  res.send('<form method="post" action="/cancel"><button type="submit">결제 취소</button></form>');
});

router.post("/cancel", function (req, res) {
  // TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
  // TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요.
  let paymentKey = "";
  let cancelReason = "고객 변심";

  //부분 취소에서만 사용
  // let cancelAmount = 100;

  //refundReceiveAccount - 가상계좌 거래에 대해 입금후에 취소하는 경우만 필요
  // let bank = "신한";
  // let accountNumber = "12345678901234";
  // let holderName = "홍길동";

  got
    .post("https://api.tosspayments.com/v1/payments/" + paymentKey + "/cancel", {
      headers: {
        Authorization: "Basic " + Buffer.from(secretKey + ":").toString("base64"),
        "Content-Type": "application/json",
        // 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 보내요.
        "Idempotency-Key": uuid(),
      },
      json: {
        cancelReason: cancelReason,
        // cancelAmount: cancelAmount,
        // refundReceiveAccount: {
        //   bank: bank,
        //   accountNumber: accountNumber,
        //   holderName: holderName,
        // },
      },
      responseType: "json",
    })
    .then(function (response) {
      res.render("cancel", {
        isSuccess: true,
        responseJson: response.body,
      });
    })
    .catch(function (error) {
      res.render("cancel", {
        isSuccess: false,
        responseJson: error.response.body,
      });
    });
});

module.exports = router;
