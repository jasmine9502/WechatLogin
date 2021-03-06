//
//  AppDelegate.m
//  WechatLogin
//
//  Created by 张玥 on 2019/1/29.
//  Copyright © 2019 张玥. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import "LoginUtils.h"

#define WXAppId            @"wxf5a1ec60f90631eb"//填上应用的AppID
@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXApi registerApp:WXAppId];
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendAuthResp class]]){//判断是否为授权登录类
        SendAuthResp *req = (SendAuthResp *)resp;
        if([req.state isEqualToString:@"GSTDoctorApp"]){//微信授权成功
            //处理返回code
            [LoginUtils wechatStateChange:req];
        }
    }
}


@end
