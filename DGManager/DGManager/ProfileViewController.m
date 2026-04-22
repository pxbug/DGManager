#import "ProfileViewController.h"
#import <UIKit/UIKit.h>

@interface ProfileViewController ()
@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, strong) UILabel *daysLabel;
@property (nonatomic, strong) UIButton *checkInButton;
@property (nonatomic, assign) NSInteger currentPoints;
@property (nonatomic, assign) NSInteger checkinDays;
@property (nonatomic, strong) NSString *baseURL;
@end

@implementation ProfileViewController

// 获取格式化的设备UID - 只显示12位
- (NSString *)getFormattedDeviceUID {
    NSString *deviceUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if (!deviceUID || deviceUID.length == 0) {
        deviceUID = @"UNKNOWN-DEVICE-IDENTIFIER";
    }
    
    // 移除连字符，只保留字母数字
    deviceUID = [deviceUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // 如果长度不足12位，用0补齐
    if (deviceUID.length < 12) {
        deviceUID = [deviceUID stringByPaddingToLength:12 withString:@"0" startingAtIndex:0];
    }
    
    // 只显示前12位
    if (deviceUID.length >= 12) {
        NSString *shortUID = [deviceUID substringToIndex:12];
        return [NSString stringWithFormat:@"UID: %@", shortUID];
    }
    
    return [NSString stringWithFormat:@"UID: %@", deviceUID];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置后端API地址
    self.baseURL = @"http://156.233.232.210/user_api.php"; // 用户相关功能仍使用user_api.php
    
    // 设置背景颜色与主视图保持一致
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.15 alpha:1.0];
    
    // 设置导航栏标题
    self.title = @"个人中心";
    
    // 初始化数据
    self.currentPoints = 1; // 默认值，将从服务器获取
    self.checkinDays = 0;
    
    [self setupProfileUI];
    [self loadUserData]; // 加载用户数据
}

- (void)setupProfileUI {
    // 创建长方形背景容器
    UIView *backgroundContainer = [[UIView alloc] init];
    backgroundContainer.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0]; // 青蓝色渐变背景
    backgroundContainer.layer.cornerRadius = 20;
    backgroundContainer.layer.masksToBounds = YES;
    backgroundContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 添加渐变效果
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0].CGColor,  // 青色
        (id)[UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0].CGColor   // 蓝色
    ];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.cornerRadius = 20;
    [backgroundContainer.layer insertSublayer:gradientLayer atIndex:0];
    
    [self.view addSubview:backgroundContainer];
    
    // 创建圆形图像视图
    UIImageView *profileImageView = [[UIImageView alloc] init];
    profileImageView.image = [UIImage imageNamed:@"ikun"];
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    profileImageView.layer.cornerRadius = 60; // 半径为60，直径为120
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 4;
    profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [backgroundContainer addSubview:profileImageView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 背景容器约束
        [backgroundContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [backgroundContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40],
        [backgroundContainer.widthAnchor constraintEqualToConstant:380],
        [backgroundContainer.heightAnchor constraintEqualToConstant:200],
        
        // 圆形图像约束 - 居中显示
        [profileImageView.centerXAnchor constraintEqualToAnchor:backgroundContainer.centerXAnchor],
        [profileImageView.centerYAnchor constraintEqualToAnchor:backgroundContainer.centerYAnchor],
        [profileImageView.widthAnchor constraintEqualToConstant:120],
        [profileImageView.heightAnchor constraintEqualToConstant:120]
    ]];
    
    // 创建信息面板容器
    UIView *infoPanel = [[UIView alloc] init];
    infoPanel.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    infoPanel.layer.cornerRadius = 15;
    infoPanel.layer.shadowColor = [UIColor blackColor].CGColor;
    infoPanel.layer.shadowOffset = CGSizeMake(0, 2);
    infoPanel.layer.shadowOpacity = 0.1;
    infoPanel.layer.shadowRadius = 5;
    infoPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:infoPanel];
    
    // UID标签
    UILabel *uidLabel = [[UILabel alloc] init];
    uidLabel.text = [self getFormattedDeviceUID];
    uidLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    uidLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    uidLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [infoPanel addSubview:uidLabel];
    
    // 积分标签
    self.pointsLabel = [[UILabel alloc] init];
    self.pointsLabel.text = [NSString stringWithFormat:@"当前积分: %ld", (long)self.currentPoints];
    self.pointsLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.pointsLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.pointsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [infoPanel addSubview:self.pointsLabel];
    
    // 签到天数标签
    self.daysLabel = [[UILabel alloc] init];
    self.daysLabel.text = [NSString stringWithFormat:@"已签到 %ld 天", (long)self.checkinDays];
    self.daysLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.daysLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.daysLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [infoPanel addSubview:self.daysLabel];
    
    // 签到按钮
    self.checkInButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.checkInButton setTitle:@"每日签到" forState:UIControlStateNormal];
    [self.checkInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.checkInButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.checkInButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    self.checkInButton.layer.cornerRadius = 25;
    self.checkInButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.checkInButton addTarget:self action:@selector(checkInButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [infoPanel addSubview:self.checkInButton];
    
    // 积分兑换面板
    UIView *exchangePanel = [[UIView alloc] init];
    exchangePanel.backgroundColor = [UIColor whiteColor];
    exchangePanel.layer.cornerRadius = 15;
    exchangePanel.layer.shadowColor = [UIColor blackColor].CGColor;
    exchangePanel.layer.shadowOffset = CGSizeMake(0, 2);
    exchangePanel.layer.shadowOpacity = 0.1;
    exchangePanel.layer.shadowRadius = 5;
    exchangePanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:exchangePanel];
    
    // 兑换标题
    UILabel *exchangeTitle = [[UILabel alloc] init];
    exchangeTitle.text = @"积分兑换";
    exchangeTitle.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    exchangeTitle.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    exchangeTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [exchangePanel addSubview:exchangeTitle];
    
    // 商品容器 - 无额外容器样式，因为已在exchangePanel容器中
    UIView *itemContainer = [[UIView alloc] init];
    itemContainer.backgroundColor = [UIColor clearColor]; // 透明背景
    itemContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [exchangePanel addSubview:itemContainer];
    
    // 商品图标
    UILabel *itemIcon = [[UILabel alloc] init];
    itemIcon.text = @"🎫";
    itemIcon.font = [UIFont systemFontOfSize:24];
    itemIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [itemContainer addSubview:itemIcon];
    
    // 商品名称
    UILabel *itemName = [[UILabel alloc] init];
    itemName.text = @"天卡";
    itemName.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    itemName.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    itemName.translatesAutoresizingMaskIntoConstraints = NO;
    [itemContainer addSubview:itemName];
    
    // 移除商品描述，保持简洁设计
    
    // 积分价格标签 - 蓝色价格样式
    UILabel *priceLabel = [[UILabel alloc] init];
    priceLabel.text = @"20积分";
    priceLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    priceLabel.textColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0]; // 蓝色
    priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [itemContainer addSubview:priceLabel];
    
    // 兑换按钮 - 黄色立即购买样式
    UIButton *exchangeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [exchangeButton setTitle:@"🛒 立即兑换" forState:UIControlStateNormal];
    [exchangeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    exchangeButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    exchangeButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0]; // 金黄色背景
    exchangeButton.layer.cornerRadius = 20;
    exchangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [exchangeButton addTarget:self action:@selector(exchangeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [exchangePanel addSubview:exchangeButton];
    
    // 信息面板约束
    [NSLayoutConstraint activateConstraints:@[
        // 信息面板约束
        [infoPanel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [infoPanel.topAnchor constraintEqualToAnchor:backgroundContainer.bottomAnchor constant:20],
        [infoPanel.widthAnchor constraintEqualToConstant:380],
        [infoPanel.heightAnchor constraintEqualToConstant:160],
        
        // UID标签约束
        [uidLabel.leadingAnchor constraintEqualToAnchor:infoPanel.leadingAnchor constant:20],
        [uidLabel.topAnchor constraintEqualToAnchor:infoPanel.topAnchor constant:20],
        
        // 积分标签约束
        [self.pointsLabel.trailingAnchor constraintEqualToAnchor:infoPanel.trailingAnchor constant:-20],
        [self.pointsLabel.topAnchor constraintEqualToAnchor:infoPanel.topAnchor constant:20],
        
        // 签到天数标签约束
        [self.daysLabel.centerXAnchor constraintEqualToAnchor:infoPanel.centerXAnchor],
        [self.daysLabel.topAnchor constraintEqualToAnchor:uidLabel.bottomAnchor constant:15],
        
        // 签到按钮约束
        [self.checkInButton.centerXAnchor constraintEqualToAnchor:infoPanel.centerXAnchor],
        [self.checkInButton.topAnchor constraintEqualToAnchor:self.daysLabel.bottomAnchor constant:20],
        [self.checkInButton.widthAnchor constraintEqualToConstant:120],
        [self.checkInButton.heightAnchor constraintEqualToConstant:50],
        
        // 积分兑换面板约束 - 增加高度以容纳新布局
        [exchangePanel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [exchangePanel.topAnchor constraintEqualToAnchor:infoPanel.bottomAnchor constant:20],
        [exchangePanel.widthAnchor constraintEqualToConstant:380],
        [exchangePanel.heightAnchor constraintEqualToConstant:140],
        
        // 兑换标题约束
        [exchangeTitle.leadingAnchor constraintEqualToAnchor:exchangePanel.leadingAnchor constant:20],
        [exchangeTitle.topAnchor constraintEqualToAnchor:exchangePanel.topAnchor constant:15],
        
        // 商品容器约束 - 调整为上半部分，为按钮留出下半部分空间
        [itemContainer.leadingAnchor constraintEqualToAnchor:exchangePanel.leadingAnchor constant:20],
        [itemContainer.trailingAnchor constraintEqualToAnchor:exchangePanel.trailingAnchor constant:-20],
        [itemContainer.topAnchor constraintEqualToAnchor:exchangeTitle.bottomAnchor constant:10],
        [itemContainer.heightAnchor constraintEqualToConstant:50],
        
        // 商品图标约束
        [itemIcon.leadingAnchor constraintEqualToAnchor:itemContainer.leadingAnchor constant:15],
        [itemIcon.centerYAnchor constraintEqualToAnchor:itemContainer.centerYAnchor],
        
        // 商品名称约束 - 居中显示
        [itemName.leadingAnchor constraintEqualToAnchor:itemIcon.trailingAnchor constant:10],
        [itemName.centerYAnchor constraintEqualToAnchor:itemContainer.centerYAnchor],
        
        // 积分价格约束 - 放在右侧
        [priceLabel.trailingAnchor constraintEqualToAnchor:itemContainer.trailingAnchor constant:-15],
        [priceLabel.centerYAnchor constraintEqualToAnchor:itemContainer.centerYAnchor],
        
        // 兑换按钮约束 - 独立在下方居中显示
        [exchangeButton.centerXAnchor constraintEqualToAnchor:exchangePanel.centerXAnchor],
        [exchangeButton.topAnchor constraintEqualToAnchor:itemContainer.bottomAnchor constant:15],
        [exchangeButton.widthAnchor constraintEqualToConstant:120],
        [exchangeButton.heightAnchor constraintEqualToConstant:40]
    ]];
    
    // 延迟设置渐变层的frame，确保容器布局完成
    dispatch_async(dispatch_get_main_queue(), ^{
        gradientLayer.frame = backgroundContainer.bounds;
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // TODO: 刷新个人信息等数据
}

- (void)checkInButtonTapped:(UIButton *)sender {
    // 调用签到API
    [self performCheckin];
}

- (void)exchangeButtonTapped:(UIButton *)sender {
    // 检查积分是否足够
    int requiredPoints = 20;
    
    if (self.currentPoints >= requiredPoints) {
        // 积分足够，调用后端API进行兑换
        [self exchangeProductWithName:@"天卡" pointsCost:requiredPoints];
    } else {
        // 积分不足，显示提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"积分不足" 
                                                                       message:[NSString stringWithFormat:@"兑换天卡需要%d积分，当前积分：%ld", requiredPoints, (long)self.currentPoints]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" 
                                                           style:UIAlertActionStyleDefault 
                                                         handler:nil];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// 生成兑换表单图片
- (void)generateExchangeFormImage {
    // 创建图片尺寸 (iPhone 屏幕比例)
    CGSize imageSize = CGSizeMake(750, 1334);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置白色背景
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    // 绘制表单内容
    [self drawFormContentInContext:context size:imageSize];
    
    // 添加水印
    [self drawWatermarkInContext:context size:imageSize];
    
    // 获取生成的图片
    UIImage *formImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 保存到相册
    [self saveImageToPhotoAlbum:formImage];
}

// 绘制表单内容
- (void)drawFormContentInContext:(CGContextRef)context size:(CGSize)size {
    // 获取当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    
    // 获取设备UID
    NSString *deviceUID = [self getFormattedDeviceUID];
    
    // 标题
    NSString *title = @"DG Manager 兑换凭证";
    NSDictionary *titleAttributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:36],
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0]
    };
    CGSize titleSize = [title sizeWithAttributes:titleAttributes];
    CGRect titleRect = CGRectMake((size.width - titleSize.width) / 2, 80, titleSize.width, titleSize.height);
    [title drawInRect:titleRect withAttributes:titleAttributes];
    
    // 分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, 50, 180);
    CGContextAddLineToPoint(context, size.width - 50, 180);
    CGContextStrokePath(context);
    
    // 表单内容样式
    NSDictionary *labelAttributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:24],
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]
    };
    NSDictionary *valueAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:22],
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]
    };
    
    CGFloat startY = 250;
    CGFloat lineHeight = 80;
    CGFloat leftMargin = 80;
    
    // 用户ID
    NSString *uidLabel = @"用户ID:";
    [uidLabel drawAtPoint:CGPointMake(leftMargin, startY) withAttributes:labelAttributes];
    [deviceUID drawAtPoint:CGPointMake(leftMargin, startY + 35) withAttributes:valueAttributes];
    
    // 兑换商品
    NSString *productLabel = @"兑换商品:";
    [productLabel drawAtPoint:CGPointMake(leftMargin, startY + lineHeight) withAttributes:labelAttributes];
    NSString *productValue = @"天卡 (20积分)";
    [productValue drawAtPoint:CGPointMake(leftMargin, startY + lineHeight + 35) withAttributes:valueAttributes];
    
    // 兑换时间
    NSString *timeLabel = @"兑换时间:";
    [timeLabel drawAtPoint:CGPointMake(leftMargin, startY + lineHeight * 2) withAttributes:labelAttributes];
    [currentTime drawAtPoint:CGPointMake(leftMargin, startY + lineHeight * 2 + 35) withAttributes:valueAttributes];
    
    // 状态
    NSString *statusLabel = @"状态:";
    [statusLabel drawAtPoint:CGPointMake(leftMargin, startY + lineHeight * 3) withAttributes:labelAttributes];
    NSString *statusValue = @"兑换成功，请联系客服";
    NSDictionary *statusAttributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:22],
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0]
    };
    [statusValue drawAtPoint:CGPointMake(leftMargin, startY + lineHeight * 3 + 35) withAttributes:statusAttributes];
    
    // 底部提示
    NSString *notice = @"请保存此图片并发送给客服完成兑换";
    NSDictionary *noticeAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:18],
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]
    };
    CGSize noticeSize = [notice sizeWithAttributes:noticeAttributes];
    CGRect noticeRect = CGRectMake((size.width - noticeSize.width) / 2, size.height - 150, noticeSize.width, noticeSize.height);
    [notice drawInRect:noticeRect withAttributes:noticeAttributes];
}

// 绘制水印
- (void)drawWatermarkInContext:(CGContextRef)context size:(CGSize)size {
    // 保存当前图形状态
    CGContextSaveGState(context);
    
    // 获取当前时间作为水印
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *watermark = [formatter stringFromDate:[NSDate date]];
    
    NSDictionary *watermarkAttributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:36],
        NSForegroundColorAttributeName: [UIColor colorWithWhite:0.9 alpha:0.25]
    };
    
    // 计算水印尺寸
    CGSize watermarkSize = [watermark sizeWithAttributes:watermarkAttributes];
    
    // 设置旋转变换 (45度)
    CGFloat angle = M_PI / 4; // 45度
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextRotateCTM(context, angle);
    
    // 只绘制3个水印，确保完全不重叠
    NSArray *positions = @[
        [NSValue valueWithCGPoint:CGPointMake(-300, -250)],  // 左上
        [NSValue valueWithCGPoint:CGPointMake(300, 0)],      // 右中
        [NSValue valueWithCGPoint:CGPointMake(-100, 300)]    // 左下偏右
    ];
    
    for (NSValue *posValue in positions) {
        CGPoint pos = [posValue CGPointValue];
        CGPoint position = CGPointMake(pos.x - watermarkSize.width / 2, 
                                     pos.y - watermarkSize.height / 2);
        [watermark drawAtPoint:position withAttributes:watermarkAttributes];
    }
    
    // 恢复图形状态
    CGContextRestoreGState(context);
}

// 保存图片到相册
- (void)saveImageToPhotoAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// 保存完成回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存失败" 
                                                                           message:@"无法保存兑换凭证到相册，请检查相册权限。" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"兑换成功！" 
                                                                           message:@"兑换凭证已保存到相册📸\n请发送给客服完成兑换流程。" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" 
                                                               style:UIAlertActionStyleDefault 
                                                             handler:^(UIAlertAction * _Nonnull action) {
                // TODO: 实际的兑换逻辑
                // 1. 扣除积分
                // 2. 记录兑换历史
                // 3. 更新UI显示的积分数量
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

#pragma mark - 网络请求方法

// 加载用户数据
- (void)loadUserData {
    NSString *deviceUID = [self getDeviceUID];
    NSString *urlString = [NSString stringWithFormat:@"%@?action=get_user_info", self.baseURL];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestData = @{@"device_uid": deviceUID};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    
    if (error) {
        NSLog(@"JSON序列化错误: %@", error.localizedDescription);
        return;
    }
    
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"网络请求错误: %@", error.localizedDescription);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"JSON解析错误: %@", jsonError.localizedDescription);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([responseData[@"success"] boolValue]) {
                NSDictionary *userData = responseData[@"data"];
                self.currentPoints = [userData[@"points"] integerValue];
                self.checkinDays = [userData[@"checkin_days"] integerValue];
                
                // 更新UI
                [self updateUI];
            } else {
                NSLog(@"获取用户数据失败: %@", responseData[@"message"]);
            }
        });
    }];
    
    [task resume];
}

// 用户签到
- (void)performCheckin {
    NSString *deviceUID = [self getDeviceUID];
    NSString *urlString = [NSString stringWithFormat:@"%@?action=checkin", self.baseURL];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestData = @{@"device_uid": deviceUID};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    
    if (error) {
        NSLog(@"JSON序列化错误: %@", error.localizedDescription);
        return;
    }
    
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"网络请求错误: %@", error.localizedDescription);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"JSON解析错误: %@", jsonError.localizedDescription);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = responseData[@"message"];
            NSString *title = [responseData[@"success"] boolValue] ? @"签到成功" : @"签到失败";
            
            if ([responseData[@"success"] boolValue]) {
                // 更新本地数据
                self.currentPoints = [responseData[@"data"][@"points"] integerValue];
                self.checkinDays = [responseData[@"data"][@"consecutive_days"] integerValue];
                [self updateUI];
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    }];
    
    [task resume];
}

// 兑换商品
- (void)exchangeProductWithName:(NSString *)productName pointsCost:(NSInteger)pointsCost {
    NSString *deviceUID = [self getDeviceUID];
    NSString *urlString = [NSString stringWithFormat:@"%@?action=exchange", self.baseURL];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestData = @{
        @"device_uid": deviceUID,
        @"product_name": productName,
        @"points_cost": @(pointsCost)
    };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    
    if (error) {
        NSLog(@"JSON序列化错误: %@", error.localizedDescription);
        return;
    }
    
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"网络请求错误: %@", error.localizedDescription);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"JSON解析错误: %@", jsonError.localizedDescription);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([responseData[@"success"] boolValue]) {
                // 兑换成功，更新本地积分
                self.currentPoints = [responseData[@"data"][@"remaining_points"] integerValue];
                [self updateUI];
                
                // 生成兑换表单图片
                [self generateExchangeFormImage];
            } else {
                // 兑换失败，显示错误信息
                NSString *message = responseData[@"message"];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"兑换失败"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
                [alert addAction:okAction];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
    
    [task resume];
}

// 获取设备UID（去除格式化）
- (NSString *)getDeviceUID {
    NSString *deviceUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if (!deviceUID || deviceUID.length == 0) {
        deviceUID = @"UNKNOWN-DEVICE-IDENTIFIER";
    }
    
    // 移除连字符，只保留字母数字
    deviceUID = [deviceUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return deviceUID;
}

// 更新UI显示
- (void)updateUI {
    self.pointsLabel.text = [NSString stringWithFormat:@"当前积分: %ld", (long)self.currentPoints];
    self.daysLabel.text = [NSString stringWithFormat:@"已签到 %ld 天", (long)self.checkinDays];
}

@end 