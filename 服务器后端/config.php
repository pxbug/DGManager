<?php
// 数据库配置
define('DB_HOST', 'localhost');
define('DB_NAME', 'dgglq');
define('DB_USER', 'dgglq');
define('DB_PASS', 'dgglq');

// 加密配置
define('ENCRYPTION_KEY', 'DGManager2024SecretKey!@#$%^&*()'); // 32字符密钥
define('ENCRYPTION_METHOD', 'AES-256-CBC');

// 加密函数
function encryptData($data) {
    $key = hash('sha256', ENCRYPTION_KEY, true);
    $iv = openssl_random_pseudo_bytes(16);
    $encrypted = openssl_encrypt($data, ENCRYPTION_METHOD, $key, OPENSSL_RAW_DATA, $iv);
    return base64_encode($iv . $encrypted);
}

// 解密函数
function decryptData($encryptedData) {
    $key = hash('sha256', ENCRYPTION_KEY, true);
    $data = base64_decode($encryptedData);
    $iv = substr($data, 0, 16);
    $encrypted = substr($data, 16);
    return openssl_decrypt($encrypted, ENCRYPTION_METHOD, $key, OPENSSL_RAW_DATA, $iv);
}

// 验证请求签名
function verifySignature($data, $signature, $timestamp) {
    // 检查时间戳，防止重放攻击（5分钟有效期）
    if (abs(time() - $timestamp) > 300) {
        return false;
    }
    
    $expectedSignature = hash_hmac('sha256', $data . $timestamp, ENCRYPTION_KEY);
    return hash_equals($expectedSignature, $signature);
}

// 生成响应签名
function generateSignature($data, $timestamp) {
    return hash_hmac('sha256', $data . $timestamp, ENCRYPTION_KEY);
}

// 管理员登录验证函数
function verifyAdmin($username, $password) {
    $pdo = getDB();
    $stmt = $pdo->prepare("SELECT * FROM admin_users WHERE username = ? AND password = ? AND status = 1");
    $stmt->execute([$username, $password]);
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

// 数据库连接
function getDB() {
    try {
        $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $pdo;
    } catch(PDOException $e) {
        die("数据库连接失败: " . $e->getMessage());
    }
}

// 初始化数据库表
function initDB() {
    $pdo = getDB();
    
    // 创建管理员用户表
    $adminSql = "CREATE TABLE IF NOT EXISTS admin_users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        nickname VARCHAR(100),
        status TINYINT(1) DEFAULT 1 COMMENT '1=启用 0=禁用',
        last_login TIMESTAMP NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $pdo->exec($adminSql);
    
    // 创建按钮链接表
    $linkSql = "CREATE TABLE IF NOT EXISTS button_links (
        id INT AUTO_INCREMENT PRIMARY KEY,
        button_name VARCHAR(50) NOT NULL UNIQUE,
        button_url TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $pdo->exec($linkSql);
    
    // 创建用户表
    $userSql = "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        device_uid VARCHAR(100) NOT NULL UNIQUE COMMENT '设备UID',
        points INT DEFAULT 1 COMMENT '积分数量',
        last_checkin_date DATE NULL COMMENT '最后签到日期',
        checkin_days INT DEFAULT 0 COMMENT '连续签到天数',
        total_checkin_days INT DEFAULT 0 COMMENT '总签到天数',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表'";
    
    $pdo->exec($userSql);
    
    // 创建兑换记录表
    $exchangeSql = "CREATE TABLE IF NOT EXISTS exchange_records (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL COMMENT '用户ID',
        device_uid VARCHAR(100) NOT NULL COMMENT '设备UID',
        product_name VARCHAR(100) NOT NULL COMMENT '商品名称',
        points_cost INT NOT NULL COMMENT '消耗积分',
        status TINYINT(1) DEFAULT 1 COMMENT '状态 1=成功 0=失败',
        exchange_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '兑换时间',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_device_uid (device_uid),
        INDEX idx_exchange_time (exchange_time)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='兑换记录表'";
    
    $pdo->exec($exchangeSql);
    
    // 插入默认管理员账号
    $stmt = $pdo->prepare("INSERT IGNORE INTO admin_users (username, password, nickname) VALUES (?, ?, ?)");
    $stmt->execute(['admin', '123456', '超级管理员']);
    
    // 插入默认按钮链接数据
    $defaultLinks = [
        ['TG主频道', 'https://t.me/ios5v5'],
        ['TG交流群', 'https://t.me/AiGosvip'],
        ['彩虹卡网', 'https://iosaigo.com/'],
        ['随风卡网', 'https://sf.suifengyun.cn/shop/AiGo'],
        ['永久引导页', 'https://link3.cc/iosaigo'],
        ['安装网盘', 'http://121.36.56.188:21727'],
        ['联系客服', 'http://t.me/AiGoCc']
    ];
    
    $stmt = $pdo->prepare("INSERT IGNORE INTO button_links (button_name, button_url) VALUES (?, ?)");
    foreach ($defaultLinks as $link) {
        $stmt->execute($link);
    }
}

// 用户相关函数

// 获取或创建用户
if (!function_exists('getOrCreateUser')) {
    function getOrCreateUser($deviceUID) {
        $pdo = getDB();
        
        // 先尝试获取用户
        $stmt = $pdo->prepare("SELECT * FROM users WHERE device_uid = ?");
        $stmt->execute([$deviceUID]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            // 用户不存在，创建新用户
            $stmt = $pdo->prepare("INSERT INTO users (device_uid, points) VALUES (?, 1)");
            $stmt->execute([$deviceUID]);
            
            // 获取新创建的用户
            $stmt = $pdo->prepare("SELECT * FROM users WHERE device_uid = ?");
            $stmt->execute([$deviceUID]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
        }
        
        return $user;
    }
}

// 用户签到
if (!function_exists('userCheckin')) {
    function userCheckin($deviceUID) {
    $pdo = getDB();
    $today = date('Y-m-d');
    
    // 获取用户信息
    $user = getOrCreateUser($deviceUID);
    
    // 检查今天是否已经签到
    if ($user['last_checkin_date'] === $today) {
        return [
            'success' => false,
            'message' => '今日已签到',
            'points' => $user['points']
        ];
    }
    
    // 计算连续签到天数
    $yesterday = date('Y-m-d', strtotime('-1 day'));
    $consecutiveDays = 1;
    
    if ($user['last_checkin_date'] === $yesterday) {
        $consecutiveDays = $user['checkin_days'] + 1;
    }
    
    // 更新用户签到信息
    $stmt = $pdo->prepare("
        UPDATE users 
        SET points = points + 1, 
            last_checkin_date = ?, 
            checkin_days = ?, 
            total_checkin_days = total_checkin_days + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE device_uid = ?
    ");
    $stmt->execute([$today, $consecutiveDays, $deviceUID]);
    
    return [
        'success' => true,
        'message' => '签到成功，获得1积分',
        'points' => $user['points'] + 1,
        'consecutive_days' => $consecutiveDays
    ];
    }
}

// 兑换商品
if (!function_exists('exchangeProduct')) {
    function exchangeProduct($deviceUID, $productName, $pointsCost) {
    $pdo = getDB();
    
    try {
        $pdo->beginTransaction();
        
        // 获取用户信息
        $user = getOrCreateUser($deviceUID);
        
        // 检查积分是否足够
        if ($user['points'] < $pointsCost) {
            $pdo->rollBack();
            return [
                'success' => false,
                'message' => '积分不足',
                'current_points' => $user['points'],
                'required_points' => $pointsCost
            ];
        }
        
        // 扣除积分
        $stmt = $pdo->prepare("UPDATE users SET points = points - ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?");
        $stmt->execute([$pointsCost, $user['id']]);
        
        // 记录兑换
        $stmt = $pdo->prepare("
            INSERT INTO exchange_records (user_id, device_uid, product_name, points_cost) 
            VALUES (?, ?, ?, ?)
        ");
        $stmt->execute([$user['id'], $deviceUID, $productName, $pointsCost]);
        
        $pdo->commit();
        
        return [
            'success' => true,
            'message' => '兑换成功',
            'remaining_points' => $user['points'] - $pointsCost,
            'exchange_id' => $pdo->lastInsertId()
        ];
        
    } catch (Exception $e) {
        $pdo->rollBack();
        return [
            'success' => false,
            'message' => '兑换失败：' . $e->getMessage()
        ];
    }
    }
}

// 初始化数据库
initDB();
?>
