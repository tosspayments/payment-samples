var express = require("express");
var got = require("got");
var uuid = require("uuid").v4;

var router = express.Router();

// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
var secretKey = process.env.TOSS_SECRET_KEY || "{SECRET_KEY}";

// 가상계좌 발급은 버튼을 눌러 POST 로 요청할 때만 실행해요.
router.get("/virtual_account", function (req, res) {
  res.send('<form method="post" action="/virtual_account"><button type="submit">가상계좌 발급</button></form>');
});

router.post("/virtual_account", function (req, res) {
  let path = "http://127.0.0.1/Samples";

  let orderId = "virtualaccount-" + uuid();
  let amount = 50000;
  let customerEmail = "customer@email.com";
  let customerName = "박토스";
  let orderName = "토스 가상계좌 결제";
  let bank = "국민";
  let validHours = 72;
  let virtualAccountCallbackUrl = path + "/va_callback.php";
  let customerMobilePhone = "01000001234";
  let useEscrow = false;

  let type = "소득공제";
  let registrationNumber = "01000001234";

  got
    .post("https://api.tosspayments.com/v1/virtual-accounts", {
      headers: {
        Authorization: "Basic " + Buffer.from(secretKey + ":").toString("base64"),
        "Content-Type": "application/json",
      },
      json: {
        orderId: orderId,
        amount: amount,
        customerEmail: customerEmail,
        customerName: customerName,
        orderName: orderName,
        bank: bank,
        validHours: validHours,
        virtualAccountCallbackUrl: virtualAccountCallbackUrl,
        customerMobilePhone: customerMobilePhone,
        useEscrow: useEscrow,
        cashReceipt: {
          type: type,
          registrationNumber: registrationNumber,
        },
      },
      responseType: "json",
    })
    .then(function (response) {
      res.render("virtual_account", {
        isSuccess: true,
        responseJson: response.body,
      });
    })
    .catch(function (error) {
      res.render("virtual_account", {
        isSuccess: false,
        responseJson: error.response.body,
      });
    });
});

module.exports = router;
