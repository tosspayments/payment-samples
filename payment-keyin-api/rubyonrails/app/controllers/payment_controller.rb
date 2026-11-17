class PaymentController < ApplicationController

  def keyinapi
    datetime = Time.now.to_i
      
    options = {
      headers: {
        Authorization: "Basic " + Base64.strict_encode64("{SECRET_KEY}:"),
        "Content-Type": "application/json"
      },
      body: {          
        orderId: datetime,
        amount: 50000,
        customerEmail: "customer@email.com",
        orderName: "토스 카드정보(키인) 결제",
        cardNumber: "",
        cardExpirationYear: "",
        cardExpirationMonth: "",
        cardPassword: "",
        customerIdentityNumber: "",
        cardInstallmentPlan: "0"    
      }.to_json
    }
      
	  begin
      response = HTTParty.post("https://api.tosspayments.com/v1/payments/key-in", options).parsed_response
      @Response = response
    end      
  end
  
end