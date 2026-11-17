class PaymentController < ApplicationController

  def inquiryapi
    datetime = Time.now.to_i
    paymentKey = ""
      
    options = {
      headers: {
        Authorization: "Basic " + Base64.strict_encode64("{SECRET_KEY}:"),
        "Content-Type": "application/json"
      }
    }
      
	begin
      response = HTTParty.get("https://api.tosspayments.com/v1/payments/" + paymentKey, options).parsed_response
      @Response = response
    end      
  end
  
end