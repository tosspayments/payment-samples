var express = require("express");
var got = require("got");
var uuid = require("uuid").v4;

var router = express.Router();

var secretKey = "{SECRET_KEY}";

router.get("/", function (req, res) {
  res.redirect("/cancel");
});

router.get("/cancel", function (req, res) {
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
