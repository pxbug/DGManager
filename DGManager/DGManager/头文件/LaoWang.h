

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PermissionType) {
    kTypeNone = -1, 
    kPasteboard, // 粘贴
    kPhotos,     // 相册
    kCamera,     // 相机
    kMicrophone, // 麦克风
    kAddressBook,// 通讯录
    kUserTracking// 跟踪
};

@interface ProcessInfo : NSObject
@property (nonatomic, assign) pid_t PID;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *name;
@end


@interface LaoWang : NSObject
+ (void)printClassInfo:(Class)Class;
+ (void)AlertPrompt:(NSString *)message hidetiming:(int)time;
+ (NSString *)getUUIDForBundleIdentifier:(NSString *)bundleIdentifier;
+ (void)resetUUID:(NSString *)uuid forBundleIdentifier:(NSString *)bundleIdentifier;
+ (void)SwitchStoreAccount;
+ (void)CleanKeychains:(NSString *)whereClause;
+ (void)CleanAppDataFile:(NSString *)bundleIdentifier;
+ (ProcessInfo*)GetProcessInfo:(NSString*)bundleIdentifier;
+ (void)SetPermissions:(PermissionType)type bundleId:(NSString*)bundleIdentifier auth:(int)auth_value;

//设置联网权限 auth_value==0 无权限 1 有WIFI权限 2 有WIFI和蜂窝权限
+ (void)SetNetworkPermissions:(NSString*)bundleIdentifier auth:(int)auth_value;
//设置位置权限 auth_value==0 永不 1 询问 2 使用应用程序运行时 3 总是
+ (void)SetLocationPermissions:(NSString*)bundleIdentifier auth:(int)auth_value;

+ (NSURL*)AppDataURL:(NSString *)bundleIdentifier;
+ (NSURL*)AppBundleURL:(NSString *)bundleIdentifier;

@end
