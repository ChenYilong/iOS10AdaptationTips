# iOS10AdaptationTips [Draft, not published]

Reference:[**iOS9AdaptationTips**]( https://github.com/ChenYilong/iOS9AdaptationTips ).

## Notification

### User Notifications : both a new and old framework 

in iOS10, Several UIKit classes related to notifications are deprecated, such as

 1. UILocalNotification
 2. UIMutableUserNotificationAction
 3. UIMutableUserNotificationCategory 
 4. UIUserNotificationAction
 5. UIUserNotificationCategory 
 6. UIUserNotificationSettings

Old api also works fine with iOS10, but we had better use the APIs in the User Notifications framework instead.

In addation to these classes, the `handleActionWithIdentifier:forLocalNotification:`, `handleActionWithIdentifier:forRemoteNotification:`, `didReceiveLocalNotification:withCompletion:`, and `didReceiveRemoteNotification:withCompletion:` WatchKit methods. Use `handleActionWithIdentifier:forNotification:` and `didReceiveNotification:withCompletion:` instead.
Also the notification-handling methods in WKExtensionDelegate, such as `didReceiveRemoteNotification:` and `handleActionWithIdentifier:forRemoteNotification:`. Instead of using these methods, first create a delegate object that adopts the UNUserNotificationCenterDelegate protocol and implement the appropriate methods. Then assign the delegate object to the delegate property of the singleton UNUserNotificationCenter object.

iOS 10 introduces the User Notifications framework (UserNotifications.framework), independent from UIKit, which supports the delivery and handling of local and remote notifications. so it's' both a new and old framework. You use the classes of this framework to schedule the delivery of local notifications based on specific conditions, such as time or location. Apps and app extensions can use this framework to receive and potentially modify local and remote notifications when they are delivered to the user’s device.

Also introduced in iOS 10, the User Notifications UI framework (UserNotificationsUI.framework) lets you customize the appearance of local and remote notifications when they appear on the user’s device. You use this framework to define an app extension that receives the notification data and provides the corresponding visual representation. Your extension can also respond to custom actions associated with those notifications.

I'll introduce the User Notifications framework in two parts:
 1. Local Notification
 2. Romote Notification

### LocalNotification : write everything in on place

Someone may have the same question with this guy:
![enter image description here](http://a65.tinypic.com/2roqpw1.jpg) 

It is impossible for the first question, but local notification may be the best way to help you In terms of waking the app at a certain time, even a certain place. Because LocalNotification is just for scheduling the delivery of local notifications based on specific conditions, such as time or location.

LocalNotification has a limit, you can't trigger a block of code to run when the notification is fired.  You can, however, trigger a block of code to execute with a  [UNNotificationAction](https://developer.apple.com/reference/usernotifications/unnotificationaction) by adding an action to your notification and using `userNotificationCenter(_:didReceive:withCompletionHandler:)` on `UNUserNotificationCenter.currentNotificationCenter()`. That is to say, it's impossiable to run a snippet in background at a certain time, without notifiying user. This feature is limited byond iOS8.

#### schedule the delivery of local notifications based on time

Big Diff:

 1. Now you can either present alert, sound or increase badge while the app is in foreground too with iOS 10
 2. Now you can handle all event in one place when user tapped (or slided) the action button, even while the app has already been killed.
 3. Support 3D touch instead of sliding gesture.
 4. Now you can remove specifical local notification just by one row code.

sample use with Objective-C implemation:

I write a Demo here:  [**iOS10AdaptationTips**](https://github.com/ChenYilong/iOS10AdaptationTips) .

 1. import UserNotifications


        ///    Notification become independent from UIKit
        @import UserNotifications;


 2. request authorization for localNotification

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (!error) {
                                      NSLog(@"request authorization succeeded!");
                                      [self showAlert];
                                  }
                              }];


 3. schedule localNotification
 4. update application icon badge number

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

then it will appear like this:

iOS Version | iOS10  | iOS9
-------------|--------------|-------------
Request Authorization |  ![enter image description here](http://a65.tinypic.com/fbicjt.jpg) | ![enter image description here](http://i67.tinypic.com/spulac.jpg)
In Background | ![enter image description here](http://a67.tinypic.com/ve3dy8.jpg) | ![enter image description here](http://i65.tinypic.com/oh253c.jpg)
Lock Screen |  ![enter image description here](http://a64.tinypic.com/33vf39i.jpg) | ![enter image description here](http://i63.tinypic.com/28l6uwy.jpg)
If Repeat by default |  ![enter image description here](http://a64.tinypic.com/33vf39i.jpg) |![enter image description here](http://i67.tinypic.com/98t75s.jpg)
 3D Touch |  ![enter image description here](http://a67.tinypic.com/dorw3b.jpg) | not support

 1. Now you can either present alert, sound or increase badge while the app is in foreground too with iOS 10
 2. Now you can handle all event in one place when user tapped (or slided) the action button, even while the app has already been killed.
 3. Support 3D touch instead of sliding gesture.
 4. Now you can remove specifical local notification just by one row code.

 ```Objective-C

- (void)stopNotification:(id)sender {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // remove all local notification:
//        [center removeAllPendingNotificationRequests];
        // or you can remove specifical local notification:
         [center removePendingNotificationRequestsWithIdentifiers:@[ CYLInviteCategoryIdentifier ]];
    } else {
        // remove all local notification:
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        // or you can remove specifical local notification:
        NSString *specificalIDToCancel = CYLInviteCategoryIdentifier;
        UILocalNotification *notificationToCancel = nil;
        for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            if([[aNotif.userInfo objectForKey:@"CategoryIdentifier"] isEqualToString:specificalIDToCancel]) {
                notificationToCancel = aNotif;
                break;
            }
        }
        if(notificationToCancel) {
            [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
        }
    }
}

 ```

#### schedule the delivery of local notifications based on location

If your iPhone installed Foursquare-app, you will deliver notification when you enters or leaves a geographic region. How to do that?

## some little error

> Check dependencies
Signing for Your-Prject-Name requires a development team. Select a development team in the Target Editor.
Warning: The Copy Bundle Resources build phase contains this target's Info.plist file '/Users/<Your-Prject-Path>/Info.plist'.
Code signing is required for product type 'Application' in SDK 'iOS 10.0'


## ATS

Reference : [***Security and Privacy Enhancements***](https://developer.apple.com/library/prerelease/content/releasenotes/General/WhatsNewIniOS/Articles/iOS10.html#//apple_ref/doc/uid/TP40017084-SW3) 



#【Chinese】 iOS10适配系列教程

学习交流群：561873398

相关链接： [《iOS9适配系列教程》]( https://github.com/ChenYilong/iOS9AdaptationTips) 。
