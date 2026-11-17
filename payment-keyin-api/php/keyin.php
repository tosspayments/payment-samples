<?php
error_reporting(E_ALL);
// 에러 화면에 설정과 스택이 나가지 않도록 꺼 둬요. 개발할 때만 켜세요.
ini_set("display_errors", false);

function h($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

// 카드 번호 결제는 가맹점 관리자가 버튼을 눌러 POST 로 요청할 때만 실행해요.
// TODO: 가맹점 관리자 로그인 여부와 권한을 확인하세요.
// TODO: 폼에 CSRF 토큰을 넣고 여기서 검증하세요.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <title>카드 번호 결제</title>
</head>
<body>
<form method="post">
    <button type="submit">카드 번호 결제</button>
</form>
</body>
</html>
<?php
    exit;
}


$orderId = "keyin-" . time()*1000;
$amount = 50000;
$cardNumber = "";
$cardExpirationYear = "";
$cardExpirationMonth = "";
$cardPassword = "";
$customerBirthday = "";
$cardInstallmentPlan = 0;
$customerEmail = "customer@email.com";
$customerName = "박토스";
$orderName = "토스 키인 결제";

// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정 파일에서 읽으세요.
$secretKey = getenv('TOSS_SECRET_KEY') ?: '{SECRET_KEY}';

$url = 'https://api.tosspayments.com/v1/payments/key-in';

$data = ['orderId' => $orderId, 'amount' => $amount, 'cardNumber' => $cardNumber, 'cardExpirationYear' => $cardExpirationYear, 
'cardExpirationMonth' => $cardExpirationMonth, 'cardPassword' => $cardPassword, 'customerBirthday' => $customerBirthday,
'cardInstallmentPlan' => $cardInstallmentPlan, 'customerEmail' => $customerEmail, 'customerName' => $customerName,
'orderName' => $orderName];

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
    <title>결제 성공</title>
    <meta http-equiv="x-ua-compatible" content="ie=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
</head>
<body>
<section>
    <?php
    if ($isSuccess) { ?>
        <h1>결제 성공</h1>
        <p>orderName : <?php echo h($responseJson->orderName) ?></p>
        <p>method : <?php echo h($responseJson->method) ?></p>
        <p>card -> number : <?php echo h($responseJson->card->number) ?></p>
              
        <?php
    } else { ?>
        <h1>결제 실패</h1>
        <p>에러메시지 : <?php echo h($responseJson->message) ?></p>
        <span>에러코드: <?php echo h($responseJson->code) ?></span>
        <?php
    }
    ?>

</section>
</body>
</html>
