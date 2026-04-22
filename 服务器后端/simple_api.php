<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 防止缓存
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 按钮链接配置
$buttonLinks = array(
    "TG主频道" => "https://t.me/ios5v5",
    "TG交流群" => "https://t.me/AiGosvip", 
    "彩虹卡网" => "https://iosaigo.com/",
    "随风卡网" => "https://sf.suifengyun.cn/shop/AiGo",
    "永久引导页" => "https://link3.cc/iosaigo",
    "安装网盘" => "http://121.36.56.188:21727",
    "联系客服" => "http://t.me/AiGoCc"
);

// 返回JSON响应
$response = array(
    "success" => true,
    "data" => $buttonLinks,
    "timestamp" => time(),
    "message" => "链接获取成功"
);

echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?> 