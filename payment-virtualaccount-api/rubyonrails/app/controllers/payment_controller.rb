class PaymentController < ApplicationController

  # 가상계좌 발급은 버튼을 눌러 POST 로 요청할 때만 실행해요.
  def vaform
    render html: helpers.button_to("가상계좌 발급", "/payment/vaapi", method: :post)
  end

  def vaapi
    datetime = Time.now.to_i
    paymentKey = ""
      
    # TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
    secretKey = ENV.fetch("TOSS_SECRET_KEY", "{SECRET_KEY}")

    options = {
      headers: {
        Authorization: "Basic " + Base64.strict_encode64(secretKey + ":"),
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
      response = HTTParty.post("https://api.tosspayments.com/v1/virtual-accounts", options).parsed_response
      @Response = response
    end      
  end
  
end
