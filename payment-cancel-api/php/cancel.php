<?php
error_reporting(E_ALL);
// 에러 화면에 설정과 스택이 나가지 않도록 꺼 둬요. 개발할 때만 켜세요.
ini_set("display_errors", false);

function h($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

// 결제 취소는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
// TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
// TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <title>결제 취소</title>
</head>
<body>
<form method="post">
    <button type="submit">결제 취소</button>
</form>
</body>
</html>
<?php
    exit;
}

$paymentKey = "";
$cancelReason = "고객 변심";

//부분 취소에서만 사용
$cancelAmount = 300;

//refundReceiveAccount - 가상계좌 거래에 대해 입금후에 취소하는 경우만 필요
$bank = "신한";
$accountNumber = "12345678901234";
$holderName = "홍길동";

// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정 파일에서 읽으세요.
$secretKey = getenv('TOSS_SECRET_KEY') ?: '{SECRET_KEY}';

$url = 'https://api.tosspayments.com/v1/payments/'. $paymentKey .'/cancel';

$data = ['cancelReason' => $cancelReason, 'cancelAmount' => $cancelAmount,
'refundReceiveAccount' => ['bank' => $bank, 'accountNumber' => $accountNumber, 'holderName' => $holderName]];

$credential = base64_encode($secretKey . ':');

$curlHandle = curl_init($url);


curl_setopt_array($curlHandle, [
    CURLOPT_POST => TRUE,
    CURLOPT_RETURNTRANSFER => TRUE,
    CURLOPT_HTTPHEADER => [
        'Authorization: Basic ' . $credential,
        'Content-Type: application/json',
        // 같은 요청이 두 번 처리되지 않도록 요청마다 고유한 멱등 키를 보내요.
        'Idempotency-Key: ' . bin2hex(random_bytes(16))
    ],
    CURLOPT_POSTFIELDS => json_encode($data)
]);





$response = curl_exec($curlHandle);

$httpCode = curl_getinfo($curlHandle, CURLINFO_HTTP_CODE);
$isSuccess = $httpCode == 200;
$responseJson = json_decode($response);





?>

<!DOCTYPE html>
<html lang="ko">
<head>
    <title>취소 성공</title>
    <meta http-equiv="x-ua-compatible" content="ie=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
</head>
<body>

<section>
    <?php
    if ($isSuccess) { ?>
        <h1>취소 성공</h1>
        <p>orderName : <?php echo h($responseJson->orderName) ?></p>
        <p>method : <?php echo h($responseJson->method) ?></p>
        <p>cancels -> cancelReason : <?php echo h($responseJson->cancels[0]->cancelReason) ?></p>
              
        <?php
    } else { ?>
        <h1>취소 실패</h1>
        <p>에러메시지 : <?php echo h($responseJson->message) ?></p>
        <span>에러코드: <?php echo h($responseJson->code) ?></span>
        <?php
    }
    ?>

</section>
</body>
</html>
