#import "EncryptionManager.h"

// 与服务器端相同的密钥
static NSString *const kEncryptionKey = @"DGManager2024SecretKey!@#$%^&*()";

@implementation EncryptionManager

+ (instancetype)sharedManager {
    static EncryptionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EncryptionManager alloc] init];
    });
    return manager;
}

- (NSString *)encryptData:(NSString *)data {
    NSData *dataToEncrypt = [data dataUsingEncoding:NSUTF8StringEncoding];
    if (!dataToEncrypt) return nil;
    
    // 生成密钥
    NSData *keyData = [self keyFromString:kEncryptionKey];
    if (!keyData) return nil;
    
    // 生成随机IV
    NSMutableData *iv = [NSMutableData dataWithLength:kCCBlockSizeAES128];
    if (SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, iv.mutableBytes) != errSecSuccess) {
        return nil;
    }
    
    // 加密
    NSMutableData *encryptedData = [NSMutableData dataWithLength:dataToEncrypt.length + kCCBlockSizeAES128];
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt,
                                   kCCAlgorithmAES,
                                   kCCOptionPKCS7Padding,
                                   keyData.bytes,
                                   keyData.length,
                                   iv.bytes,
                                   dataToEncrypt.bytes,
                                   dataToEncrypt.length,
                                   encryptedData.mutableBytes,
                                   encryptedData.length,
                                   &numBytesEncrypted);
    
    if (result != kCCSuccess) return nil;
    
    encryptedData.length = numBytesEncrypted;
    
    // 将IV和加密数据合并
    NSMutableData *finalData = [NSMutableData dataWithData:iv];
    [finalData appendData:encryptedData];
    
    return [finalData base64EncodedStringWithOptions:0];
}

- (NSString *)decryptData:(NSString *)encryptedData {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:encryptedData options:0];
    if (!data || data.length < kCCBlockSizeAES128) return nil;
    
    // 生成密钥
    NSData *keyData = [self keyFromString:kEncryptionKey];
    if (!keyData) return nil;
    
    // 提取IV
    NSData *iv = [data subdataWithRange:NSMakeRange(0, kCCBlockSizeAES128)];
    NSData *encryptedPayload = [data subdataWithRange:NSMakeRange(kCCBlockSizeAES128, data.length - kCCBlockSizeAES128)];
    
    // 解密
    NSMutableData *decryptedData = [NSMutableData dataWithLength:encryptedPayload.length];
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                   kCCAlgorithmAES,
                                   kCCOptionPKCS7Padding,
                                   keyData.bytes,
                                   keyData.length,
                                   iv.bytes,
                                   encryptedPayload.bytes,
                                   encryptedPayload.length,
                                   decryptedData.mutableBytes,
                                   decryptedData.length,
                                   &numBytesDecrypted);
    
    if (result != kCCSuccess) return nil;
    
    decryptedData.length = numBytesDecrypted;
    
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

- (NSString *)generateSignature:(NSString *)data timestamp:(NSTimeInterval)timestamp {
    NSString *message = [NSString stringWithFormat:@"%@%.0f", data, timestamp];
    return [self hmacSHA256:message key:kEncryptionKey];
}

- (BOOL)verifySignature:(NSString *)signature data:(NSString *)data timestamp:(NSTimeInterval)timestamp {
    // 检查时间戳（5分钟有效期）
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    if (ABS(currentTime - timestamp) > 300) {
        return NO;
    }
    
    NSString *expectedSignature = [self generateSignature:data timestamp:timestamp];
    return [signature isEqualToString:expectedSignature];
}

- (NSTimeInterval)getCurrentTimestamp {
    return [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Private Methods

- (NSData *)keyFromString:(NSString *)keyString {
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, hash.mutableBytes);
    
    return hash;
}

- (NSString *)hmacSHA256:(NSString *)data key:(NSString *)key {
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *messageData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, keyData.bytes, keyData.length, messageData.bytes, messageData.length, hash.mutableBytes);
    
    return [hash base64EncodedStringWithOptions:0];
}

@end 