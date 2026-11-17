<?php
error_reporting(E_ALL);
// 에러 화면에 설정과 스택이 나가지 않도록 꺼 둬요. 개발할 때만 켜세요.
ini_set("display_errors", false);

function h($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

// 가상계좌 발급은 버튼을 눌러 POST 로 요청할 때만 실행해요.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
?>
<form method="post"><button type="submit">가상계좌 발급</button></form>
<?php
    exit;
}

$path = "http://127.0.0.1/Samples";


$orderId = "virtualaccount-" . time()*1000;
$amount = 50000;
$customerEmail = "customer@email.com";
$customerName = "박토스";
$orderName = "토스 가상계좌 결제";
$bank = "국민";
$validHours = 72;
$virtualAccountCallbackUrl = $path . "/va_callback.php";
$customerMobilePhone = "01000001234";
$useEscrow = false;



$type = "소득공제";
$registrationNumber  = "01000001234";


// TODO: 시크릿 키는 소스에 적지 말고 환경 변수나 웹 루트 밖 설정 파일에서 읽으세요.
$secretKey = getenv('TOSS_SECRET_KEY') ?: '{SECRET_KEY}';

$url = 'https://api.tosspayments.com/v1/virtual-accounts';

$data = ['orderId' => $orderId, 'amount' => $amount, 'customerEmail' => $customerEmail, 'customerName' => $customerName,
'bank' => $bank, 'validHours' => $validHours,'virtualAccountCallbackUrl' => $virtualAccountCallbackUrl,
'customerMobilePhone' => $customerMobilePhone,'useEscrow' => $useEscrow, 'orderName' => $orderName,
'cashReceipt' => ['type' => $type,'registrationNumber' => $registrationNumber] ];

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
        <p>virtualAccount -> accountNumber : <?php echo h($responseJson->virtualAccount->accountNumber) ?></p>
        <p>virtualAccount -> bank  : <?php echo h($responseJson->virtualAccount->bank) ?></p>
              
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
