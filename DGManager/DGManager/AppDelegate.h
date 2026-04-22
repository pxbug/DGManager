

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface BundleEx : NSBundle
@end
@interface NSBundle (Language)
+ (void)setLanguage:(NSString *)language;
@end
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UIWindow *window;
@end

