//
//  AppDelegate.m
//  CYLLocalNotificationDemo
//
//  Created by Elon Chan 陈宜龙 ( https://github.com/ChenYilong ) on  6/15/16.
//  Copyright © 2016 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong ). All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

///    Notification become independent from UIKit
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
@import UserNotifications;
#endif

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property (nonatomic, strong) UINavigationController *navigationController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
        /// schedule localNotification, the delegate must be set before the application returns from applicationDidFinishLaunching:.
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
#endif
    } else {
        UILocalNotification *localNotifacation = [self getLocalNotificationFromLaunchOptions:launchOptions];
        if (localNotifacation) {
            NSString *title = localNotifacation.alertBody;
            [self addLabel:title];
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

/*!
 *  avoid other behaviours such as Launching by URL Scheme
 */
- (UILocalNotification *)getLocalNotificationFromLaunchOptions:(NSDictionary *const)launchOptions {
    id notification, candidate;
    @try {
        candidate = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    } @catch (NSException *exception) {}
    BOOL isLocalNotificationLaunchOption = [candidate isKindOfClass:[UILocalNotification class]];
    if (isLocalNotificationLaunchOption) {
        notification = candidate;
    }
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

/// invoked not only when enter foreground but also in foreground,
/// when the user tapped (or slided) the action button (or slider) while in foregroud then we should show alert instead of local notification.
/// but can not invoked when the user tapped (or slided) the action button while the app has already been killed,
/// so we have to handle the launch action in `-application:didFinishLaunchingWithOptions:` and tell the right local notification behaviour.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"%@", notification.userInfo);
        if (notification.userInfo) {
            [self addLabel:[NSString stringWithFormat:@"%@", notification.userInfo[@"alertBody"]]];
        }
    }
}

#pragma mark -
#pragma mark - UNUserNotificationCenterDelegate Method

#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"Notification is triggered");
    [self addLabel:notification.request.identifier backgroundColor:[UIColor blueColor]];
    // You can either present alert, sound or increase badge while the app is in foreground too with iOS 10
    // Must be called when finished, when you do not want foreground show, pass UNNotificationPresentationOptionNone to the completionHandler()
    completionHandler(UNNotificationPresentationOptionAlert);
    // completionHandler(UNNotificationPresentationOptionBadge);
    // completionHandler(UNNotificationPresentationOptionSound);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)())completionHandler {
    NSLog(@"Tapped in notification");
    NSString *actionIdentifier = response.actionIdentifier;
    
    if ([actionIdentifier isEqualToString:@"com.apple.UNNotificationDefaultActionIdentifier"] ||
        [actionIdentifier isEqualToString:@"com.apple.UNNotificationDismissActionIdentifier"]) {
        return;
    }
    BOOL accept = [actionIdentifier isEqualToString:@"com.elonchan.yes"];
    BOOL decline = [actionIdentifier isEqualToString:@"com.elonchan.no"];
    BOOL snooze = [actionIdentifier isEqualToString:@"com.elonchan.snooze"];
    do {
        if (accept) {
            NSString *title = @"Tom is comming now";
            [self addLabel:title backgroundColor:[UIColor yellowColor]];
            break;
        }
        if (decline) {
            NSString *title = @"Tom won't come";
            [self addLabel:title backgroundColor:[UIColor redColor]];
            break;
        }
        if (snooze) {
            NSString *title = @"Tom will snooze for minute";
            [self addLabel:title backgroundColor:[UIColor redColor]];
        }
    } while (NO);
    // Must be called when finished
    completionHandler();
}

#endif

@end
