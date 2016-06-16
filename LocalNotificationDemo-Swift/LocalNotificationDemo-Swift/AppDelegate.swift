//
//  ViewController.m
//  LocalNotificationDemo-Swift
//
//  Created by Elon Chan 陈宜龙 ( https://github.com/ChenYilong ) on  6/15/16.
//  Copyright © 2016 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong ). All rights reserved.
//

import UIKit
import  UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("Tapped in notification")
        let actionIdentifier = response.actionIdentifier
        if actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" || actionIdentifier == "com.apple.UNNotificationDismissActionIdentifier" {
            return;
        }
        let accept = (actionIdentifier == "com.elonchan.yes")
        let decline = (actionIdentifier == "com.elonchan.no")
        let snooze = (actionIdentifier == "com.elonchan.snooze")
        
        repeat {
            if (accept) {
                let title = "Tom is comming now"
                self.addLabel(title: title, color: UIColor.yellow())
                break;
            }
            if (decline) {
                let title = "Tom won't come";
                self.addLabel(title: title, color: UIColor.red())
                break;
            }
            if (snooze) {
                let title = "Tom will snooze for minute"
                self.addLabel(title: title, color: UIColor.red());
                break;
            }
        } while (false);
    }
    private func addLabel(title: String, color: UIColor) {
        let label = UILabel.init()
        label.backgroundColor = UIColor.red()
        label.text = title
        label.sizeToFit()
        label.backgroundColor = color
        let centerX = UIScreen.main().bounds.width * 0.5
        let centerY = CGFloat(arc4random_uniform(UInt32(UIScreen.main().bounds.height)))
        label.center = CGPoint(x: centerX, y: centerY)
        self.window!.rootViewController!.view.addSubview(label)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        // You can either present alert, sound or increase badge while the app is in foreground too with iOS 10
        completionHandler( UNNotificationPresentationOptions.alert)
        // completionHandler( UNNotificationPresentationOptions.sound)
        // completionHandler( UNNotificationPresentationOptions.badge)
    }
}
