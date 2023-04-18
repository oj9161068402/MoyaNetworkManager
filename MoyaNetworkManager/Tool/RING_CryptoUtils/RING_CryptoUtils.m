//
//  CryptoUtils.m
//  OCTest
//
//  Created by wenqiang on 2018/8/7.
//  Copyright © 2018年 wenqiang. All rights reserved.
//

#import "RING_CryptoUtils.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <iconv.h>

@implementation RING_CryptoUtils

//aes-128-cbc  IOS无kay解密方法   偏移量1234567890123456
//aes-128-cbc  IOS无kay解密方法   偏移量1234567890123456
+ (NSString*)RING_decryptUseAES:(NSString *)content
                       key:(NSString *)key{
    // 利用 GTMBase64 解碼 Base64 字串
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:content
                                                             options:0];
    unsigned char buffer[1024 * 128];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeAES128,
                                          //[@"01234567" UTF8String],
                                          NULL,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          1024 * 128,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer
                                      length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    }
    return plainText;
}


//DES加密
+ (NSString *) RING_encryptUseDES:(NSString *)plainText
                         key:(NSString *)key {
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [plainData bytes],
                                          [plainData length],
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    NSString *ciphertext = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer
                                      length:(NSUInteger)numBytesEncrypted];
        ciphertext = [RING_CryptoUtils convertDataToHexStr:data];
        ciphertext = [ciphertext uppercaseString];
    }
    return ciphertext;
}


//DES解密
+ (NSString *)RING_decryptUseDES:(NSString *)cipherText key:(NSString*)key {
    
    NSData* cipherData = [RING_CryptoUtils convertHexStrToData:cipherText];
    
    unsigned char buffer[1024 * 512];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          1024 * 512,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    
    if (cryptStatus == kCCSuccess) {
        
        NSData* data = [NSData dataWithBytes:buffer
                                      length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

//将NSData转成16进制
+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

//将16进制字符串转成NSData
+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length; range.length = 2;
    }
    return hexData;
}

+ (void)files {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray<NSURL *> * urls = [manager URLsForDirectory:NSDocumentationDirectory
                                              inDomains:NSAllDomainsMask];
    NSLog(@"URLs: %@", urls);
}

/// DES 解密
+ (NSDictionary *)decryptString:(id)JSON key:(NSString *)key {
    NSDictionary *dict = @{@"msg": @"\n============   Decrypt Use DES fail   ============\n"};
    
    NSData *base64Data = [[NSData alloc]initWithBase64EncodedData:JSON options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *aseDicString = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    if (base64Data == nil || [aseDicString length] == 0) {
        NSLog(@"=================== 服务器数据未加密 =====================");
        NSDictionary *newDict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingAllowFragments error:nil];

        if (newDict) {
            return newDict;
        } else {
            return dict;
        }
    }
    
    NSString *dataString = [RING_CryptoUtils RING_decryptUseDES:aseDicString key:key];
    NSData *jsonData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (jsonData) {
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    }
    return dict;
}



////含有非编码处理
//static NSData * ALUTF8NSData(NSData *data) {
//    if (!data) return nil;
//    const char *iconv_utf8_encoding = "UTF-8";
//    iconv_t cd = iconv_open(iconv_utf8_encoding, iconv_utf8_encoding); // 从utf8转utf8
//    int one = 1;
//    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // 丢弃不正确的字符
//
//    size_t inbytesleft, outbytesleft;
//    inbytesleft = outbytesleft = data.length;
//    char *inbuf  = (char *)data.bytes;
//    char *outbuf = malloc(sizeof(char) * data.length);
//    char *outptr = outbuf;
//    size_t icon = iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft);
//
//    if (icon == 0) {
//        NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
//        iconv_close(cd);
//        free(outbuf);
//
//        return result;
//    }
//    return nil;
//}

@end

