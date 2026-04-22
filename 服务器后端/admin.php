<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DGManager API 管理面板</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
        .test-section {
            margin-bottom: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            border-left: 4px solid #007bff;
        }
        .test-section h3 {
            margin-top: 0;
            color: #007bff;
        }
        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.3s ease;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        .response {
            margin-top: 15px;
            padding: 15px;
            background: #fff;
            border-radius: 8px;
            border: 1px solid #dee2e6;
            white-space: pre-wrap;
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 12px;
            max-height: 300px;
            overflow-y: auto;
        }
        .success {
            border-left: 4px solid #28a745;
            background-color: #d4edda;
        }
        .error {
            border-left: 4px solid #dc3545;
            background-color: #f8d7da;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 DGManager API 加密测试面板</h1>
        
        <div class="test-section">
            <h3>📡 测试加密API获取</h3>
            <p>测试从API获取加密的按钮链接数据</p>
            <button onclick="testGetAPI()">测试获取API数据</button>
            <div id="getResponse" class="response" style="display: none;"></div>
        </div>

        <div class="test-section">
            <h3>🔧 加密功能测试</h3>
            <p>测试服务器端的加密和解密功能</p>
            <button onclick="testEncryption()">测试加密功能</button>
            <div id="encryptResponse" class="response" style="display: none;"></div>
        </div>

        <div class="test-section">
            <h3>📱 客户端兼容性测试</h3>
            <p>生成客户端可解析的加密响应格式</p>
            <button onclick="testClientFormat()">生成客户端测试数据</button>
            <div id="clientResponse" class="response" style="display: none;"></div>
        </div>
    </div>

    <script>
        async function testGetAPI() {
            const responseDiv = document.getElementById('getResponse');
            responseDiv.style.display = 'block';
            responseDiv.textContent = '正在请求API...';
            
            try {
                const response = await fetch('api.php');
                const data = await response.json();
                
                responseDiv.className = 'response success';
                responseDiv.textContent = '✅ API响应:\n' + JSON.stringify(data, null, 2);
            } catch (error) {
                responseDiv.className = 'response error';
                responseDiv.textContent = '❌ 请求失败:\n' + error.message;
            }
        }

        async function testEncryption() {
            const responseDiv = document.getElementById('encryptResponse');
            responseDiv.style.display = 'block';
            responseDiv.textContent = '正在测试加密功能...';
            
            try {
                const response = await fetch('test_encryption_only.php');
                const text = await response.text();
                
                responseDiv.className = 'response success';
                responseDiv.textContent = text;
            } catch (error) {
                responseDiv.className = 'response error';
                responseDiv.textContent = '❌ 测试失败:\n' + error.message;
            }
        }

        async function testClientFormat() {
            const responseDiv = document.getElementById('clientResponse');
            responseDiv.style.display = 'block';
            responseDiv.textContent = '正在生成客户端测试数据...';
            
            try {
                const response = await fetch('api.php');
                const data = await response.json();
                
                responseDiv.className = 'response success';
                responseDiv.textContent = '📱 客户端应该接收到的数据格式:\n' + JSON.stringify(data, null, 2) + '\n\n' +
                                         '🔍 数据说明:\n' +
                                         '• data: AES-256-CBC加密的JSON数据\n' +
                                         '• timestamp: 服务器时间戳\n' +
                                         '• signature: HMAC-SHA256签名\n\n' +
                                         '客户端需要:\n' +
                                         '1. 验证签名\n' +
                                         '2. 检查时间戳有效性\n' +
                                         '3. 解密data字段\n' +
                                         '4. 解析JSON获取实际数据';
            } catch (error) {
                responseDiv.className = 'response error';
                responseDiv.textContent = '❌ 生成失败:\n' + error.message;
            }
        }
    </script>
</body>
</html> 