

#import "LaoWang.h"
#import "AppDelegate.h"
#import "LSApplicationProxy.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        if(argc <= 1 || !argv[1]){
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        NSString *type = [NSString stringWithUTF8String:argv[1]];
        NSString *where = [NSString stringWithUTF8String:argv[2]];
        NSString *auth = [NSString stringWithUTF8String:argv[3]];
        if ([type isEqual:@"-CleanKeychains"])
        {
            NSLog(@"CleanKeychains %@  %@  %@" ,type,where,auth);
            LSApplicationProxy* proxy = [LSApplicationProxy applicationProxyForIdentifier:where];
            [LaoWang CleanKeychains:where];
            [LaoWang CleanKeychains:proxy.teamID];
            [LaoWang CleanKeychains:[LaoWang getUUIDForBundleIdentifier:where]];
            return EXIT_SUCCESS;
        } else if ([type isEqual:@"-SetPaste"])
        {
            NSLog(@"SetPaste %@  %@  %@" ,type,where,auth);
            [LaoWang SetPermissions:kPasteboard bundleId:where auth:auth.intValue];
            return EXIT_SUCCESS;
        }
    }
}
