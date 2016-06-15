//
//  ViewController.m
//  CYLLocalNotificationDemo
//
//  Created by Elon Chan 陈宜龙 ( https://github.com/ChenYilong ) on  6/15/16.
//  Copyright © 2016 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong ). All rights reserved.
//
#import "ViewController.h"

#define XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8    __has_include(<UserNotifications/UserNotifications.h>)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/// 1. import UserNotifications
///    推送通知从Foundation独立出来，成为一个独立的框架。必须导入
///    Notification independence from Foundation
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
@import UserNotifications;
#endif

@implementation ViewController

- (IBAction)buttonClicked:(id)sender {
    /// 2. request authorization for localNotification
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && SYSTEM_VERSION_LESS_THAN(@"10.0"))  {
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)
                                                                                                 categories:nil];
        UIApplication *application = [UIApplication sharedApplication];
        [application registerUserNotificationSettings:userNotificationSettings];
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (!error) {
                                      NSLog(@"request authorization succeeded!");
                                      [self showAlert];
                                  }
                              }];
#endif
    }
    
    /// 3. schedule localNotification
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.f];
        localNotification.alertTitle = @"Elon said:";
        localNotification.alertBody = @"Hello Tom！Get up, let's play with Jerry!";
        localNotification.alertAction = @"play with Jerry";
        //Identifies the image used as the launch image when the user taps (or slides) the action button (or slider).
        localNotification.alertLaunchImage = @"LaunchImage.png";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //repeat evey minute,  0 means don't repeat
        localNotification.repeatInterval = 0;
        
        /// 4. update application icon badge number
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [self showAlert];
    } else {
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
        
        //        //Deliver the notification at 08:30 everyday
        //        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        //        dateComponents.hour = 8;
        //        dateComponents.minute = 30;
        //        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"Elon said:" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Hello Tom！Get up, let's play with Jerry!"
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        /// 4. update application icon badge number
        content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        content.launchImageName = @"any string is ok,such as 微博@iOS程序犭袁";
        // Deliver the notification in five seconds.
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:5.f repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                              content:content trigger:trigger];
        /// 3. schedule localNotification
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
#endif
    }
}

- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"please enter background now" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    int delayInSeconds = 1;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:(51) / 255.f green:(171) / 255.f blue:(160) / 255.f alpha:1.f];
    button.frame = ({
        CGRect frame = button.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        frame.size.height = 40;
        frame;
    });
    button.center = CGPointMake([UIScreen mainScreen].bounds.size.width * .5, [UIScreen mainScreen].bounds.size.height * .5);
    button.layer.shadowColor = [UIColor grayColor].CGColor;
    button.layer.cornerRadius = 3.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:@"Click me to schedule localNotification" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

@end
