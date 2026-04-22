// CloZhi AES 加密
// 2025-09-06
// 1.0.0
// 1.0.0
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface EncryptionManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)encryptData:(NSString *)data;

- (NSString *)decryptData:(NSString *)encryptedData;

- (NSString *)generateSignature:(NSString *)data timestamp:(NSTimeInterval)timestamp;

- (BOOL)verifySignature:(NSString *)signature data:(NSString *)data timestamp:(NSTimeInterval)timestamp;

- (NSTimeInterval)getCurrentTimestamp;

@end

NS_ASSUME_NONNULL_END 