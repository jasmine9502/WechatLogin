//
//  LoginUtils.m
//  WechatLogin
//
//  Created by 张玥 on 2019/1/29.
//  Copyright © 2019 张玥. All rights reserved.
//

#import "LoginUtils.h"
#define WXAppId            @"wxf5a1ec60f90631eb"//填上应用的AppID
#define WXAppSecret            @"d976de848b8b2a6199935331a5da8b89"//填上应用的AppSecret
#define WX_BASE_URL            @"https://api.weixin.qq.com/sns"//填上应用的AppURL
#define WX_REFRESH_TOKEN            @"wx_refresh_token"
#define WX_ACCESS_TOKEN            @"wx_access_token"
#define WX_OPEN_ID             @"wx_open_id"
@implementation LoginUtils

#pragma mark - 通过code获取access_token
+(void)wechatStateChange:(SendAuthResp*)response {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *refreshUrlStr = [NSString stringWithFormat:@"%@/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_BASE_URL, WXAppId, WXAppSecret,response.code];
    [manager GET:refreshUrlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] ;
        NSDictionary *accessDict = [self dictionaryWithJsonString:responseString];
        NSLog(@"请求accesstoken的response = %@", accessDict);
        NSString *accessToken = [accessDict objectForKey:@"access_token"];
        NSString *openID = [accessDict objectForKey:@"openid"];
        NSString *refreshToken = [accessDict objectForKey:@"refresh_token"];
        // 本地持久化，以便access_token的使用、刷新或者持续
        if (accessToken && ![accessToken isEqualToString:@""] && openID && ![openID isEqualToString:@""]) {
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:WX_ACCESS_TOKEN];
            [[NSUserDefaults standardUserDefaults] setObject:openID forKey:WX_OPEN_ID];
            [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:WX_REFRESH_TOKEN];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self wechatLoginByRequestForUserInfo];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        NSLog(@"获取access_token时出错 = %@", error);
    }];
}

#pragma mark - 通过access_token和openid获取用户信息
+ (void)wechatLoginByRequestForUserInfo {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    NSString *userUrlStr = [NSString stringWithFormat:@"%@/userinfo?access_token=%@&openid=%@", WX_BASE_URL, accessToken, openID];
    // 请求用户数据
    [manager GET:userUrlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] ;
        NSDictionary *userDic = [self dictionaryWithJsonString:responseString];
        NSLog(@"请求userInfo的response = %@", userDic);
        [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
        //获得用户微信数据，自行存储，跳转登录成功页面
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        NSLog(@"获取用户信息时出错 = %@", error);
    }];
}

#pragma mark - 将string转成dictionary
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
