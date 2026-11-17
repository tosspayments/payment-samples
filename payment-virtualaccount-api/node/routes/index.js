var express = require("express");
var got = require("got");
var uuid = require("uuid").v4;

var router = express.Router();

var secretKey = "{SECRET_KEY}";

router.get("/virtual_account", function (req, res) {
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
