//
//  ViewController.m
//  CYLLocalNotificationDemo
//
//  Created by Elon Chan 陈宜龙 ( https://github.com/ChenYilong ) on  6/15/16.
//  Copyright © 2016 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong ). All rights reserved.
//
#import "ViewController.h"

/// 1. import UserNotifications
///    推送通知从 UIKit 独立出来，成为一个独立的框架。必须导入
///    Notification become independent from UIKit
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
@import UserNotifications;
#endif
static NSString *const CYLInviteCategoryIdentifier = @"com.elonchan.localNotification";

@interface ViewController ()

@end

@implementation ViewController

- (void)triggerNotification:(id)sender {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        // create actions
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // create actions
        UNNotificationAction *acceptAction = [UNNotificationAction actionWithIdentifier:@"com.elonchan.yes"
                                                                                  title:@"Accept"
                                                                                options:UNNotificationActionOptionForeground];
        UNNotificationAction *declineAction = [UNNotificationAction actionWithIdentifier:@"com.elonchan.no"
                                                                                   title:@"Decline"
                                                                                 options:UNNotificationActionOptionDestructive];
        UNNotificationAction *snoozeAction = [UNNotificationAction actionWithIdentifier:@"com.elonchan.snooze"
                                                                                   title:@"Snooze"
                                                                                 options:UNNotificationActionOptionDestructive];
        NSArray *notificationActions = @[ acceptAction, declineAction, snoozeAction ];
        
        // create a category
        UNNotificationCategory *inviteCategory = [UNNotificationCategory categoryWithIdentifier:CYLInviteCategoryIdentifier actions:notificationActions intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        
        NSSet *categories = [NSSet setWithObject:inviteCategory];
        
         // registration
        [center setNotificationCategories:categories];
#endif
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        // create actions
        UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
        acceptAction.identifier = @"com.elonchan.yes";
        acceptAction.title = @"Accept";
        acceptAction.activationMode = UIUserNotificationActivationModeBackground;
        acceptAction.destructive = NO;
        acceptAction.authenticationRequired = NO; //If YES requies passcode, but does not unlock the device
        
        UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
        declineAction.identifier = @"com.elonchan.no";
        acceptAction.title = @"Decline";
        acceptAction.activationMode = UIUserNotificationActivationModeBackground;
        declineAction.destructive = YES;
        acceptAction.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *snoozeAction = [[UIMutableUserNotificationAction alloc] init];
        snoozeAction.identifier = @"com.elonchan.snooze";
        acceptAction.title = @"Snooze";
        snoozeAction.activationMode = UIUserNotificationActivationModeBackground;
        snoozeAction.destructive = YES;
        snoozeAction.authenticationRequired = NO;
        
        // create a category
        UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
        inviteCategory.identifier = CYLInviteCategoryIdentifier;
        NSArray *notificationActions = @[ acceptAction, declineAction, snoozeAction ];

        [inviteCategory setActions:notificationActions forContext:UIUserNotificationActionContextDefault];
        [inviteCategory setActions:notificationActions forContext:UIUserNotificationActionContextMinimal];
        
        // registration
        NSSet *categories = [NSSet setWithObject:inviteCategory];
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    /// 2. request authorization for localNotification
    
    [self registerNotificationSettingsCompletionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeeded!");
            [self showAlert];
        }
    }];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
        // //Deliver the notification at 08:30 everyday
        // NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        // dateComponents.hour = 8;
        // dateComponents.minute = 30;
        // UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"Elon said:" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Hello Tom！Get up, let's play with Jerry!"
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier = @"com.elonchan.localNotification";
        /// 4. update application icon badge number
        content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        content.launchImageName = @"any string is ok,such as 微博@iOS程序犭袁";
        // Deliver the notification in five seconds.
        //*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:60.0f repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                              content:content trigger:trigger];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        /// 3. schedule localNotification,The delegate must be set before the application returns from applicationDidFinishLaunching:.
        // center.delegate = self;
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
#endif
    } else {
        /// 3. schedule localNotification
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.f];
        localNotification.alertTitle = @"Elon said:";
        localNotification.alertBody = @"Hello Tom！Get up, let's play with Jerry!";
        localNotification.alertAction = @"play with Jerry";
        //Identifies the image used as the launch image when the user taps (or slides) the action button (or slider).
        localNotification.alertLaunchImage = @"LaunchImage.png";
        localNotification.userInfo = @{ @"CategoryIdentifier" : CYLInviteCategoryIdentifier };
        
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //repeat evey minute,  0 means don't repeat
        localNotification.repeatInterval = NSCalendarUnitMinute;
        /// 4. update application icon badge number
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [self showAlert];
    }
}

- (void)registerNotificationSettingsCompletionHandler:(void (^)(BOOL granted, NSError *__nullable error))completionHandler; {
    /// 2. request authorization for localNotification
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                              completionHandler:completionHandler];
#endif
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))  {
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge)
                                                                                                 categories:nil];
        UIApplication *application = [UIApplication sharedApplication];
        [application registerUserNotificationSettings:userNotificationSettings];
        //FIXME:
        // !completionHandler ?: completionHandler(granted, error);
    }
}

- (void)stopNotification:(id)sender {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
#if XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // remove all local notification:
        [center removeAllPendingNotificationRequests];
        // or you can remove specifical local notification:
//         [center removePendingNotificationRequestsWithIdentifiers:@[ CYLInviteCategoryIdentifier ]];
#endif
    } else {
        // remove all local notification:
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        // or you can remove specifical local notification:
//        NSString *specificalIDToCancel = CYLInviteCategoryIdentifier;
        
//        UILocalNotification *notificationToCancel = nil;
//        for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
//            if([[aNotif.userInfo objectForKey:@"CategoryIdentifier"] isEqualToString:specificalIDToCancel]) {
//                notificationToCancel = aNotif;
//                break;
//            }
//        }
//        if(notificationToCancel) {
//            [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
//        }
    }
}

- (void)addLabel:(NSString *)title backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.backgroundColor = backgroundColor;
    label.text = title;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    label.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, arc4random_uniform([UIScreen mainScreen].bounds.size.height));
    [self.view addSubview:label];
}

//TODO:
//- (void)handleActionWithIdentifier:(NSString *)identifier
//              forLocalNotification:(UILocalNotification *)localNotification {
//
//}

- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"please enter background now"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];
    int delayInSeconds = 1;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *triggerButton = [self buttonWithY:([UIScreen mainScreen].bounds.size.width * .5 - 50)title:@"Click me to trigger localNotification" backgroundColor:[UIColor colorWithRed:(51) / 255.f green:(171) / 255.f blue:(160) / 255.f alpha:1.f]];
    [triggerButton addTarget:self action:@selector(triggerNotification:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:triggerButton];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        UIButton *stopButton = [self buttonWithY:([UIScreen mainScreen].bounds.size.width * .5 + 50)title:@"Click me to stop localNotification" backgroundColor:[UIColor redColor]];
        [stopButton addTarget:self action:@selector(stopNotification:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:stopButton];
    }
}

- (UIButton *)buttonWithY:(CGFloat)Y title:(NSString *)title backgroundColor:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    button.frame = ({
        CGRect frame = button.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width - 10;
        frame.size.height = 40;
        frame;
    });
    button.center = CGPointMake([UIScreen mainScreen].bounds.size.width * .5, Y);
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.shadowColor = [UIColor grayColor].CGColor;
    button.layer.cornerRadius = 6.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    return button;
}

@end
