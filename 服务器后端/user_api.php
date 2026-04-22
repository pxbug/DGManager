<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'config.php';

// 处理不同的API操作
$action = $_GET['action'] ?? '';

try {
    switch ($action) {
        case 'get_user_info':
            handleGetUserInfo();
            break;
        case 'checkin':
            handleCheckin();
            break;
        case 'exchange':
            handleExchange();
            break;
        default:
            sendResponse(false, '无效的操作');
            break;
    }
} catch (Exception $e) {
    sendResponse(false, '服务器错误: ' . $e->getMessage());
}

function handleGetUserInfo() {
    $input = getJsonInput();
    
    if (!isset($input['device_uid'])) {
        sendResponse(false, '缺少设备UID');
        return;
    }
    
    $user = getOrCreateUser($input['device_uid']);
    
    sendResponse(true, '获取成功', [
        'points' => (int)$user['points'],
        'checkin_days' => (int)$user['checkin_days'],
        'total_checkin_days' => (int)$user['total_checkin_days'],
        'last_checkin_date' => $user['last_checkin_date']
    ]);
}

function handleCheckin() {
    $input = getJsonInput();
    
    if (!isset($input['device_uid'])) {
        sendResponse(false, '缺少设备UID');
        return;
    }
    
    $result = userCheckin($input['device_uid']);
    
    if ($result['success']) {
        sendResponse(true, $result['message'], [
            'points' => $result['points'],
            'consecutive_days' => $result['consecutive_days']
        ]);
    } else {
        sendResponse(false, $result['message'], [
            'points' => $result['points']
        ]);
    }
}

function handleExchange() {
    $input = getJsonInput();
    
    if (!isset($input['device_uid']) || !isset($input['product_name']) || !isset($input['points_cost'])) {
        sendResponse(false, '参数不完整');
        return;
    }
    
    $result = exchangeProduct($input['device_uid'], $input['product_name'], (int)$input['points_cost']);
    
    if ($result['success']) {
        sendResponse(true, $result['message'], [
            'remaining_points' => $result['remaining_points'],
            'exchange_id' => $result['exchange_id']
        ]);
    } else {
        sendResponse(false, $result['message'], [
            'current_points' => $result['current_points'] ?? 0,
            'required_points' => $result['required_points'] ?? 0
        ]);
    }
}

function getJsonInput() {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        sendResponse(false, 'JSON格式错误: ' . json_last_error_msg());
        exit;
    }
    
    return $data;
}

function sendResponse($success, $message, $data = null) {
    $response = [
        'success' => $success,
        'message' => $message,
        'timestamp' => time()
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit;
}
?> 