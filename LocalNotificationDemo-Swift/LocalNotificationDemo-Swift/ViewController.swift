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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction  func triggerNotification(){
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Elon said:", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Hello Tom！Get up, let's play with Jerry!", arguments: nil)
        content.sound = UNNotificationSound.default()

        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.add(request)
    
        
    }

    @IBAction func stopNotification(_ sender: AnyObject) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["FiveSecond"])
    }
}

extension ViewController:UNUserNotificationCenterDelegate{


    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        
        print("Tapped in notification")
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
         completionHandler( UNNotificationPresentationOptions.alert)
        // completionHandler( UNNotificationPresentationOptions.sound)
        // completionHandler( UNNotificationPresentationOptions.badge)
        
    }
  
}
