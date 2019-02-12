//
//  ViewController.m
//  WechatLogin
//
//  Created by 张玥 on 2019/1/29.
//  Copyright © 2019 张玥. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "WXApi.h"
#import "LoginUtils.h"
#define WXAppId            @"wxf5a1ec60f90631eb"//填上应用的AppID
#define WXAppSecret            @"d976de848b8b2a6199935331a5da8b89"//填上应用的AppSecret
#define WX_BASE_URL            @"https://api.weixin.qq.com/sns"//填上应用的AppURL
#define WX_REFRESH_TOKEN            @"wx_refresh_token"
#define WX_ACCESS_TOKEN            @"wx_access_token"
#define WX_OPEN_ID             @"wx_open_id"


@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 微信首次或accesstoken过期后登陆
- (IBAction)wechatLoginClick:(id)sender {
    //判断本地是否存在token
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    // 如果已经请求过微信授权登录，那么考虑用已经得到的access_token
    if (accessToken && openID) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_REFRESH_TOKEN];
        NSString *refreshUrlStr = [NSString stringWithFormat:@"%@/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", WX_BASE_URL, WXAppId, refreshToken];
        //刷新access_token有效期
        [manager GET:refreshUrlStr parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] ;
            NSDictionary *refreshDict = [LoginUtils dictionaryWithJsonString:responseString];
            NSLog(@"请求reAccessCode的response = %@", refreshDict);
            NSString *reAccessToken = [refreshDict objectForKey:@"access_token"];
            // 如果reAccessToken为空,说明reAccessToken也过期了,反之则没有过期
            if (reAccessToken) {
                // 更新access_token、refresh_token、open_id
                [[NSUserDefaults standardUserDefaults] setObject:reAccessToken forKey:WX_ACCESS_TOKEN];
                [[NSUserDefaults standardUserDefaults] setObject:[refreshDict objectForKey:@"openid"] forKey:WX_OPEN_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[refreshDict objectForKey:@"refresh_token"] forKey:WX_REFRESH_TOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 当存在reAccessToken不为空时直接执行wechatLoginByRequestForUserInfo方法，获取用户信息
                [LoginUtils wechatLoginByRequestForUserInfo];
            }
            else {
                [self wechatLogin];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
            NSLog(@"用refresh_token来更新accessToken时出错 = %@", error);
        }];
    }
    else {
        [self wechatLogin];
    }
}

#pragma mark - 设置弹出提示语
- (void)setupAlertController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 微信首次或accesstoken过期后登陆
- (void)wechatLogin {
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"GSTDoctorApp";
        [WXApi sendReq:req];
    }
    else {
        [self setupAlertController];
    }
}


@end
