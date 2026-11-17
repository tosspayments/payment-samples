<?php
error_reporting(E_ALL);
ini_set("display_errors", true);

$paymentKey = "";
$cancelReason = "고객 변심";

//부분 취소에서만 사용
$cancelAmount = 300;

//refundReceiveAccount - 가상계좌 거래에 대해 입금후에 취소하는 경우만 필요
$bank = "신한";
$accountNumber = "12345678901234";
$holderName = "홍길동";

$secretKey = '{SECRET_KEY}'; 

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
        'Content-Type: application/json'
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
        <p>결과 데이터 : <?php echo json_encode($responseJson, JSON_UNESCAPED_UNICODE); ?></p>
        <p>orderName : <?php echo $responseJson->orderName ?></p>
        <p>method : <?php echo $responseJson->method ?></p>
        <p>cancels -> cancelReason : <?php echo $responseJson->cancels[0]->cancelReason ?></p>
              
        <?php
    } else { ?>
        <h1>취소 실패</h1>
        <p>에러메시지 : <?php echo $responseJson->message ?></p>
        <span>에러코드: <?php echo $responseJson->code ?></span>
        <?php
    }
    ?>

</section>
</body>
</html>
