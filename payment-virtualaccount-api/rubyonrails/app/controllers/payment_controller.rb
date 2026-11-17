class PaymentController < ApplicationController

  def inquiryapi
    datetime = Time.now.to_i
    paymentKey = ""
      
    options = {
      headers: {
        Authorization: "Basic " + Base64.strict_encode64("{SECRET_KEY}:"),
        "Content-Type": "application/json"
      },
      body: {
        orderId: datetime,
        amount: 50000,
        customerEmail: "customer@email.com",
        orderName: "토스 가상계좌 결제",
        bank: "우리"
    }.to_json
    }
      
	begin
      response = HTTParty.get("https://api.tosspayments.com/v1/virtual-accounts", options).parsed_response
      @Response = response
    end      
  end
  
end
