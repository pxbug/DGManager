

#import <dlfcn.h>
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "LaunchViewController.h"
#import <Foundation/Foundation.h>


static const char kBundleKey = 0;
@implementation BundleEx
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &kBundleKey);
    if (bundle) {
        return [bundle localizedStringForKey:key value:value table:tableName];
    }
    return [super localizedStringForKey:key value:value table:tableName];
}
@end

@implementation NSBundle (Language)

+ (void)setLanguage:(NSString *)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [BundleEx class]);
    });
    
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    NSBundle *languageBundle = [NSBundle bundleWithPath:path];
    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, languageBundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDictionary = [defaults dictionaryRepresentation];
    if([infoDictionary.allKeys containsObject:@"setLanguages"]){
        NSInteger Languages = [defaults integerForKey:@"setLanguages"];
        if (Languages == 1) {
            [NSBundle setLanguage:@"zh-Hans"];
        }else if (Languages == 2){
            [NSBundle setLanguage:@"en"];
        }
    }
    [self refreshUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLanguageChangedNotification:) name:@"LanguageChangedNotification" object:nil];
    return YES;
}
- (void)didReceiveLanguageChangedNotification:(NSNotification*)notification {
    NSLog(@"返回 %@",notification);
    [NSBundle setLanguage:notification.object];
    [self refreshUI];
}
- (void)refreshUI {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 检查是否是首次启动（显示启动页）
    static BOOL hasShownLaunchScreen = NO;
    if (!hasShownLaunchScreen) {
        hasShownLaunchScreen = YES;
        LaunchViewController *launchViewController = [[LaunchViewController alloc] init];
        [self.window setRootViewController:launchViewController];
    } else {
        // 非首次启动，直接显示主界面
        self.viewController = [[ViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
        [self.window setRootViewController:navigationController];
    }
    
    [self.window makeKeyAndVisible];
}
@end
