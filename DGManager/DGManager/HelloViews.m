#import "HelloViews.h"
#import "EncryptionManager.h"
#import "ProfileViewController.h"
#import <CommonCrypto/CommonCrypto.h>

@interface HelloViews ()
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *descriptionContainer;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UILabel *copyrightLabel;
@property (nonatomic, strong) NSDictionary *buttonLinks; // 存储从API获取的链接

// 调试相关属性
@property (nonatomic, strong) UIButton *debugButton;
@property (nonatomic, strong) UIView *debugPanel;
@property (nonatomic, strong) UITextView *debugTextView;
@property (nonatomic, strong) NSMutableString *debugLog;

// 加密相关
@property (nonatomic, strong) NSString *encryptionKey;

// 私有方法声明
- (void)showErrorAlert:(NSString *)message;
- (void)setupDebugButton;
- (void)showDebugPanel;
- (void)hideDebugPanel;
- (void)copyDebugLog;
- (void)clearDebugLog;
- (void)addDebugLog:(NSString *)message;
@end

@implementation HelloViews

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.15 alpha:1.0]; // 深蓝色背景
    
    // 初始化调试日志
    self.debugLog = [[NSMutableString alloc] init];
    [self addDebugLog:@"应用启动"];
    
    // 初始化加密密钥
    self.encryptionKey = @"DGManager2024SecretKey!@#$%^&*()";
    [self addDebugLog:@"加密密钥初始化完成"];
    
    [self setupLogo];
    [self setupTitles];
    [self setupDescriptionContainer];
    [self setupProfileButton];
    [self loadButtonLinks]; // 先加载链接，再设置按钮
    [self setupCopyright];
    // [self setupDebugButton]; // 功能正常后隐藏debug按钮
}

- (void)setupLogo {
    // 创建Logo图片
    self.logoImageView = [[UIImageView alloc] init];
    self.logoImageView.image = [UIImage imageNamed:@"logo"]; // 确保添加了logo图片到项目中
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.logoImageView.clipsToBounds = YES;
    self.logoImageView.layer.cornerRadius = 60; // 设置圆角为宽度的一半
    self.logoImageView.layer.masksToBounds = YES;
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoImageView];
    
    // Logo约束 - 往上移动
    [NSLayoutConstraint activateConstraints:@[
        [self.logoImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.logoImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.logoImageView.widthAnchor constraintEqualToConstant:120],
        [self.logoImageView.heightAnchor constraintEqualToConstant:120]
    ]];
}

- (void)setupTitles {
    // 主标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"色色游戏辅助";
    self.titleLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightBold];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.8 blue:1.0 alpha:1.0]; // 浅粉色
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];
    
    // 副标题
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = @"专注热门游戏外挂";
    self.subtitleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.textColor = [UIColor colorWithRed:1.0 green:0.8 blue:1.0 alpha:1.0]; // 浅粉色
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.subtitleLabel];
    
    // 标题约束 - 减少间距
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.logoImageView.bottomAnchor constant:10],
        
        [self.subtitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5]
    ]];
}

- (void)setupDescriptionContainer {
    // 描述容器
    self.descriptionContainer = [[UIView alloc] init];
    self.descriptionContainer.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0];
    self.descriptionContainer.layer.cornerRadius = 15;
    self.descriptionContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.descriptionContainer];
    
    // 描述文本
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = @"作为深耕行业多年的老字号\n我们始终秉持专业与可靠\n致力于为每一位玩家\n提供稳定安全的游戏增强方案\n选择色色游戏定制\n就是选择一份值得信赖的持久陪伴";
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:1.0 alpha:1.0]; // 浅紫色
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.descriptionContainer addSubview:self.descriptionLabel];
    
    // 容器和文本约束 - 减少间距
    [NSLayoutConstraint activateConstraints:@[
        [self.descriptionContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.descriptionContainer.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:15],
        [self.descriptionContainer.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-40],
        
        [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.descriptionContainer.topAnchor constant:20],
        [self.descriptionLabel.bottomAnchor constraintEqualToAnchor:self.descriptionContainer.bottomAnchor constant:-20],
        [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.descriptionContainer.leadingAnchor constant:20],
        [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.descriptionContainer.trailingAnchor constant:-20]
    ]];
}

- (void)setupProfileButton {
    self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.profileButton.layer.cornerRadius = 20;
    self.profileButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.profileButton];
    
    // 创建渐变背景
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.8 green:0.4 blue:0.9 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.3 blue:0.8 alpha:1.0].CGColor
    ];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.cornerRadius = 20;
    [self.profileButton.layer insertSublayer:gradientLayer atIndex:0];
    
    // 创建图标
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:@"person.circle.fill"];
    iconView.tintColor = [UIColor whiteColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.profileButton addSubview:iconView];
    
    // 创建标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"个人中心";
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.profileButton addSubview:titleLabel];
    
    // 设置约束 - 减少间距
    [NSLayoutConstraint activateConstraints:@[
        [self.profileButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.profileButton.topAnchor constraintEqualToAnchor:self.descriptionContainer.bottomAnchor constant:10],
        [self.profileButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-40],
        [self.profileButton.heightAnchor constraintEqualToConstant:50],
        
        [iconView.leadingAnchor constraintEqualToAnchor:self.profileButton.leadingAnchor constant:20],
        [iconView.centerYAnchor constraintEqualToAnchor:self.profileButton.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:24],
        [iconView.heightAnchor constraintEqualToConstant:24],
        
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.profileButton.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:self.profileButton.centerYAnchor]
    ]];
    
    [self.profileButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.profileButton.tag = 999; // 特殊标识
    
    // 延迟设置渐变layer的frame
    dispatch_async(dispatch_get_main_queue(), ^{
        gradientLayer.frame = self.profileButton.bounds;
    });
}

- (void)setupFunctionButtons {
    self.buttonContainer = [[UIView alloc] init];
    self.buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.buttonContainer];
    
    // 按钮数据
    NSArray *buttonData = @[
        @{@"title": @"TG主频道", @"icon": @"paperplane.fill"},
        @{@"title": @"TG交流群", @"icon": @"message.fill"},
        @{@"title": @"彩虹卡网", @"icon": @"creditcard.fill"},
        @{@"title": @"随风卡网", @"icon": @"cart.fill"},
        @{@"title": @"永久引导页", @"icon": @"link"},
        @{@"title": @"安装网盘", @"icon": @"cloud.fill"},
        @{@"title": @"联系客服", @"icon": @"headphones"},
        @{@"title": @"DG管理器", @"icon": @"gear"}
    ];
    
    CGFloat spacing = 15;
    CGFloat containerWidth = [UIScreen mainScreen].bounds.size.width - 40;
    CGFloat buttonWidth = (containerWidth - spacing) / 2;
    CGFloat buttonHeight = 60;
    
    for (int i = 0; i < buttonData.count; i++) {
        int row = i / 2;
        int col = i % 2;
        NSDictionary *data = buttonData[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 15;
        button.tag = i;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.buttonContainer addSubview:button];
        
        // 创建渐变背景
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        NSArray *colors = @[
            (id)[UIColor colorWithRed:0.2 green:0.3 blue:0.8 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.4 green:0.2 blue:0.6 alpha:1.0].CGColor
        ];
        
        // 为不同按钮使用不同的渐变色
        if (i % 4 == 1) {
            colors = @[
                (id)[UIColor colorWithRed:0.8 green:0.3 blue:0.4 alpha:1.0].CGColor,
                (id)[UIColor colorWithRed:0.6 green:0.2 blue:0.7 alpha:1.0].CGColor
            ];
        } else if (i % 4 == 2) {
            colors = @[
                (id)[UIColor colorWithRed:0.3 green:0.7 blue:0.5 alpha:1.0].CGColor,
                (id)[UIColor colorWithRed:0.2 green:0.5 blue:0.8 alpha:1.0].CGColor
            ];
        } else if (i % 4 == 3) {
            colors = @[
                (id)[UIColor colorWithRed:0.9 green:0.5 blue:0.2 alpha:1.0].CGColor,
                (id)[UIColor colorWithRed:0.7 green:0.3 blue:0.5 alpha:1.0].CGColor
            ];
        }
        
        gradientLayer.colors = colors;
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        gradientLayer.cornerRadius = 15;
        [button.layer insertSublayer:gradientLayer atIndex:0];
        
        // 创建图标
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image = [UIImage systemImageNamed:data[@"icon"]];
        iconView.tintColor = [UIColor whiteColor];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [button addSubview:iconView];
        
        // 创建标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = data[@"title"];
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [button addSubview:titleLabel];
        
        // 设置按钮位置
        CGFloat x = col * (buttonWidth + spacing);
        CGFloat y = row * (buttonHeight + spacing);
        
        [NSLayoutConstraint activateConstraints:@[
            [button.leadingAnchor constraintEqualToAnchor:self.buttonContainer.leadingAnchor constant:x],
            [button.topAnchor constraintEqualToAnchor:self.buttonContainer.topAnchor constant:y],
            [button.widthAnchor constraintEqualToConstant:buttonWidth],
            [button.heightAnchor constraintEqualToConstant:buttonHeight],
            
            [iconView.leadingAnchor constraintEqualToAnchor:button.leadingAnchor constant:15],
            [iconView.centerYAnchor constraintEqualToAnchor:button.centerYAnchor],
            [iconView.widthAnchor constraintEqualToConstant:20],
            [iconView.heightAnchor constraintEqualToConstant:20],
            
            [titleLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:10],
            [titleLabel.centerYAnchor constraintEqualToAnchor:button.centerYAnchor],
            [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:button.trailingAnchor constant:-15]
        ]];
        
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        // 延迟设置渐变layer的frame
        dispatch_async(dispatch_get_main_queue(), ^{
            gradientLayer.frame = button.bounds;
        });
    }
    
    // 按钮容器约束
    CGFloat containerHeight = 4 * buttonHeight + 3 * spacing;
    [NSLayoutConstraint activateConstraints:@[
        [self.buttonContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.buttonContainer.topAnchor constraintEqualToAnchor:self.profileButton.bottomAnchor constant:20],
        [self.buttonContainer.widthAnchor constraintEqualToConstant:containerWidth],
        [self.buttonContainer.heightAnchor constraintEqualToConstant:containerHeight]
    ]];
}

- (void)setupCopyright {
    self.copyrightLabel = [[UILabel alloc] init];
    self.copyrightLabel.text = @"© 2025 色色游戏外挂  专业游戏辅助服务";
    self.copyrightLabel.font = [UIFont systemFontOfSize:12];
    self.copyrightLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.copyrightLabel.textAlignment = NSTextAlignmentCenter;
    self.copyrightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.copyrightLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.copyrightLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.copyrightLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10],
        [self.copyrightLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.copyrightLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
}

// 加载按钮链接
- (void)loadButtonLinks {
    [self addDebugLog:@"开始加载按钮链接"];
    
    // 首先设置内置备用链接，确保按钮能正常工作
    [self setupFallbackLinks];
    
    // 显示加载提示
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    loadingIndicator.color = [UIColor whiteColor];
    loadingIndicator.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    
    [NSLayoutConstraint activateConstraints:@[
        [loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    // 从服务器获取加密的链接
    NSString *urlString = [NSString stringWithFormat:@"http://156.233.232.210/api.php?t=%.0f", [[NSDate date] timeIntervalSince1970]];
    [self addDebugLog:[NSString stringWithFormat:@"请求URL: %@", urlString]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    // 强制不使用缓存
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [request setValue:@"0" forHTTPHeaderField:@"Expires"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingIndicator stopAnimating];
            [loadingIndicator removeFromSuperview];
            
            if (error) {
                [self addDebugLog:[NSString stringWithFormat:@"网络请求错误，使用备用链接: %@", error.localizedDescription]];
                NSLog(@"网络请求错误，使用备用链接: %@", error.localizedDescription);
                [self setupFunctionButtons]; // 使用备用链接设置按钮
                return;
            }
            
            [self addDebugLog:@"网络请求成功，开始解析数据"];
            
            NSError *jsonError;
            NSDictionary *encryptedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError) {
                [self addDebugLog:[NSString stringWithFormat:@"JSON解析错误，使用备用链接: %@", jsonError.localizedDescription]];
                NSLog(@"JSON解析错误，使用备用链接: %@", jsonError.localizedDescription);
                [self setupFunctionButtons]; // 使用备用链接设置按钮
                return;
            }
            
            [self addDebugLog:[NSString stringWithFormat:@"收到加密响应: %@", encryptedResponse]];
            
            // 检查是否是加密响应格式
            if (!encryptedResponse[@"data"] || !encryptedResponse[@"signature"]) {
                [self addDebugLog:@"响应格式错误，使用备用链接：缺少data或signature字段"];
                [self setupFunctionButtons]; // 使用备用链接设置按钮
                return;
            }
            
            // 解密数据
            NSString *encryptedData = encryptedResponse[@"data"];
            NSString *decryptedJson = [self decryptData:encryptedData];
            
            if (!decryptedJson) {
                [self addDebugLog:@"解密失败，使用备用链接"];
                [self setupFunctionButtons]; // 使用备用链接设置按钮
                return;
            }
            
            // 解析解密后的JSON
            NSError *decryptedJsonError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:[decryptedJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&decryptedJsonError];
            
            if (decryptedJsonError) {
                [self addDebugLog:[NSString stringWithFormat:@"解密后JSON解析错误，使用备用链接: %@", decryptedJsonError.localizedDescription]];
                [self setupFunctionButtons]; // 使用备用链接设置按钮
                return;
            }
            
            [self addDebugLog:[NSString stringWithFormat:@"解密后的响应: %@", jsonResponse]];
            
            if (!jsonResponse[@"success"] || ![jsonResponse[@"success"] boolValue]) {
                [self addDebugLog:[NSString stringWithFormat:@"API返回失败，使用备用链接: %@", jsonResponse[@"message"]]];
                NSLog(@"API返回失败，使用备用链接: %@", jsonResponse[@"message"]);
                [self setupFunctionButtons]; // 使用备用链接设置按钮
                return;
            }
            
            // 保存从服务器获取的链接（优先使用服务器链接）
            self.buttonLinks = jsonResponse[@"data"];
            [self addDebugLog:[NSString stringWithFormat:@"成功获取服务器链接数据: %@", self.buttonLinks]];
            [self setupFunctionButtons];
        });
    }];
    
    [task resume];
}

// 设置内置备用链接
- (void)setupFallbackLinks {
    // 内置备用链接，确保即使服务器失败也能正常工作
    self.buttonLinks = @{
        @"TG主频道": @"https://t.me/ios5v5",
        @"TG交流群": @"https://t.me/AiGosvip", 
        @"彩虹卡网": @"https://iosaigo.com/",
        @"随风卡网": @"https://sf.suifengyun.cn/shop/AiGo",
        @"永久引导页": @"https://link3.cc/iosaigo",
        @"安装网盘": @"http://121.36.56.188:21727",
        @"联系客服": @"http://t.me/AiGoCc"
    };
    
    [self addDebugLog:[NSString stringWithFormat:@"设置内置备用链接: %@", self.buttonLinks]];
}

// 加密版本的API请求（备用）
- (void)loadButtonLinksWithEncryption {
    // 创建带签名的请求 - 添加缓存控制
    NSString *urlString = [NSString stringWithFormat:@"http://156.233.232.210/api.php?t=%.0f", [[NSDate date] timeIntervalSince1970]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    // 强制不使用缓存
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [request setValue:@"0" forHTTPHeaderField:@"Expires"];
    
    // 生成时间戳和签名
    EncryptionManager *encryptionManager = [EncryptionManager sharedManager];
    NSTimeInterval timestamp = [encryptionManager getCurrentTimestamp];
    NSString *requestData = url.absoluteString; // GET请求使用URL作为签名数据
    NSString *signature = [encryptionManager generateSignature:requestData timestamp:timestamp];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                // 网络请求失败，显示错误提示
                [self showErrorAlert:@"网络请求失败，无法获取最新链接"];
                return;
            }
            
            NSError *jsonError;
            NSDictionary *encryptedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError) {
                [self showErrorAlert:@"数据解析失败"];
                return;
            }
            
            // 解密响应数据
            NSString *encryptedData = encryptedResponse[@"data"];
            
            if (!encryptedData) {
                [self showErrorAlert:@"服务器返回数据格式错误"];
                return;
            }
            
            // 暂时跳过签名验证，直接解密数据
            NSString *decryptedJson = [encryptionManager decryptData:encryptedData];
            if (!decryptedJson) {
                [self showErrorAlert:@"数据解密失败"];
                return;
            }
            
            // 解析解密后的JSON
            NSData *decryptedData = [decryptedJson dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:decryptedData options:0 error:&jsonError];
            
            if (jsonError || !jsonResponse[@"success"] || ![jsonResponse[@"success"] boolValue]) {
                [self showErrorAlert:@"服务器返回错误信息"];
                return;
            }
            
            // 保存API返回的链接
            self.buttonLinks = jsonResponse[@"data"];
            [self setupFunctionButtons];
        });
    }];
    
    [task resume];
}



- (void)buttonTapped:(UIButton *)sender {
    [self addDebugLog:[NSString stringWithFormat:@"按钮被点击，tag: %ld", (long)sender.tag]];
    
    // 如果是调试按钮
    if (sender.tag == 1000) {
        [self showDebugPanel];
        return;
    }
    
    // 如果是个人中心按钮，跳转到个人中心页面
    if (sender.tag == 999) {
        [self addDebugLog:@"打开个人中心"];
        ProfileViewController *profileVC = [[ProfileViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileVC];
        
        // 设置导航栏样式
        navController.navigationBar.barStyle = UIBarStyleBlack;
        navController.navigationBar.translucent = YES;
        navController.navigationBar.tintColor = [UIColor whiteColor];
        
        // 添加关闭按钮
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                     target:self 
                                                                                     action:@selector(closeProfileView)];
        profileVC.navigationItem.rightBarButtonItem = closeButton;
        
        [self presentViewController:navController animated:YES completion:nil];
        return;
    }
    
    // 如果是DG管理器按钮，关闭当前页面并进入APP列表
    if (sender.tag == 7) {
        [self addDebugLog:@"返回DG管理器主界面"];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // 获取按钮对应的链接（注意：个人中心和DG管理器是本地功能，不在此列表中）
    NSArray *buttonNames = @[@"TG主频道", @"TG交流群", @"彩虹卡网", @"随风卡网", @"永久引导页", @"安装网盘", @"联系客服"];
    
    if (sender.tag < buttonNames.count) {
        NSString *buttonName = buttonNames[sender.tag];
        NSString *urlString = self.buttonLinks[buttonName];
        
        [self addDebugLog:[NSString stringWithFormat:@"点击按钮: %@, URL: %@", buttonName, urlString]];
        
        if (urlString && urlString.length > 0) {
            NSURL *url = [NSURL URLWithString:urlString];
            if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                [self addDebugLog:[NSString stringWithFormat:@"成功打开URL: %@", urlString]];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [self addDebugLog:[NSString stringWithFormat:@"无法打开URL: %@", urlString]];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法打开链接" 
                                                                               message:[NSString stringWithFormat:@"无法打开 %@ 的链接，请检查网络连接或稍后重试。", buttonName] 
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        } else {
            [self addDebugLog:[NSString stringWithFormat:@"按钮 %@ 没有对应的URL，尝试重新加载链接", buttonName]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"链接获取失败" 
                                                                           message:[NSString stringWithFormat:@"%@ 的链接暂时无法获取，是否重新尝试加载？", buttonName] 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重试" 
                                                                  style:UIAlertActionStyleDefault 
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    [self loadButtonLinks];
                                                                }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:retryAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)closeProfileView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 显示错误提示
- (void)showErrorAlert:(NSString *)message {
    [self addDebugLog:[NSString stringWithFormat:@"显示错误提示: %@", message]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" 
                                                                   message:message 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" 
                                                       style:UIAlertActionStyleDefault 
                                                     handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 加密解密功能

// SHA256哈希
- (NSData *)sha256:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], hash);
    return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
}

// AES解密
- (NSString *)decryptData:(NSString *)encryptedData {
    if (!encryptedData || encryptedData.length == 0) {
        [self addDebugLog:@"解密失败：输入数据为空"];
        return nil;
    }
    
    [self addDebugLog:[NSString stringWithFormat:@"开始解密数据，长度: %lu", (unsigned long)encryptedData.length]];
    
    // Base64解码
    NSData *data = [[NSData alloc] initWithBase64EncodedString:encryptedData options:0];
    if (!data || data.length < 16) {
        [self addDebugLog:@"解密失败：Base64解码失败或数据太短"];
        return nil;
    }
    
    [self addDebugLog:[NSString stringWithFormat:@"Base64解码后数据长度: %lu", (unsigned long)data.length]];
    
    // 提取IV（前16字节）和加密数据（剩余部分）
    NSData *iv = [data subdataWithRange:NSMakeRange(0, 16)];
    NSData *encryptedBytes = [data subdataWithRange:NSMakeRange(16, data.length - 16)];
    
    [self addDebugLog:[NSString stringWithFormat:@"IV长度: %lu, 加密数据长度: %lu", (unsigned long)iv.length, (unsigned long)encryptedBytes.length]];
    
    // 生成密钥 - 使用SHA256哈希
    NSData *key = [self sha256:self.encryptionKey];
    [self addDebugLog:[NSString stringWithFormat:@"密钥长度: %lu", (unsigned long)key.length]];
    
    // 解密
    size_t bufferSize = encryptedBytes.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(
        kCCDecrypt,
        kCCAlgorithmAES,
        kCCOptionPKCS7Padding,
        key.bytes,
        kCCKeySizeAES256,
        iv.bytes,
        encryptedBytes.bytes,
        encryptedBytes.length,
        buffer,
        bufferSize,
        &numBytesDecrypted
    );
    
    [self addDebugLog:[NSString stringWithFormat:@"解密操作状态: %d, 解密字节数: %zu", cryptStatus, numBytesDecrypted]];
    
    if (cryptStatus == kCCSuccess) {
        NSData *decryptedData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted freeWhenDone:YES];
        NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        
        if (decryptedString) {
            [self addDebugLog:[NSString stringWithFormat:@"解密成功，解密后长度: %lu", (unsigned long)decryptedString.length]];
            [self addDebugLog:[NSString stringWithFormat:@"解密后内容预览: %@", [decryptedString substringToIndex:MIN(100, decryptedString.length)]]];
            return decryptedString;
        } else {
            [self addDebugLog:@"解密成功但UTF-8转换失败"];
            free(buffer);
            return nil;
        }
    } else {
        [self addDebugLog:[NSString stringWithFormat:@"解密失败，错误代码: %d", cryptStatus]];
        free(buffer);
        return nil;
    }
}

#pragma mark - 调试功能

// 设置调试按钮
- (void)setupDebugButton {
    self.debugButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.debugButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:0.8];
    self.debugButton.layer.cornerRadius = 25;
    self.debugButton.tag = 1000;
    self.debugButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.debugButton];
    
    // 创建调试图标
    UILabel *debugIcon = [[UILabel alloc] init];
    debugIcon.text = @"🐛";
    debugIcon.font = [UIFont systemFontOfSize:20];
    debugIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.debugButton addSubview:debugIcon];
    
    // 设置约束 - 放在右上角
    [NSLayoutConstraint activateConstraints:@[
        [self.debugButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.debugButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.debugButton.widthAnchor constraintEqualToConstant:50],
        [self.debugButton.heightAnchor constraintEqualToConstant:50],
        
        [debugIcon.centerXAnchor constraintEqualToAnchor:self.debugButton.centerXAnchor],
        [debugIcon.centerYAnchor constraintEqualToAnchor:self.debugButton.centerYAnchor]
    ]];
    
    [self.debugButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

// 显示调试面板
- (void)showDebugPanel {
    if (self.debugPanel) {
        return; // 如果已经显示，直接返回
    }
    
    // 创建调试面板背景
    self.debugPanel = [[UIView alloc] init];
    self.debugPanel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    self.debugPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.debugPanel];
    
    // 创建内容容器
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    contentView.layer.cornerRadius = 15;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.debugPanel addSubview:contentView];
    
    // 创建标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"调试面板";
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:titleLabel];
    
    // 创建调试文本视图
    self.debugTextView = [[UITextView alloc] init];
    self.debugTextView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    self.debugTextView.textColor = [UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:1.0];
    self.debugTextView.font = [UIFont fontWithName:@"Menlo" size:12];
    self.debugTextView.layer.cornerRadius = 8;
    self.debugTextView.editable = NO;
    self.debugTextView.text = self.debugLog;
    self.debugTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.debugTextView];
    
    // 创建按钮容器
    UIView *buttonContainer = [[UIView alloc] init];
    buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:buttonContainer];
    
    // 复制全部按钮
    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [copyButton setTitle:@"复制全部" forState:UIControlStateNormal];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    copyButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    copyButton.layer.cornerRadius = 8;
    copyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [copyButton addTarget:self action:@selector(copyDebugLog) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:copyButton];
    
    // 清空按钮
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];
    clearButton.layer.cornerRadius = 8;
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [clearButton addTarget:self action:@selector(clearDebugLog) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:clearButton];
    
    // 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    closeButton.layer.cornerRadius = 8;
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(hideDebugPanel) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:closeButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 调试面板约束
        [self.debugPanel.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.debugPanel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.debugPanel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.debugPanel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        // 内容容器约束
        [contentView.centerXAnchor constraintEqualToAnchor:self.debugPanel.centerXAnchor],
        [contentView.centerYAnchor constraintEqualToAnchor:self.debugPanel.centerYAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:self.debugPanel.widthAnchor constant:-40],
        [contentView.heightAnchor constraintEqualToAnchor:self.debugPanel.heightAnchor constant:-100],
        
        // 标题约束
        [titleLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        
        // 文本视图约束
        [self.debugTextView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.debugTextView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.debugTextView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [self.debugTextView.bottomAnchor constraintEqualToAnchor:buttonContainer.topAnchor constant:-15],
        
        // 按钮容器约束
        [buttonContainer.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [buttonContainer.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [buttonContainer.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20],
        [buttonContainer.heightAnchor constraintEqualToConstant:50],
        
        // 复制按钮约束
        [copyButton.leadingAnchor constraintEqualToAnchor:buttonContainer.leadingAnchor],
        [copyButton.topAnchor constraintEqualToAnchor:buttonContainer.topAnchor],
        [copyButton.bottomAnchor constraintEqualToAnchor:buttonContainer.bottomAnchor],
        [copyButton.widthAnchor constraintEqualToAnchor:buttonContainer.widthAnchor multiplier:0.3],
        
        // 清空按钮约束
        [clearButton.centerXAnchor constraintEqualToAnchor:buttonContainer.centerXAnchor],
        [clearButton.topAnchor constraintEqualToAnchor:buttonContainer.topAnchor],
        [clearButton.bottomAnchor constraintEqualToAnchor:buttonContainer.bottomAnchor],
        [clearButton.widthAnchor constraintEqualToAnchor:buttonContainer.widthAnchor multiplier:0.3],
        
        // 关闭按钮约束
        [closeButton.trailingAnchor constraintEqualToAnchor:buttonContainer.trailingAnchor],
        [closeButton.topAnchor constraintEqualToAnchor:buttonContainer.topAnchor],
        [closeButton.bottomAnchor constraintEqualToAnchor:buttonContainer.bottomAnchor],
        [closeButton.widthAnchor constraintEqualToAnchor:buttonContainer.widthAnchor multiplier:0.3]
    ]];
    
    // 添加动画效果
    self.debugPanel.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.debugPanel.alpha = 1.0;
    }];
    
    // 滚动到底部
    if (self.debugTextView.text.length > 0) {
        [self.debugTextView scrollRangeToVisible:NSMakeRange(self.debugTextView.text.length - 1, 1)];
    }
}

// 隐藏调试面板
- (void)hideDebugPanel {
    if (!self.debugPanel) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.debugPanel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.debugPanel removeFromSuperview];
        self.debugPanel = nil;
        self.debugTextView = nil;
    }];
}

// 复制调试日志
- (void)copyDebugLog {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.debugLog;
    
    [self addDebugLog:@"调试日志已复制到剪贴板"];
    self.debugTextView.text = self.debugLog;
    
    // 显示复制成功提示
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"复制成功" 
                                                                   message:@"调试日志已复制到剪贴板" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" 
                                                       style:UIAlertActionStyleDefault 
                                                     handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 清空调试日志
- (void)clearDebugLog {
    [self.debugLog setString:@""];
    [self addDebugLog:@"调试日志已清空"];
    self.debugTextView.text = self.debugLog;
}

// 添加调试日志
- (void)addDebugLog:(NSString *)message {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    
    NSString *logEntry = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];
    [self.debugLog appendString:logEntry];
    
    // 如果调试面板正在显示，更新文本视图
    if (self.debugTextView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.debugTextView.text = self.debugLog;
            // 滚动到底部
            if (self.debugTextView.text.length > 0) {
                [self.debugTextView scrollRangeToVisible:NSMakeRange(self.debugTextView.text.length - 1, 1)];
            }
        });
    }
}

@end 
 