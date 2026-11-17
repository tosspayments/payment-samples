class PaymentController < ApplicationController

  # 카드 번호 결제는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
  def keyinform
    render html: helpers.button_to("카드 번호 결제", "/payment/keyinapi", method: :post)
  end

  # TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
  # TODO: ApplicationController 에 protect_from_forgery 를 켜서 button_to 가 넣은 CSRF 토큰을 검증하세요.
  def keyinapi
    datetime = Time.now.to_i
      
    # TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 비밀 저장소에서 읽으세요.
    secretKey = ENV.fetch("TOSS_SECRET_KEY", "{SECRET_KEY}")

    options = {
      headers: {
        Authorization: "Basic " + Base64.strict_encode64(secretKey + ":"),
        "Content-Type": "application/json",
        # 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 보내요.
        "Idempotency-Key": SecureRandom.uuid
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