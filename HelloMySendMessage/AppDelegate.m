//
//  AppDelegate.m
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/17.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import "AppDelegate.h"
#import "Communicator.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

//整隻APP的最起點
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Ask user's permission
    UIUserNotificationType type=UIUserNotificationTypeAlert |
    UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
    
    UIUserNotificationSettings *settings=
    [UIUserNotificationSettings settingsForTypes:type categories:nil];
    
    [application registerUserNotificationSettings:settings];
    
    // Ask deviceToken from APNS
    //向APNS詢問deviceToken
    
    [application registerForRemoteNotifications];
    
    return YES;
}
//推播相關
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"DeviceToken: %@", deviceToken.description);
    
    
    
    NSString *finalDeviceToken=deviceToken.description;
    
    //finalDeviceToken出來是
    //<6156ce1f 5bae2af2 4b90fbf5 6e28a3d3 a22b78ce 0caa018b be8b728b f4890562>格式
    //用下面方法把< > 空格用@""取代
    
    finalDeviceToken=[finalDeviceToken
                      stringByReplacingOccurrencesOfString:@"<" withString:@""];
    finalDeviceToken=[finalDeviceToken
                      stringByReplacingOccurrencesOfString:@">" withString:@""];
    finalDeviceToken=[finalDeviceToken
                      stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //最後會拿到6156ce1f5bae2af24b90fbf56e28a3d3a22b78ce0caa018bbe8b728bf4890562
    //是我們想要的
    NSLog(@"finalDeviceToken: %@",finalDeviceToken);
    //Update DeviceToken to Server
    Communicator * comm=[Communicator sharedInstance];
    [comm updateDeviceToken:finalDeviceToken
                 completion:^(NSError *error, id result) {
        //
    }];
}
//推播相關
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

//收到推播時會收到通知,在背景或者使用APP時都會
-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    NSLog(@"* didReceiveRemoteNotification: %@",userInfo.description);
    
    //Notify the ViewController to do refresh
    [[NSNotificationCenter defaultCenter]postNotificationName:DID_RECEIVED_REMOTE_NOTIFICATION object:nil];
}

//此方法為推播能用silent Notification方式更新資料
//還需到藍色畫面裡的Capabilites->background 勾選RemoteNotification
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"* didReceiveRemoteNotification: %@",userInfo.description);
    
    //Notify the ViewController to do refresh
    [[NSNotificationCenter defaultCenter]postNotificationName:DID_RECEIVED_REMOTE_NOTIFICATION object:nil];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

//即將進入背景
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
//已經進入背景,接電話 簡訊類不會進入背景
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
//即將進入APP,接電話 簡訊類不會即將進入APP
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
//已經進入APP
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
//APP即將被殺掉(在背景被殺掉不會通知)
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
