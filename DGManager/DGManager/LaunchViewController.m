#import "LaunchViewController.h"
#import "ViewController.h"

@interface LaunchViewController ()
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景颜色与主应用保持一致
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.15 alpha:1.0];
    
    // 添加渐变背景
    [self setupGradientBackground];
    [self setupLaunchUI];
    [self startLaunchAnimation];
}

- (void)setupGradientBackground {
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.view.bounds;
    self.gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.06 green:0.06 blue:0.15 alpha:1.0].CGColor,  // 深蓝色
        (id)[UIColor colorWithRed:0.08 green:0.08 blue:0.20 alpha:1.0].CGColor,  // 中间色
        (id)[UIColor colorWithRed:0.04 green:0.04 blue:0.12 alpha:1.0].CGColor   // 更深的蓝色
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (void)setupLaunchUI {
    // 创建容器视图来同时实现圆形效果和阴影效果
    UIView *logoContainer = [[UIView alloc] init];
    logoContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设置容器的阴影效果
    logoContainer.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.6].CGColor;
    logoContainer.layer.shadowOffset = CGSizeMake(0, 0);
    logoContainer.layer.shadowOpacity = 0.8;
    logoContainer.layer.shadowRadius = 20;
    logoContainer.layer.masksToBounds = NO; // 允许阴影显示
    
    // 创建圆形logo图像视图
    self.logoImageView = [[UIImageView alloc] init];
    self.logoImageView.image = [UIImage imageNamed:@"aigo"];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.logoImageView.layer.cornerRadius = 80; // 半径为80，直径为160
    self.logoImageView.layer.masksToBounds = YES; // 确保圆形裁剪效果
    self.logoImageView.layer.borderWidth = 4;
    self.logoImageView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0].CGColor;
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [logoContainer addSubview:self.logoImageView];
    [self.view addSubview:logoContainer];
    
    // 创建应用名称标签
    self.appNameLabel = [[UILabel alloc] init];
    self.appNameLabel.text = @"DG Manager";
    self.appNameLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightBold];
    self.appNameLabel.textColor = [UIColor whiteColor];
    self.appNameLabel.textAlignment = NSTextAlignmentCenter;
    self.appNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 添加文字阴影
    self.appNameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.appNameLabel.layer.shadowOffset = CGSizeMake(0, 2);
    self.appNameLabel.layer.shadowOpacity = 0.5;
    self.appNameLabel.layer.shadowRadius = 4;
    
    [self.view addSubview:self.appNameLabel];
    
    // 创建副标题标签
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.text = @"专业的iOS管理工具";
    self.subTitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.subTitleLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.subTitleLabel];
    
    // 创建版本号标签
    self.versionLabel = [[UILabel alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (!version) version = @"1.0.0";
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@", version];
    self.versionLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    self.versionLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.versionLabel];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // Logo容器约束 - 居中偏上
        [logoContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [logoContainer.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-60],
        [logoContainer.widthAnchor constraintEqualToConstant:160],
        [logoContainer.heightAnchor constraintEqualToConstant:160],
        
        // Logo图像在容器中的约束 - 填满容器
        [self.logoImageView.centerXAnchor constraintEqualToAnchor:logoContainer.centerXAnchor],
        [self.logoImageView.centerYAnchor constraintEqualToAnchor:logoContainer.centerYAnchor],
        [self.logoImageView.widthAnchor constraintEqualToConstant:160],
        [self.logoImageView.heightAnchor constraintEqualToConstant:160],
        
        // 应用名称约束
        [self.appNameLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.appNameLabel.topAnchor constraintEqualToAnchor:logoContainer.bottomAnchor constant:30],
        [self.appNameLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.appNameLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        
        // 副标题约束
        [self.subTitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.subTitleLabel.topAnchor constraintEqualToAnchor:self.appNameLabel.bottomAnchor constant:15],
        [self.subTitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.subTitleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        
        // 版本号约束 - 放在底部
        [self.versionLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.versionLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-30],
        [self.versionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.versionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40]
    ]];
}

- (void)startLaunchAnimation {
    // 初始状态：所有元素透明度为0，logo稍微缩小
    self.logoImageView.alpha = 0.0;
    self.appNameLabel.alpha = 0.0;
    self.subTitleLabel.alpha = 0.0;
    self.versionLabel.alpha = 0.0;
    self.logoImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    // 添加脉冲动画到logo的阴影
    [self addPulseAnimationToLogo];
    
    // 第一阶段动画：logo淡入并放大到正常大小
    [UIView animateWithDuration:0.8 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.logoImageView.alpha = 1.0;
        self.logoImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        // 第二阶段动画：应用名称淡入
        [UIView animateWithDuration:0.6 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.appNameLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            // 第三阶段动画：副标题和版本号同时淡入
            [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.subTitleLabel.alpha = 1.0;
                self.versionLabel.alpha = 1.0;
            } completion:^(BOOL finished) {
                // 等待一段时间后跳转到主界面
                [self performSelector:@selector(dismissLaunchScreen) withObject:nil afterDelay:1.2];
            }];
        }];
    }];
}

- (void)addPulseAnimationToLogo {
    // 创建脉冲动画
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    pulseAnimation.fromValue = @15;
    pulseAnimation.toValue = @25;
    pulseAnimation.duration = 1.0;
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = HUGE_VALF;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.logoImageView.layer addAnimation:pulseAnimation forKey:@"shadowPulse"];
}

- (void)dismissLaunchScreen {
    // 淡出动画
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        // 跳转到主界面
        [self transitionToMainViewController];
    }];
}

- (void)transitionToMainViewController {
    // 获取应用的主窗口
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    // 创建主视图控制器
    ViewController *mainViewController = [[ViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    // 设置导航栏样式
    navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.15 alpha:1.0];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // 切换根视图控制器
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 确保渐变层的frame与视图bounds一致
    self.gradientLayer.frame = self.view.bounds;
}

- (BOOL)prefersStatusBarHidden {
    return YES; // 启动页隐藏状态栏
}

@end 