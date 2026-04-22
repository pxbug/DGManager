

#import <Foundation/Foundation.h>
#include "LSApplicationProxy.h"
@interface UIImage (PrivateIcon)
+ (id)_applicationIconImageForBundleIdentifier:(NSString *)identifier format:(int)format scale:(double)scale;
@end


@implementation LSApplicationProxy (Private)
+ (NSArray<LSApplicationProxy*>*)readApplications{
    LSApplicationWorkspace * workspace = [LSApplicationWorkspace defaultWorkspace];
    NSMutableArray<LSApplicationProxy *> *applications = [NSMutableArray array];
    NSArray *allInstalledApplications = [workspace allInstalledApplications];
    
    for (LSApplicationProxy *app  in allInstalledApplications) {
        if (!app) continue;
        if (!app.isHiddenApp && [app.containerURL.path containsString:@"/var/mobile"]) {
            [applications addObject:app];
        }
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)];
    return [applications sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (BOOL)isHiddenApp {
    return [self.appTags containsObject:@"hidden"];
}

- (UIImage *)icon {
    return  [UIImage _applicationIconImageForBundleIdentifier:self.bundleIdentifier format:10 scale:[UIScreen mainScreen].scale];
}


- (NSString *)OrganizationIdentifier {
    NSArray *components = [self.bundleIdentifier componentsSeparatedByString:@"."];
    return (components.count > 1) ? [[components subarrayWithRange:NSMakeRange(0, components.count - 1)] componentsJoinedByString:@"."] : self.bundleIdentifier;
}
- (NSString *)name {
    NSString *name = self.localizedName ?: self.localizedShortName;
    if (!name) return nil;
    
    NSString *currentLanguage = [[[NSLocale preferredLanguages] firstObject] componentsSeparatedByString:@"-"].firstObject;
    if ([currentLanguage hasPrefix:@"zh"] && ![self containsChinese:name]) {
        NSString *displayName = [self getAppDisplayNameFromBundlePath:self.bundleURL.path];
        if (displayName.length > 0) return displayName;
        
        NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:[self.bundleURL.path stringByAppendingPathComponent:@"Info.plist"]];
        NSString *plistDisplayName = infoDict[@"CFBundleDisplayName"];
        if ([self containsChinese:plistDisplayName]) return plistDisplayName;
    }
    return name;
}

- (BOOL)containsChinese:(NSString *)string {
    if (string.length == 0) return NO;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\u4e00-\\u9fa5]"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    return regex ? [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)] > 0 : NO;
}

- (NSString *)getAppDisplayNameFromBundlePath:(NSString *)bundlePath {
    if (bundlePath.length == 0) return nil;
    
    NSString *languageCode = [[[NSLocale preferredLanguages] firstObject] componentsSeparatedByString:@"-"].firstObject;
    NSString *lprojPath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj", languageCode]];
    NSString *infoPlistPath = [lprojPath stringByAppendingPathComponent:@"InfoPlist.strings"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:infoPlistPath]) {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
        return plistDict[@"CFBundleDisplayName"] ?: nil;
    }
    return nil;
}
@end
