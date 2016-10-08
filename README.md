# iOS10AdaptationTips

<p align="center">
[![Codewake](https://www.codewake.com/badges/ask_question.svg)](https://www.codewake.com/p/ios10adaptationtips)
</a>

Reference:[**iOS9AdaptationTips**]( https://github.com/ChenYilong/iOS9AdaptationTips ).

## Notification

### User Notifications : both a new and old framework 

If you diff SDK 'iOS 10.0'(Xcode 8)  and SDK 'iOS 9.0' with this command below, you will find six UIKit classes related to notifications are deprecated in SDK 'iOS 10.0'(Xcode 8) .

```
UIKit9Dir="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/UIKit.framework"
UIKit10Dir="/Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/UIKit.framework"

OptIgnore=--ignore-matching-lines='//.*Copyright'
DIFFBIN=/usr/bin/diff
$DIFFBIN -U 1 -r -x '*.tbd' -x '*.modulemap' $OptIgnore $UIKit9Dir $UIKit10Dir|egrep -C 1 "NS_CLASS_DEPRECATED_IOS.*"|grep interface
```

All of them are:

 1. UILocalNotification
 2. UIMutableUserNotificationAction
 3. UIMutableUserNotificationCategory 
 4. UIUserNotificationAction
 5. UIUserNotificationCategory 
 6. UIUserNotificationSettings

Old api also works fine with SDK 'iOS 10.0'(Xcode 8) , but we had better use the APIs in the User Notifications framework instead.

In addation to these classes, the `handleActionWithIdentifier:forLocalNotification:`, `handleActionWithIdentifier:forRemoteNotification:`, `didReceiveLocalNotification:withCompletion:`, and `didReceiveRemoteNotification:withCompletion:` WatchKit methods. Use `handleActionWithIdentifier:forNotification:` and `didReceiveNotification:withCompletion:` instead.
Also the notification-handling methods in WKExtensionDelegate, such as `didReceiveRemoteNotification:` and `handleActionWithIdentifier:forRemoteNotification:`. Instead of using these methods, first create a delegate object that adopts the UNUserNotificationCenterDelegate protocol and implement the appropriate methods. Then assign the delegate object to the delegate property of the singleton UNUserNotificationCenter object.

SDK 'iOS 10.0'(Xcode 8)  introduces the User Notifications framework (UserNotifications.framework), independent from UIKit, which supports the delivery and handling of local and remote notifications. so it's' both a new and old framework. You use the classes of this framework to schedule the delivery of local notifications based on specific conditions, such as time or location. Apps and app extensions can use this framework to receive and potentially modify local and remote notifications when they are delivered to the user’s device.

Also introduced in SDK 'iOS 10.0'(Xcode 8) , the User Notifications UI framework (UserNotificationsUI.framework) lets you customize the appearance of local and remote notifications when they appear on the user’s device. You use this framework to define an app extension that receives the notification data and provides the corresponding visual representation. Your extension can also respond to custom actions associated with those notifications.

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

 1. Now you can either present alert, sound or increase badge while the app is in foreground too with SDK 'iOS 10.0'(Xcode 8) 
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

 1. Now you can either present alert, sound or increase badge while the app is in foreground too with SDK 'iOS 10.0'(Xcode 8) 
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

By the way, you can use this code to check Xcode Version:

 ```Objective-C
#define XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8    __has_include(<UserNotifications/UserNotifications.h>)
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

##  Security

### Access privacy-sensitive data

Before you access privacy-sensitive data like Camera, Contacts, and so on, you must ask for the authorization, your app will crash when you access them.Then Xcode will log like:

 > This app has crashed because it attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain an `NSContactsUsageDescription` key with a string value explaining to the user how the app uses this data.

How to deal with this?

Open the file in your project named `info.plist`, right click it, opening as `Source Code`, paste this code below to it. Or you can open  `info.plist` as `Property List` by default, click the add button, Xcode will give you the suggest completions while typing `Privacy -`  with the help of keyboard  ⬆️ and ⬇️.


Remember to write your description why you ask for this authorization, between   `<string> ` and `</string>`:

 ```XML
    <!-- 🖼 Photo Library -->
	<key>NSPhotoLibraryUsageDescription</key>
	<string></string>
    
    <!-- 📷 Camera -->
	<key>NSCameraUsageDescription</key>
	<string></string>
    
    <!-- 🎤 Microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string></string>
    
    <!-- 📍 Location -->
	<key>NSLocationUsageDescription</key>
	<string></string>
    
    <!-- 📍 Location When In Use -->
	<key>NSLocationWhenInUseUsageDescription</key>
	<string></string>
    
    <!-- 📍 Location Always -->
	<key>NSLocationAlwaysUsageDescription</key>
	<string></string>

    <!-- 📆 Calendars -->
	<key>NSCalendarsUsageDescription</key>
	<string></string>

    <!-- ⏰ Reminders -->
    <key>NSRemindersUsageDescription</key>
    <string></string>
    
    <!-- 🏊 Motion -->
    <key>NSMotionUsageDescription</key>
    <string></string>
    
    <!-- 💊 Health Update -->
    <key>NSHealthUpdateUsageDescription</key>
    <string></string>
    
    <!-- 💊 Health Share -->
    <key>NSHealthShareUsageDescription</key>
    <string></string>
    
    <!-- ᛒ🔵 Bluetooth Peripheral -->
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string></string>

    <!-- 🎵 Media Library -->
    <key>NSAppleMusicUsageDescription</key>
    <string></string>
 ```

If it does not works, try to ask for the the background authorization:


 ```XML 
<key>UIBackgroundModes</key>
<array>
    <!-- something you should use in background -->
    <string>location</string>
</array>
 ```

Or go to `target -> Capabilities -> Background Modes -> open the background Modes`:

![enter image description here](http://cdn2.raywenderlich.com/wp-content/uploads/2014/12/background_modes.png)

then clean your Project, run it.

## You can work with AutoresizingMask and Autolayout Constraints at the same time in Xib and Storyboard

Even iOS6 has give a compatibility to let developer work with AutoresizingMask and Autolayout Constraints together, Xcode can translates AutoresizingMask code into Constraints, but it does not work with Xib or Storyboard.


 ```Objective-C
@interface UIView (UIConstraintBasedCompatibility) 

/* By default, the autoresizing mask on a view gives rise to constraints that fully determine 
 the view's position. This allows the auto layout system to track the frames of views whose 
 layout is controlled manually (through -setFrame:, for example).
 When you elect to position the view using auto layout by adding your own constraints, 
 you must set this property to NO. IB will do this for you.
 */
@property(nonatomic) BOOL translatesAutoresizingMaskIntoConstraints NS_AVAILABLE_IOS(6_0); // Default YES
@end
 ```

But now Xcode8 can translate AutoresizingMask into Autolayout Constraints, so you can work with AutoresizingMask and Autolayout Constraints in Xib or Storyboard at the same time.

## iOS Version Checking

 Do not do this below to check the iOS version in your app:

 ```Objective-C
#define IsIOS7 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)
 ```

It will always return NO, `substringToIndex:1` in SDK 'iOS 10.0'(Xcode 8)  means SDK 'iOS 1.0'.

Use this instead:

Objective-C:

 ```Objective-C
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
 ```

Or:

 ```Objective-C
//App Deployment Target should be beyond 8.0:
if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 9, .minorVersion = 1, .patchVersion = 0}]) {
    NSLog(@"Hello from > iOS 9.1");
}

// Using short-form for the struct, we can make things somewhat more compact:
if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9,3,0}]) {
    NSLog(@"Hello from > iOS 9.3");
}
 ```

Or:

 ```Objective-C
//App Deployment Target should be beyond 2.0:
if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_0) {
    // do stuff for iOS 9 and newer
} else {
    // do stuff for older versions than iOS 9
}
 ```

SDK 'iOS 10.0' (Xcode 8) gives more version numbers even future version.

 ```Objective-C
#define NSFoundationVersionNumber_iOS_9_0 1240.1
#define NSFoundationVersionNumber_iOS_9_1 1241.14
#define NSFoundationVersionNumber_iOS_9_2 1242.12
#define NSFoundationVersionNumber_iOS_9_3 1242.12
#define NSFoundationVersionNumber_iOS_9_4 1280.25
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
 ```

Swift:

 ```Swift
if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0)) {
    // modern code
}
 ```

Or:

 ```Swift
if #available(iOS 10.0, *) {
    // modern code
} else {
    // Fallback on earlier versions
}
 ```

Reference:[***Efficient iOS Version Checking***](https://pspdfkit.com/blog/2016/efficient-iOS-version-checking/).
#【Chinese】 iOS10适配系列教程

###[中文版 chinese edition](https://github.com/BaihaoTian/iOS10AdaptationTips-chineseEdition)

学习交流群：561873398

相关链接： [《iOS9适配系列教程》]( https://github.com/ChenYilong/iOS9AdaptationTips) 。
