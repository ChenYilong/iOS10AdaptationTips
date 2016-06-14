//
//  ViewController.m
//  CYLLocalNotificationDemo
//
//  Created by 陈宜龙 ( https://github.com/ChenYilong ) on  6/15/16.
//  Copyright © 2016 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong ). All rights reserved.
//

#import "ViewController.h"
/// 1. import UserNotifications
//@import Foundation;
//推送通知从Foundation独立出来，成为一个独立的框架。必须导入
@import UserNotifications;

@implementation ViewController
- (IBAction)buttonClicked:(id)sender {
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    /// 2. request authorization for localNotification
    if (systemVersion >= 8.f && systemVersion <10.f)  {
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)
                                                                                                 categories:nil];
        UIApplication *application = [UIApplication sharedApplication];
        [application registerUserNotificationSettings:userNotificationSettings];
    } else if (systemVersion >= 10.f) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (!error) {
                                      NSLog(@"request   succeeded!");
                                  }
                              }];
    }
    
    /// 3. schedule localNotification
    if (systemVersion < 10.f) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.f];
        localNotification.alertTitle = @"Elon said:";
        localNotification.alertBody = @"Hello Tom！Get up, let's play with Jerry!";
        localNotification.alertAction = @"play with Jerry";
        //Identifies the image used as the launch image when the user taps (or slides) the action button (or slider).
        localNotification.alertLaunchImage = @"any string is ok,such as 微博@iOS程序犭袁";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //repeat evey minute
        localNotification.repeatInterval = NSCalendarUnitMinute;
        
        /// 4. update application icon badge number
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        return;
    } else {
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
        // Schedule the notification.
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"user tapped (or slided) the action button (or slider)");
            }
        }];
    }
    
    //如果是测试状态(不是从AppStore下载的版本,与服务器是正式还是测试无关)，则进行如下操作
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
    
}

@end
