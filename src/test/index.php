<?php

echo 'Test page<br />';

// DB_TYPE: ${DB_TYPE}
//       DB_HOST: ${DB_HOST}
//       DB_PORT: ${DB_PORT}
//       DB_USERNAME: ${DB_USERNAME}
//       DB_PASSWORD: ${DB_PASSWORD}
//       DB_NAME: ${DB_NAME}
//       DB_CHARSET: ${DB_CHARSET}
//       REDIS_HOST: ${REDIS_HOST}
//       REDIS_PORT: ${REDIS_PORT}
//       REDIS_TIMEOUT: ${REDIS_TIMEOUT}
//       REDIS_DB: ${REDIS_DB}
//       REDIS_PASSWORD: ${REDIS_PASSWORD}

echo 'mariadb conn test:<br />' . PHP_EOL;
$servername = getenv('DB_HOST') . ':' . getenv('DB_PORT');
$username = getenv('DB_USERNAME');
$password = getenv('DB_PASSWORD');

try {
    $conn = new PDO("mysql:host=$servername;", $username, $password);
    echo "连接成功<br />" . PHP_EOL . PHP_EOL;
} catch (\PDOException $e) {
    echo $e->getMessage() . PHP_EOL . PHP_EOL;
}

unset($conn);


echo '<br /><br />redis conn test:<br />' . PHP_EOL;
//连接本地的 Redis 服务
$redis = new Redis();
try {
    if ($redis->connect(getenv('REDIS_HOST'), getenv('REDIS_PORT'))) {
        if (!empty(getenv('REDIS_PASSWORD'))) {
            if ($redis->auth(getenv('REDIS_PASSWORD')) === false) {
                echo "redis auth error<br />" . PHP_EOL;
                return;
            }
        }
        echo "Connection to server sucessfully<br />" . PHP_EOL . PHP_EOL;
        echo "Server is running: " . ($redis->ping() ? 'yes' : 'no');

    } else {
        echo "redis connect error<br />" . PHP_EOL;
    }
} catch (\RedisException $e) {
    echo $e->getMessage() . PHP_EOL . PHP_EOL;
} catch (\Exception $e) {
    echo $e->getMessage() . PHP_EOL . PHP_EOL;
}
