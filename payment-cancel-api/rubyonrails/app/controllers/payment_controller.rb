class PaymentController < ApplicationController

  # 결제 취소는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
  def cancelform
    render html: helpers.button_to("결제 취소", "/payment/cancelapi", method: :post)
  end

  # TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
  # TODO: ApplicationController 에 protect_from_forgery 를 켜서 button_to 가 넣은 CSRF 토큰을 검증하세요.
  def cancelapi
    datetime = Time.now.to_i
    paymentKey = ""
      
    #부분 취소에서만 사용
    cancelAmount = 300
      
    #refundReceiveAccount - 가상계좌 거래에 대해 입금후에 취소하는 경우만 필요
    bank = "국민"
    accountNumber = "12345678901234"
    holderName = "홍길동"
   
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
        cancelReason: "고객 변심",
        cancelAmount: cancelAmount,
        #refundReceiveAccount: {
        #    bank: bank,
        #    accountNumber: accountNumber,
        #    holderName: holderName
        #    }
      }.to_json
    }
      
	  begin
      response = HTTParty.post("https://api.tosspayments.com/v1/payments/" + paymentKey + "/cancel", options).parsed_response
      @Response = response
    end      
  end
  
end