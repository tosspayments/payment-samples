# payment-cancel-api/php

PHP를 이용한 결제 취소 샘플 코드입니다.

## 준비하기

환경에 맞춰 [php를 설치하세요](https://www.php.net/manual/en/install.php).

```
brew install php
```

## 실행하기

1. `cancel.php` 파일에 테스트하고 싶은 `paymentKey` 를 넣고, 시크릿 키는 `TOSS_SECRET_KEY` 환경 변수로 넣으세요.

2. php 서버를 실행합니다.

   ```sh
   $ php -S localhost:4242 # 서버 실행
   ```

3. http://localhost:4242/cancel.php 에서 샘플 프로젝트를 확인하세요.
