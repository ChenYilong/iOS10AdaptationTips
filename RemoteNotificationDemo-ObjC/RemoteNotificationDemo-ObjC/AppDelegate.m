//
//  AppDelegate.m
//  CYLLocalNotificationDemo
//
//  Created by Elon Chan 陈宜龙 ( https://github.com/ChenYilong ) on  6/15/16.
//  Copyright © 2016 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong ). All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

/// Notification become independent from UIKit
@import UserNotifications;

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property (nonatomic, strong) UINavigationController *navigationController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    [self registerForRemoteNotification];
    if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0) {
//    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        NSDictionary *remoteNotification = [self getRemoteNotificationFromLaunchOptions:launchOptions];
        if (remoteNotification) {
            //TODO:处理远程推送内容
            NSLog(@"%@", remoteNotification);
        }
    }
    
    if ([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(51) / 255.f green:(171) / 255.f blue:(160) / 255.f alpha:1.f]];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *vc = [[ViewController alloc] init];
    vc.title = @"LocalNatification-Demo";
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window addSubview:vc.view];
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

/**
 *  avoid other behaviours such as Launching by URL Scheme
 */
- (NSDictionary *)getRemoteNotificationFromLaunchOptions:(NSDictionary *const)launchOptions {
    NSDictionary *notification;
    @try {
        notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    } @catch (NSException *exception) {}
    return notification;
}

- (void)addLabel:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor redColor];
    label.text = title;
    [label sizeToFit];
    label.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, 114);
    [self.window.rootViewController.view addSubview:label];
}

- (void)addLabel:(NSString *)title backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = backgroundColor;
    label.text = title;
    label.font= [UIFont boldSystemFontOfSize:15];
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    label.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, arc4random_uniform([UIScreen mainScreen].bounds.size.height));
    [self.window.rootViewController.view addSubview:label];
}

#pragma mark - 注册APNs成功并上报DeviceToken
///=============================================================================
/// @name 注册APNs成功并上报DeviceToken
///=============================================================================

/**
 * also used in iOS10
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //[AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
}

#pragma mark - 实现注册APNs失败接口（可选）
///=============================================================================
/// @name 实现注册APNs失败接口（可选）
///=============================================================================

/**
 * also used in iOS10
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%s\n[无法注册远程提醒, 错误信息]\nline:%@\n-----\n%@\n\n", __func__, @(__LINE__), error);
}

#pragma mark UNUserNotificationCenterDelegate

#pragma mark - 添加处理 APNs 通知回调方法
///=============================================================================
/// @name 添加处理APNs通知回调方法
///=============================================================================

#pragma mark -
#pragma mark - UNUserNotificationCenterDelegate Method

/**
 * Required for iOS 10+
 * 在前台收到推送内容, 执行的方法
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //TODO:处理远程推送内容
        NSLog(@"%@", userInfo);
    }
    // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
    completionHandler(UNNotificationPresentationOptionAlert);
}

/**
 * Required for iOS 10+
 * 在后台和启动之前收到推送内容, 执行的方法
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //TODO:处理远程推送内容
        NSLog(@"%@", userInfo);
    }
    // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
    completionHandler(UNNotificationPresentationOptionBadge + UNNotificationPresentationOptionSound);
}

#pragma mark -
#pragma mark - UIApplicationDelegate Method

/*!
 * Required for iOS 7+
 */
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //TODO:处理远程推送内容
    NSLog(@"%@", userInfo);
    // Must be called when finished
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 初始化UNUserNotificationCenter
///=============================================================================
/// @name 初始化UNUserNotificationCenter
///=============================================================================

/**
 * 初始化UNUserNotificationCenter
 */
- (void)registerForRemoteNotification {
    // iOS 10 兼容
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
        // 监听回调事件
        [uncenter setDelegate:self];
        //iOS 10 使用以下方法注册，才能得到授权
        [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    //TODO:授权状态改变
                                    NSLog(@"%@" , granted ? @"授权成功" : @"授权失败");
                                }];
        // 获取当前的通知授权状态, UNNotificationSettings
        [uncenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"%s\nline:%@\n-----\n%@\n\n", __func__, @(__LINE__), settings);
            /*
             UNAuthorizationStatusNotDetermined : 没有做出选择
             UNAuthorizationStatusDenied : 用户未授权
             UNAuthorizationStatusAuthorized ：用户已授权
             */
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                NSLog(@"未选择");
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                NSLog(@"未授权");
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                NSLog(@"已授权");
            }
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
//    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
#pragma clang diagnostic pop
}

@end
