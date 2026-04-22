#import "ViewController.h"
#import "Operationcontroller.h"
#import "LaoWang.h"
#import "HelloViews.h"

OBJC_EXTERN void CleanKeychains(NSString* where);

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) NSArray *menu;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSArray *allApplications;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSDictionary *groupedApps;
@property (nonatomic, strong) NSArray *sectionTitles;

@end

@implementation ViewController
bool zhuangtai = YES; // 初始化为 YES，确保默认可以交互

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 显示欢迎页面
    HelloViews *helloVC = [[HelloViews alloc] init];
    helloVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:helloVC animated:NO completion:^{
        [self setupMainView]; // 预先设置主视图，但不显示
    }];
}

- (void)setupMainView {
    self.title = myStr(@"APP列表");
    zhuangtai = YES; // 确保进入主界面时可以交互
    self.view.userInteractionEnabled = YES;
    
    // 设置主视图背景为白色
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 优化tableView的性能设置
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 70; // 固定行高以提高性能
    self.tableView.estimatedRowHeight = 70;
    self.tableView.sectionHeaderHeight = 30;
    self.tableView.estimatedSectionHeaderHeight = 30;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = myStr(@"搜索、输入名称或标识");
    self.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    UIBarButtonItem *donate = [[UIBarButtonItem alloc] initWithTitle:myStr(@"设置") style:UIBarButtonItemStyleDone target:self action:@selector(设置)];
    self.navigationItem.rightBarButtonItem = donate;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    if (@available(iOS 10.0, *)) {
        self.tableView.refreshControl = refreshControl;
    } else {
        [self.tableView addSubview:refreshControl];
    }
    [self refreshData];
}

- (void)executeBlock:(NSTimer *)timer {
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}

- (void)设置 {
    Operationcontroller *operationVC = [[Operationcontroller alloc] init];
    [self.navigationController pushViewController:operationVC animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";             // 清空搜索框内容
    [self searchBarSearch:searchBar.text]; // 恢复原始数据
    self.searchController.searchBar.showsCancelButton = NO;  // 添加此行
    [searchBar resignFirstResponder]; // 收起键盘，移除光标
    self.menu = self.allApplications;
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    UIButton *cancelButton = [searchBar valueForKey:@"cancelButton"];
    [cancelButton setTitle:myStr(@"取消") forState:UIControlStateNormal];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchBarSearch:searchText];
}

- (void)searchBarSearch:(NSString *)searchText {
    NSArray *sourceArray = self.allApplications;
    if (searchText.length) {
        NSMutableArray *filteredApps = [NSMutableArray array];
        for (LSApplicationProxy *app in sourceArray) {
            NSRange range = [app.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange range1 = [app.bundleIdentifier rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound || range1.location != NSNotFound) {
                [filteredApps addObject:app];
            }
        }
        sourceArray = filteredApps;
    }
    
    NSMutableDictionary *groupedDict = [NSMutableDictionary dictionary];
    for (LSApplicationProxy *app in sourceArray) {
        if (app.name.length > 0) {
            NSMutableString *mutableName = [app.name mutableCopy];
            CFStringTransform((__bridge CFMutableStringRef)mutableName, NULL, kCFStringTransformToLatin, NO);
            CFStringTransform((__bridge CFMutableStringRef)mutableName, NULL, kCFStringTransformStripDiacritics, NO);
            NSString *firstLetter = [[mutableName substringToIndex:1] uppercaseString];
            NSMutableArray *group = groupedDict[firstLetter];
            if (!group) {
                group = [NSMutableArray array];
                groupedDict[firstLetter] = group;
            }
            [group addObject:app];
        }
    }
    self.groupedApps = groupedDict;
    self.sectionTitles = [[groupedDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *letter = self.sectionTitles[section];
    NSArray *appsForLetter = self.groupedApps[letter];
    return appsForLetter.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
   return self.sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
   return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    NSString *letter = self.sectionTitles[indexPath.section];
    NSArray *appsForLetter = self.groupedApps[letter];
    LSApplicationProxy *app = appsForLetter[indexPath.row];
    
    cell.textLabel.text = app.name;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.detailTextLabel.text = app.bundleIdentifier;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    UIImage *image = app.icon;
    CGSize imageSize = CGSizeMake(48, 48);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = scaledImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *letter = self.sectionTitles[indexPath.section];
    NSArray *appsForLetter = self.groupedApps[letter];
    LSApplicationProxy *app = appsForLetter[indexPath.row];
    NSString *uuid = [LaoWang getUUIDForBundleIdentifier:app.bundleIdentifier];
    
    UIAlertController *uuidAlert = [UIAlertController alertControllerWithTitle:myStr(@"当前标识符") message:uuid preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        uuidAlert.popoverPresentationController.sourceView = selectedCell;
        uuidAlert.popoverPresentationController.sourceRect = selectedCell.bounds;
    }
    
    void (^presentCompletionAlert)(void) = ^{
        UIAlertController *okAlert = [UIAlertController alertControllerWithTitle:myStr(@"完成") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:okAlert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [okAlert dismissViewControllerAnimated:NO completion:nil];
            });
        }];
    };
    
    [uuidAlert addAction:[UIAlertAction actionWithTitle:myStr(@"变更新的标识符") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LaoWang resetUUID:nil forBundleIdentifier:app.bundleIdentifier];
        [uuidAlert dismissViewControllerAnimated:NO completion:presentCompletionAlert];
    }]];
    
    [uuidAlert addAction:[UIAlertAction actionWithTitle:myStr(@"清理KeyChain残留") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CleanKeychains(app.bundleIdentifier);
        [uuidAlert dismissViewControllerAnimated:NO completion:presentCompletionAlert];
    }]];
    
    [uuidAlert addAction:[UIAlertAction actionWithTitle:myStr(@"清理数据目录") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LaoWang CleanAppDataFile:app.bundleIdentifier];
        [uuidAlert dismissViewControllerAnimated:NO completion:presentCompletionAlert];
    }]];
    
    [uuidAlert addAction:[UIAlertAction actionWithTitle:myStr(@"开启定位权限") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LaoWang SetLocationPermissions:app.bundleIdentifier auth:3];
    }]];
    
    [uuidAlert addAction:[UIAlertAction actionWithTitle:myStr(@"修复联网权限") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LaoWang SetNetworkPermissions:app.bundleIdentifier auth:2];
    }]];
    
    [uuidAlert addAction:[UIAlertAction actionWithTitle:myStr(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:uuidAlert animated:YES completion:nil];
}

- (void)refreshData {
    // 在后台线程处理数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.allApplications = [LSApplicationProxy readApplications];
    NSMutableDictionary *groupedDict = [NSMutableDictionary dictionary];
        
    for (LSApplicationProxy *app in self.allApplications) {
        if (app.name.length > 0) {
                @autoreleasepool {  // 使用自动释放池优化内存使用
            NSMutableString *mutableName = [app.name mutableCopy];
            CFStringTransform((__bridge CFMutableStringRef)mutableName, NULL, kCFStringTransformToLatin, NO);
            CFStringTransform((__bridge CFMutableStringRef)mutableName, NULL, kCFStringTransformStripDiacritics, NO);
            NSString *firstLetter = [[mutableName substringToIndex:1] uppercaseString];
                    
                    @synchronized (groupedDict) {  // 线程安全处理
            NSMutableArray *group = groupedDict[firstLetter];
            if (!group) {
                group = [NSMutableArray array];
                groupedDict[firstLetter] = group;
            }
            [group addObject:app];
        }
    }
            }
        }
        
        // 在主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
    self.groupedApps = groupedDict;
    self.sectionTitles = [[groupedDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
    [self.tableView.refreshControl endRefreshing];
            
            // 确保界面可以交互
            zhuangtai = YES;
            self.view.userInteractionEnabled = YES;
        });
    });
}

@end
