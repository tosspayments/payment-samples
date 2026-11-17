var express = require("express");
var got = require("got");
var uuid = require("uuid").v4;

var router = express.Router();

var secretKey = "{SECRET_KEY}";

router.get("/inquiry", function (req, res) {
  let paymentKey = "";

  got("https://api.tosspayments.com/v1/payments/" + paymentKey, {
    headers: {
      Authorization: "Basic " + Buffer.from(secretKey + ":").toString("base64"),
    },

    responseType: "json",
  })
    .then(function (response) {
      res.render("inquiry", {
        isSuccess: true,
        responseJson: response.body,
      });
    })
    .catch(function (error) {
      res.render("inquiry", {
        isSuccess: false,
        responseJson: error.response.body,
      });
    });
});

module.exports = router;
