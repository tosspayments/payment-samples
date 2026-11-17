<?php
error_reporting(E_ALL);
// 에러 화면에 설정과 스택이 나가지 않도록 꺼 둬요. 개발할 때만 켜세요.
ini_set("display_errors", false);

function h($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}


$paymentKey = '';

// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정 파일에서 읽으세요.
$secretKey = getenv('TOSS_SECRET_KEY') ?: '{SECRET_KEY}';

$url = 'https://api.tosspayments.com/v1/payments/' . $paymentKey;

$credential = base64_encode($secretKey . ':');

$curlHandle = curl_init($url);


curl_setopt_array($curlHandle, [

    CURLOPT_RETURNTRANSFER => TRUE,
    CURLOPT_HTTPHEADER => [
        'Authorization: Basic ' . $credential
    ]
]);





$response = curl_exec($curlHandle);

$httpCode = curl_getinfo($curlHandle, CURLINFO_HTTP_CODE);
$isSuccess = $httpCode == 200;
$responseJson = json_decode($response);





?>

<!DOCTYPE html>
<html lang="ko">
<head>
    <title>조회 성공</title>
    <meta http-equiv="x-ua-compatible" content="ie=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
</head>
<body>
<section>
    <?php
    if ($isSuccess) { ?>
        <h1>조회 성공</h1>
        <p>orderName : <?php echo h($responseJson->orderName) ?></p>
        <p>method : <?php echo h($responseJson->method) ?></p>
        <p>
            <?php if($responseJson->method === "카드") { echo h($responseJson->card->number);} ?>
            <?php if($responseJson->method === "가상계좌") { echo h($responseJson->virtualAccount->accountNumber);} ?>
            <?php if($responseJson->method === "계좌이체") { echo h($responseJson->transfer->bank);} ?>
            <?php if($responseJson->method === "휴대폰") { $phone = (string) $responseJson->mobilePhone->customerMobilePhone; echo h(substr($phone, 0, 3) . '****' . substr($phone, -4));} ?>
        </p>
        <?php
    } else { ?>
        <h1>조회 실패</h1>
        <p>에러메시지 : <?php echo h($responseJson->message) ?></p>
        <span>에러코드: <?php echo h($responseJson->code) ?></span>
        <?php
    }
    ?>

</section>
</body>
</html>
