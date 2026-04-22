

#import <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <objc/message.h>
#import <Foundation/Foundation.h>
#define myStr(key) NSLocalizedString(key, nil)

@interface LSApplicationWorkspace : NSObject
- (NSArray *)allInstalledApplications;
- (bool)openApplicationWithBundleID:(id)arg1;
- (NSArray *)privateURLSchemes;
- (NSArray *)publicURLSchemes;
+ (id)defaultWorkspace;
@end


@interface LSBundleProxy : NSObject

@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) NSString * bundleExecutable;
@property (nonatomic,readonly) NSString * canonicalExecutablePath;
@property (nonatomic,readonly) NSURL * containerURL;
@property (nonatomic,readonly) NSURL * dataContainerURL;
@property (nonatomic,readonly) NSURL * bundleContainerURL;
@property (readonly, nonatomic) NSString *bundleIdentifier;
+ (id)bundleProxyForURL:(id)arg1;
+ (id)bundleProxyForIdentifier:(id)arg1;
@end


@interface LSPlugInKitProxy : LSBundleProxy
@property (nonatomic, readonly) LSBundleProxy *containingBundle;
@property (nonatomic, readonly) NSDictionary *pluginKitDictionary;
-(NSDictionary *)infoPlist;
+ (id)pluginKitProxyForIdentifier:(id)arg1;
@end

@interface LSApplicationProxy: LSBundleProxy
- (NSDictionary *)entitlements;
- (NSDictionary<NSString *, NSURL *> *)groupContainerURLs;
- (NSArray<LSPlugInKitProxy *> *)plugInKitPlugins;
@property (nonatomic,readonly) NSArray * plugInKitPlugins;
@property (nonatomic, readonly) NSString *localizedShortName;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSArray *appTags;

@property (nonatomic, readonly) NSString *applicationDSID;
@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *applicationType;
@property (nonatomic, readonly) NSNumber *dynamicDiskUsage;

@property (nonatomic, readonly) NSArray *groupIdentifiers;
@property (nonatomic, readonly) NSNumber *itemID;
@property (nonatomic, readonly) NSString *itemName;
@property (nonatomic, readonly) NSString *minimumSystemVersion;
@property (nonatomic, readonly) NSArray *requiredDeviceCapabilities;
@property (nonatomic, readonly) NSString *roleIdentifier;
@property (nonatomic, readonly) NSString *sdkVersion;
@property (nonatomic, readonly) NSString *shortVersionString;
@property (nonatomic, readonly) NSString *sourceAppIdentifier;
@property (nonatomic, readonly) NSNumber *staticDiskUsage;
@property (nonatomic, readonly) NSString *teamID;
@property (nonatomic, readonly) NSString *vendorName;
@property (nonatomic, strong) NSString *OrganizationIdentifier;
+(id)applicationProxyForIdentifier:(id)arg1;
+ (NSArray<LSApplicationProxy*>*)readApplications;
- (NSString *)OrganizationIdentifier;
- (NSString *)name;
- (UIImage *)icon;
- (BOOL)isHiddenApp;
@end

