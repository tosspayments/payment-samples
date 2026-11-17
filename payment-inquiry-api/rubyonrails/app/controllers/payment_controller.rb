class PaymentController < ApplicationController

  def inquiryapi
    datetime = Time.now.to_i
    paymentKey = ""
      
    # TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
    secretKey = ENV.fetch("TOSS_SECRET_KEY", "{SECRET_KEY}")

    options = {
      headers: {
        Authorization: "Basic " + Base64.strict_encode64(secretKey + ":"),
        "Content-Type": "application/json"
      }
    }
      
	begin
      response = HTTParty.get("https://api.tosspayments.com/v1/payments/" + paymentKey, options).parsed_response
      @Response = response
    end      
  end
  
end