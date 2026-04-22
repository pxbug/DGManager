<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Signature, X-Timestamp');

require_once 'config.php';

// 处理OPTIONS请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// 验证请求函数
function validateRequest() {
    // 获取请求头
    $signature = $_SERVER['HTTP_X_SIGNATURE'] ?? '';
    $timestamp = $_SERVER['HTTP_X_TIMESTAMP'] ?? '';
    
    if (empty($signature) || empty($timestamp)) {
        return false;
    }
    
    // 获取请求数据
    $requestData = '';
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $requestData = file_get_contents('php://input');
    } else {
        $requestData = $_SERVER['REQUEST_URI'];
    }
    
    return verifySignature($requestData, $signature, intval($timestamp));
}

// 发送加密响应
function sendEncryptedResponse($data) {
    $timestamp = time();
    $jsonData = json_encode($data, JSON_UNESCAPED_UNICODE);
    $encryptedData = encryptData($jsonData);
    $signature = generateSignature($encryptedData, $timestamp);
    
    $response = [
        'data' => $encryptedData,
        'timestamp' => $timestamp,
        'signature' => $signature
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
}

try {
    // 验证请求签名
    // if (!validateRequest()) {
    //     sendEncryptedResponse([
    //         'success' => false,
    //         'message' => '请求验证失败'
    //     ]);
    //     exit;
    // }
    
    $pdo = getDB();
    
    // 获取所有按钮链接
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $stmt = $pdo->query("SELECT button_name, button_url FROM button_links ORDER BY id");
        $links = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // 转换为键值对格式，便于客户端使用
        $result = [];
        foreach ($links as $link) {
            $result[$link['button_name']] = $link['button_url'];
        }
        
        sendEncryptedResponse([
            'success' => true,
            'data' => $result,
            'message' => '获取成功'
        ]);
    }
    
    // 更新链接（管理端使用）
    elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        session_start();
        
        // 检查登录状态
        if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
            // 对于管理后台，返回普通JSON响应而不是加密响应
            echo json_encode([
                'success' => false,
                'message' => '未授权访问',
                'debug' => 'Session not found or not logged in'
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $rawInput = file_get_contents('php://input');
        $input = json_decode($rawInput, true);
        
        // 调试信息
        if (json_last_error() !== JSON_ERROR_NONE) {
            echo json_encode([
                'success' => false,
                'message' => 'JSON解析错误: ' . json_last_error_msg(),
                'debug' => [
                    'raw_input' => $rawInput,
                    'json_error' => json_last_error_msg()
                ]
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        // 如果输入是加密的，尝试解密
        if (isset($input['data']) && isset($input['signature'])) {
            $decryptedData = decryptData($input['data']);
            if ($decryptedData) {
                $input = json_decode($decryptedData, true);
            }
        }
        
        if (!isset($input['button_name']) || !isset($input['button_url'])) {
            // 对于管理后台，返回普通JSON响应
            echo json_encode([
                'success' => false,
                'message' => '参数不完整',
                'debug' => [
                    'received_data' => $input,
                    'button_name_exists' => isset($input['button_name']),
                    'button_url_exists' => isset($input['button_url'])
                ]
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $stmt = $pdo->prepare("UPDATE button_links SET button_url = ?, updated_at = NOW() WHERE button_name = ?");
        $result = $stmt->execute([$input['button_url'], $input['button_name']]);
        
        if ($result) {
            // 检查是否真的更新了行
            $affectedRows = $stmt->rowCount();
            
            // 对于管理后台，返回普通JSON响应
            echo json_encode([
                'success' => true,
                'message' => '更新成功',
                'debug' => [
                    'affected_rows' => $affectedRows,
                    'button_name' => $input['button_name'],
                    'button_url' => $input['button_url']
                ]
            ], JSON_UNESCAPED_UNICODE);
        } else {
            // 对于管理后台，返回普通JSON响应
            echo json_encode([
                'success' => false,
                'message' => '更新失败',
                'debug' => [
                    'pdo_error' => $pdo->errorInfo(),
                    'button_name' => $input['button_name'],
                    'button_url' => $input['button_url']
                ]
            ], JSON_UNESCAPED_UNICODE);
        }
    }
    
} catch (Exception $e) {
    // 检查是否是管理后台请求
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        session_start();
        if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
            // 管理后台请求，返回普通JSON
            echo json_encode([
                'success' => false,
                'message' => '服务器错误: ' . $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }
    
    // 客户端请求，返回加密响应
    sendEncryptedResponse([
        'success' => false,
        'message' => '服务器错误: ' . $e->getMessage()
    ]);
}
?>
