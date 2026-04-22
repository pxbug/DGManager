<?php
session_start();
require_once 'config.php';

// 检查登录状态
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header('Location: login.php');
    exit;
}

// 处理退出登录
if (isset($_GET['logout'])) {
    session_destroy();
    header('Location: login.php');
    exit;
}

// 获取当前链接数据
$pdo = getDB();
$stmt = $pdo->query("SELECT * FROM button_links ORDER BY id");
$links = $stmt->fetchAll(PDO::FETCH_ASSOC);

// 获取用户统计数据
$userStats = [];

// 总用户数
$stmt = $pdo->query("SELECT COUNT(*) as total_users FROM users");
$userStats['total_users'] = $stmt->fetch(PDO::FETCH_ASSOC)['total_users'];

// 今日签到用户数
$today = date('Y-m-d');
$stmt = $pdo->prepare("SELECT COUNT(*) as today_checkin FROM users WHERE last_checkin_date = ?");
$stmt->execute([$today]);
$userStats['today_checkin'] = $stmt->fetch(PDO::FETCH_ASSOC)['today_checkin'];

// 总兑换记录数
$stmt = $pdo->query("SELECT COUNT(*) as total_exchanges FROM exchange_records");
$userStats['total_exchanges'] = $stmt->fetch(PDO::FETCH_ASSOC)['total_exchanges'];

// 今日兑换记录数
$stmt = $pdo->prepare("SELECT COUNT(*) as today_exchanges FROM exchange_records WHERE DATE(exchange_time) = ?");
$stmt->execute([$today]);
$userStats['today_exchanges'] = $stmt->fetch(PDO::FETCH_ASSOC)['today_exchanges'];

// 获取最近的用户和兑换记录
$stmt = $pdo->query("
    SELECT device_uid, points, checkin_days, total_checkin_days, created_at, last_checkin_date 
    FROM users 
    ORDER BY created_at DESC 
    LIMIT 10
");
$recentUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);

$stmt = $pdo->query("
    SELECT er.device_uid, er.product_name, er.points_cost, er.exchange_time, u.points as current_points
    FROM exchange_records er
    LEFT JOIN users u ON er.device_uid = u.device_uid
    ORDER BY er.exchange_time DESC 
    LIMIT 10
");
$recentExchanges = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DG管理器 - 链接管理</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: #f2f2f7;
            color: #1c1c1e;
            line-height: 1.6;
        }
        
        .header {
            background: white;
            padding: 20px 0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo-section {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .logo-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #007AFF, #5856D6);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
        }
        
        .header h1 {
            font-size: 28px;
            font-weight: 700;
            color: #1c1c1e;
        }
        
        .header p {
            color: #8e8e93;
            font-size: 16px;
        }
        
        .nav-buttons {
            display: flex;
            gap: 10px;
        }
        
        .nav-btn, .logout-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .nav-btn {
            background: #007AFF;
            color: white;
        }
        
        .nav-btn:hover {
            background: #0056CC;
            transform: translateY(-1px);
        }
        
        .logout-btn {
            background: #ff3b30;
            color: white;
        }
        
        .logout-btn:hover {
            background: #d70015;
            transform: translateY(-1px);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 30px 20px;
        }
        
        .section-title {
            font-size: 24px;
            font-weight: 600;
            color: #1c1c1e;
            margin-bottom: 20px;
        }
        
        .links-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        
        .link-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
        }
        
        .link-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }
        
        .link-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
        }
        
        .link-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #007AFF, #5856D6);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }
        
        .link-name {
            font-size: 18px;
            font-weight: 600;
            color: #1c1c1e;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            font-size: 16px;
            font-weight: 500;
            color: #1c1c1e;
            margin-bottom: 8px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e5ea;
            border-radius: 10px;
            font-size: 16px;
            background: #f9f9f9;
            transition: all 0.2s ease;
            outline: none;
        }
        
        .form-group input:focus {
            border-color: #007AFF;
            background: white;
            box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
        }
        
        .update-btn {
            background: #007AFF;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            width: 100%;
        }
        
        .update-btn:hover {
            background: #0056CC;
            transform: translateY(-1px);
        }
        
        .update-btn:active {
            transform: translateY(0);
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 15px;
            border-left: 4px solid #28a745;
            display: none;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 15px;
            border-left: 4px solid #dc3545;
            display: none;
        }
        
        .stats-section {
            background: white;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .stat-item {
            text-align: center;
            padding: 20px;
            background: #f9f9f9;
            border-radius: 12px;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: 700;
            color: #007AFF;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 16px;
            color: #8e8e93;
        }
        
        /* 用户管理样式 */
        .user-section {
            background: white;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .user-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .tab-btn {
            padding: 12px 24px;
            border: none;
            background: transparent;
            color: #8e8e93;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            border-radius: 8px 8px 0 0;
            transition: all 0.2s ease;
            position: relative;
        }
        
        .tab-btn.active {
            color: #007AFF;
            background: #f8f9fa;
        }
        
        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            right: 0;
            height: 2px;
            background: #007AFF;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .table-container {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid #e5e5ea;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        
        .data-table th {
            background: #f8f9fa;
            padding: 16px 12px;
            text-align: left;
            font-weight: 600;
            color: #1c1c1e;
            border-bottom: 1px solid #e5e5ea;
        }
        
        .data-table td {
            padding: 16px 12px;
            border-bottom: 1px solid #f0f0f0;
            color: #1c1c1e;
        }
        
        .data-table tr:hover {
            background: #f8f9fa;
        }
        
        .data-table code {
            background: #f0f0f0;
            padding: 4px 8px;
            border-radius: 6px;
            font-family: 'SF Mono', Monaco, monospace;
            font-size: 12px;
            color: #007AFF;
        }
        
        .points {
            color: #28a745;
            font-weight: 600;
        }
        
        .cost {
            color: #dc3545;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .links-grid {
                grid-template-columns: 1fr;
            }
            
            .header-content {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .container {
                padding: 20px 15px;
            }
            
            .user-tabs {
                flex-direction: column;
            }
            
            .data-table {
                font-size: 12px;
            }
            
            .data-table th,
            .data-table td {
                padding: 12px 8px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <div class="logo-section">
                <div class="logo-icon">⚙️</div>
                <div>
                    <h1>DG管理器</h1>
                    <p>链接管理系统 - 欢迎，<?php echo htmlspecialchars($_SESSION['admin_nickname'] ?? $_SESSION['admin_username'] ?? '管理员'); ?></p>
                </div>
            </div>
            <div class="nav-buttons">
                <a href="admin.php" class="nav-btn">管理员管理</a>
                <a href="?logout=1" class="logout-btn">退出登录</a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <div class="stats-section">
            <h2 class="section-title">统计信息</h2>
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-number"><?php echo count($links); ?></div>
                    <div class="stat-label">管理链接</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><?php echo $userStats['total_users']; ?></div>
                    <div class="stat-label">总用户数</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><?php echo $userStats['today_checkin']; ?></div>
                    <div class="stat-label">今日签到</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><?php echo $userStats['total_exchanges']; ?></div>
                    <div class="stat-label">总兑换数</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><?php echo $userStats['today_exchanges']; ?></div>
                    <div class="stat-label">今日兑换</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><?php echo date('m-d'); ?></div>
                    <div class="stat-label">今日日期</div>
                </div>
            </div>
        </div>
        
        <!-- 用户管理部分 -->
        <div class="user-section">
            <h2 class="section-title">用户管理</h2>
            
            <div class="user-tabs">
                <button class="tab-btn active" onclick="showTab('recent-users')">最近用户</button>
                <button class="tab-btn" onclick="showTab('recent-exchanges')">兑换记录</button>
            </div>
            
            <div id="recent-users" class="tab-content active">
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>设备UID</th>
                                <th>当前积分</th>
                                <th>连续签到</th>
                                <th>总签到天数</th>
                                <th>最后签到</th>
                                <th>注册时间</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($recentUsers as $user): ?>
                            <tr>
                                <td><code><?php echo htmlspecialchars(substr($user['device_uid'], 0, 12)); ?>...</code></td>
                                <td><span class="points"><?php echo $user['points']; ?></span></td>
                                <td><?php echo $user['checkin_days']; ?>天</td>
                                <td><?php echo $user['total_checkin_days']; ?>天</td>
                                <td><?php echo $user['last_checkin_date'] ?: '未签到'; ?></td>
                                <td><?php echo date('m-d H:i', strtotime($user['created_at'])); ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div id="recent-exchanges" class="tab-content">
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>设备UID</th>
                                <th>兑换商品</th>
                                <th>消耗积分</th>
                                <th>剩余积分</th>
                                <th>兑换时间</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($recentExchanges as $exchange): ?>
                            <tr>
                                <td><code><?php echo htmlspecialchars(substr($exchange['device_uid'], 0, 12)); ?>...</code></td>
                                <td><?php echo htmlspecialchars($exchange['product_name']); ?></td>
                                <td><span class="cost">-<?php echo $exchange['points_cost']; ?></span></td>
                                <td><span class="points"><?php echo $exchange['current_points']; ?></span></td>
                                <td><?php echo date('m-d H:i', strtotime($exchange['exchange_time'])); ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <h2 class="section-title">链接管理</h2>
        <div class="links-grid">
            <?php 
            $icons = [
                'TG主频道' => '📢',
                '公益机器人' => '🤖',
                '辅助网盘' => '☁️',
                'TG交流群' => '💬',
                '自助卡网' => '💳',
                '公益专区' => '🎮',
                '联系客服' => '🎧'
            ];
            
            foreach ($links as $link): 
            ?>
                <div class="link-card">
                    <div class="link-header">
                        <div class="link-icon"><?php echo $icons[$link['button_name']] ?? '🔗'; ?></div>
                        <div class="link-name"><?php echo htmlspecialchars($link['button_name']); ?></div>
                    </div>
                    
                    <div class="success-message" id="success-<?php echo $link['id']; ?>">更新成功！</div>
                    <div class="error-message" id="error-<?php echo $link['id']; ?>">更新失败，请重试</div>
                    
                    <form onsubmit="updateLink(event, <?php echo $link['id']; ?>, '<?php echo htmlspecialchars($link['button_name']); ?>')">
                        <div class="form-group">
                            <label>按钮名称</label>
                            <input type="text" value="<?php echo htmlspecialchars($link['button_name']); ?>" readonly>
                        </div>
                        
                        <div class="form-group">
                            <label>跳转链接</label>
                            <input type="url" id="url-<?php echo $link['id']; ?>" value="<?php echo htmlspecialchars($link['button_url']); ?>" required>
                        </div>
                        
                        <button type="submit" class="update-btn">更新链接</button>
                    </form>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
    
    <script>
        // 标签切换功能
        function showTab(tabName) {
            // 隐藏所有标签内容
            const tabContents = document.querySelectorAll('.tab-content');
            tabContents.forEach(content => {
                content.classList.remove('active');
            });
            
            // 移除所有标签按钮的活动状态
            const tabBtns = document.querySelectorAll('.tab-btn');
            tabBtns.forEach(btn => {
                btn.classList.remove('active');
            });
            
            // 显示选中的标签内容
            document.getElementById(tabName).classList.add('active');
            
            // 激活对应的标签按钮
            event.target.classList.add('active');
        }
        
        async function updateLink(event, id, buttonName) {
            event.preventDefault();
            
            const urlInput = document.getElementById(`url-${id}`);
            const successMsg = document.getElementById(`success-${id}`);
            const errorMsg = document.getElementById(`error-${id}`);
            const button = event.target.querySelector('.update-btn');
            
            // 隐藏之前的消息
            successMsg.style.display = 'none';
            errorMsg.style.display = 'none';
            
            // 显示加载状态
            const originalText = button.textContent;
            button.textContent = '更新中...';
            button.disabled = true;
            
            try {
                const response = await fetch('api.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        button_name: buttonName,
                        button_url: urlInput.value
                    })
                });
                
                const result = await response.json();
                
                if (result.success) {
                    successMsg.style.display = 'block';
                    setTimeout(() => {
                        successMsg.style.display = 'none';
                    }, 3000);
                } else {
                    let errorText = result.message || '更新失败，请重试';
                    if (result.debug) {
                        console.log('调试信息:', result.debug);
                        errorText += ' (详细信息请查看控制台)';
                    }
                    errorMsg.textContent = errorText;
                    errorMsg.style.display = 'block';
                }
            } catch (error) {
                console.error('网络请求错误:', error);
                errorMsg.textContent = '网络错误，请重试: ' + error.message;
                errorMsg.style.display = 'block';
            } finally {
                // 恢复按钮状态
                button.textContent = originalText;
                button.disabled = false;
            }
        }
    </script>
</body>
</html>
