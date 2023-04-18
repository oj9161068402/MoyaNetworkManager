//
//  CryptoUtils.h
//  OCTest
//
//  Created by wenqiang on 2018/8/7.
//  Copyright © 2018年 wenqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RING_CryptoUtils : NSObject

//AES解密
+ (NSString*)RING_decryptUseAES:(NSString *)content
                       key:(NSString *)key;

//DES加密
+ (NSString *) RING_encryptUseDES:(NSString *)plainText
                         key:(NSString *)key;


//DES解密
+ (NSString *) RING_decryptUseDES:(NSString*)cipherText
                         key:(NSString*)key;


//+ (NSDictionary *)decryptString:(id)JSON;

+ (NSDictionary *)decryptString:(id)JSON key:(NSString *)key;


@end

