

#import "LaoWang.h"
#import "Operationcontroller.h"
#import <Foundation/Foundation.h>



OBJC_EXTERN void SetPaste(NSString* where,int);
OBJC_EXTERN void SetPermissions(NSString* where,int);
@interface Operationcontroller ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) NSArray *menu;
@property (nonatomic, strong) UITextView*textView;
@property (nonatomic, strong) NSMutableArray *Array;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isGameModeEnabled;
@end

@implementation Operationcontroller
static void sub_31548(const char * a1){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:a1]] preferredStyle:UIAlertControllerStyleAlert];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = myStr(@"设置");
//    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 300.0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.hidesBackButton = YES; // 隐藏默认返回按钮
    
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc]initWithImage:[UIImage systemImageNamed:@"arrowshape.turn.up.left"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = customBackButton;
    
    NSMutableArray *auxiliaryOptions = [NSMutableArray arrayWithArray:@[@"切换App Store账号", @"所有app允许粘贴", @"切换语言"]];
       NSMutableArray *auxiliaryDescriptions = [NSMutableArray arrayWithArray:@[@"快捷切换App Store登录过的账号", @"一键设置所有app允许粘贴", @"设置语言"]];
       self.menu = @[@{@"mainOptions": auxiliaryOptions, @"descriptions": auxiliaryDescriptions}];
       self.isGameModeEnabled = NO; // 默认游戏模式为关闭
}
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置UITableView的分区数
    return self.menu.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 返回每个分组中的行数
    NSDictionary *sectionData = self.menu[section];
    NSArray *mainOptions = sectionData[@"mainOptions"];
    return mainOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    NSDictionary *sectionData = self.menu[indexPath.section];
    NSArray *mainOptions = sectionData[@"mainOptions"];
    NSArray *descriptions = sectionData[@"descriptions"];
    
    cell.textLabel.text = myStr(mainOptions[indexPath.row]);
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.detailTextLabel.text = myStr(descriptions[indexPath.row]);
    cell.detailTextLabel.numberOfLines = 0; // 设置为多行显示
    cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    if(indexPath.row == 0){
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"repeat"]];
    }else if(indexPath.row == 1){
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"tornado.circle"]];
    } else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"gear"]];
    }
    if (indexPath.row == 3) {
           UISwitch *gameModeSwitch = [[UISwitch alloc] init];
           gameModeSwitch.on = self.isGameModeEnabled; // 根据状态设置开关
           [gameModeSwitch addTarget:self action:@selector(gameModeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
           cell.accessoryView = gameModeSwitch;
       } else {
           cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"gear"]];
       }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            [LaoWang SwitchStoreAccount];
        }else if(indexPath.row == 1){
            UIAlertController*alertController = [UIAlertController
                        alertControllerWithTitle:myStr(@"执行中，请稍候！") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5,5,50,50)];
            activityIndicator.hidesWhenStopped = YES;
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
            [activityIndicator startAnimating];
            [alertController.view addSubview:activityIndicator];
            [self presentViewController:alertController animated:YES completion:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *apps = [LSApplicationProxy readApplications];
                for (LSApplicationProxy *app in apps) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        alertController.message = app.name;
                    });
                    if(!app.isHiddenApp){
                        SetPaste(app.bundleIdentifier,2);
                    }
                }
                // 回到主线程执行 block
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityIndicator stopAnimating];
                    [activityIndicator removeFromSuperview];
                    alertController.title = myStr(@"操作完毕");
                    alertController.message = nil;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alertController dismissViewControllerAnimated:NO completion:nil];
                    });
                });
            });
        }else if(indexPath.row == 2){
            setLanguagesController*mp = [[setLanguagesController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mp];
            navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:navController animated:YES completion:nil];
        }
        
        
    }
}




@end

@implementation setLanguagesController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        [self setModalInPresentation:YES];
    }
    self.title = myStr(@"设置语言");
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.searchResults = @[myStr(@"跟随系统"),myStr(@"中文"), myStr(@"English")];
    [self.tableView reloadData];
    UIBarButtonItem *donate = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark.circle"]
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(colose)];
    self.navigationItem.rightBarButtonItem = donate;
}
- (void)colose {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = self.searchResults[indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger Languages = [defaults integerForKey:@"setLanguages"];
    if (Languages == indexPath.row){
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle"]];
    }
   

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:indexPath.row forKey:@"setLanguages"];
    [defaults synchronize];
    if(indexPath.row == 0){
        NSString *language = [[NSLocale preferredLanguages] firstObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LanguageChangedNotification" object:language userInfo:nil];
    }
    if(indexPath.row == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LanguageChangedNotification" object:@"zh-Hans" userInfo:nil];
    }
    if(indexPath.row == 2){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LanguageChangedNotification" object:@"en" userInfo:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

@end
