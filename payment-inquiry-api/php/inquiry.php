<?php
error_reporting(E_ALL);
ini_set("display_errors", true);


$paymentKey = '';

$secretKey = '{SECRET_KEY}'; 

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
        <p>결과 데이터 : <?php echo json_encode($responseJson, JSON_UNESCAPED_UNICODE); ?></p>
        <p>orderName : <?php echo $responseJson->orderName ?></p>
        <p>method : <?php echo $responseJson->method ?></p>
        <p>
            <?php if($responseJson->method === "카드") { echo $responseJson->card->number;} ?>
            <?php if($responseJson->method === "가상계좌") { echo $responseJson->virtualAccount->accountNumber;} ?>
            <?php if($responseJson->method === "계좌이체") { echo $responseJson->transfer->bank;} ?>
            <?php if($responseJson->method === "휴대폰") { echo $responseJson->mobilePhone->customerMobilePhone;} ?>
        </p>
        <?php
    } else { ?>
        <h1>조회 실패</h1>
        <p>에러메시지 : <?php echo $responseJson->message ?></p>
        <span>에러코드: <?php echo $responseJson->code ?></span>
        <?php
    }
    ?>

</section>
</body>
</html>
