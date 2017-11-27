//
//  XtwSdk.h
//  XtwSdk
//
//  Created by you on 31/10/2017.
//  Copyright © 2017 yougaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for XtwSdk.
FOUNDATION_EXPORT double XtwSdkVersionNumber;

//! Project version string for XtwSdk.
FOUNDATION_EXPORT const unsigned char XtwSdkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <XtwSdk/PublicHeader.h>
typedef enum XtwSdkAppType {
    XtwSdkAppType_Normal,
    XtwSdkAppType_H5,
} XtwSdkAppType;

typedef enum XtwSdkInitCode {
    XtwSdkInitCode_Success,
    XtwSdkInitCode_Fail,
} XtwSdkInitCode;

typedef enum XtwSdkLoginCode {
    XtwSdkLoginCode_Success,
    XtwSdkLoginCode_Cancel,
    XtwSdkLoginCode_Fail,
} XtwSdkLoginCode;

typedef enum XtwSdkPayCode {
    XtwSdkPayCode_Success,
    XtwSdkPayCode_Cancel,
    XtwSdkPayCode_Fail,
} XtwSdkPayCode;

// 接收初始化回调
typedef void(^InitListener)(XtwSdkInitCode code, NSString* ret);

// 接收登录回调
typedef void(^LoginListener)(XtwSdkLoginCode code, NSString* uid, NSString* token);

// 接收支付回调
typedef void(^PayListener)(XtwSdkPayCode code, NSString* ret);

@interface XtwSdk : NSObject

@property(strong, nonatomic) NSString* appId;
@property(strong, nonatomic) NSString* appKey;
@property(strong, nonatomic) NSString* h5Url;
@property(strong, nonatomic) NSString* uid;
@property(strong, nonatomic) NSString* token;

@property(assign, nonatomic) XtwSdkAppType appType;

+ (instancetype)getInstance;

- (void)xtwAppInit:(NSString*)appId appKey:(NSString*)appKey listener:(InitListener)listener;
- (void)xtwH5Init:(NSString*)h5Url listener:(InitListener)listener;

- (void)xtwInit:(NSString*)appId
         appKey:(NSString*)appKey
        appType:(XtwSdkAppType)appType
          h5Url:(NSString*)h5Url
       listener:(InitListener)listener;

- (void)login:(LoginListener)listener;
- (void)pay:(NSString*)money itemid:(NSString*)itemid itemnum:(NSString*)itemnum
   itemname:(NSString*)itemname extra:(NSString*)extra notifyurl:(NSString*)notifyurl listener:(PayListener) listener;

- (void)setLoginResult:(XtwSdkLoginCode)loginCode ret:(NSString*)ret;
- (void)setPayResult:(XtwSdkPayCode)payCode ret:(NSString*)ret;

@end
