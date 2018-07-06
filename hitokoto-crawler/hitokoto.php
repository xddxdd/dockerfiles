<?php
/* hitokoto crawler */
$redis = new Redis();
$redis->pconnect('lt-redis', 6379);
while(true) {
    $hitokotoServer = array(
        'https://hitokoto.api.freejishu.com/v2/',
        'https://api.lwl12.com/hitokoto/main/get',
        'https://hitoapi.cc/sp/',
        'https://api.i-meto.com/hitokoto'
    );
    $response = file_get_contents($hitokotoServer[rand(0, count($hitokotoServer) - 1)]);
    $responseDecoded = json_decode($response, true);
    if($responseDecoded) $response = $responseDecoded['text'];
    if($redis->sAdd('hitokoto', $response)) {
        echo "+";
    } else {
        echo " ";
    }
    sleep(1);
}
