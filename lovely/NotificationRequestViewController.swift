//
//  NotificationRequestViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/13/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class NotificationRequestViewController: UIViewController {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.view.backgroundColor = UIHelper.mainColor
        
        yesButton.backgroundColor = UIHelper.lightMainColor
        yesButton.layer.cornerRadius = 3
        yesButton.clipsToBounds = true

        noButton.backgroundColor = UIHelper.darkMainColor
        noButton.layer.cornerRadius = 3
        noButton.clipsToBounds = true
    }
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
        let type = UIUserNotificationType.Badge.union(UIUserNotificationType.Alert).union(UIUserNotificationType.Sound);
        let setting = UIUserNotificationSettings(forTypes: type, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting);
        UIApplication.sharedApplication().registerForRemoteNotifications();
        
        done()
    }
    
    @IBAction func noButtonPressed(sender: AnyObject) {
        done()
    }
    
    func done() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(true, forKey: "notificationsRequested")
        userDefaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}