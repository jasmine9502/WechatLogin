//
//  LoginUtils.h
//  WechatLogin
//
//  Created by 张玥 on 2019/1/29.
//  Copyright © 2019 张玥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "WXApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginUtils : NSObject
+(void)wechatStateChange:(SendAuthResp*)response;
+ (void)wechatLoginByRequestForUserInfo;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
