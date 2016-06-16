//
//  ViewController.m
//  LocalNotificationDemo-Swift
//
//  Created by Elon Chan 陈宜龙 ( https://github.com/ChenYilong ) on  6/15/16.
//  Copyright © 2016 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong ). All rights reserved.
//

import UIKit
import  UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let center = UNUserNotificationCenter.current()
        
        // create actions
        let accept = UNNotificationAction.init(identifier: "com.elonchan.yes",
                                               title: "Accept",
                                               options: UNNotificationActionOptions.foreground)
        let decline = UNNotificationAction.init(identifier: "com.elonchan.no",
                                                title: "Decline",
                                                options: UNNotificationActionOptions.destructive)
        let snooze = UNNotificationAction.init(identifier: "com.elonchan.snooze", title: "Snooze", options: UNNotificationActionOptions.destructive)
        let actions = [ accept, decline, snooze ]
        
        // create a category
        let inviteCategory = UNNotificationCategory(identifier: "com.elonchan.localNotification",
                                                    actions: actions,
                                                    minimalActions: actions,
                                                    intentIdentifiers: [],
                                                    options: [])
        
        // registration
        center.setNotificationCategories([ inviteCategory ])
        center.requestAuthorization([.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction  func triggerNotification(){
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Elon said:", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Hello Tom！Get up, let's play with Jerry!", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = UIApplication.shared().applicationIconBadgeNumber + 1;
        content.categoryIdentifier = "com.elonchan.localNotification"
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: true)
        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }

    @IBAction func stopNotification(_ sender: AnyObject) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // or you can remove specifical notification:
        // center.removePendingNotificationRequests(withIdentifiers: ["FiveSecond"])
    }
}


