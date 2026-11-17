var express = require("express");
var got = require("got");
var uuid = require("uuid").v4;

var router = express.Router();

var secretKey = "{SECRET_KEY}";

router.get("/keyin", function (req, res) {
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
