//
//  UIHelper.swift
//  lovely
//
//  Created by Max Hudson on 3/9/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

struct UIHelper {
    
    static var mainColor = UIColor(red: 178/255.0, green: 117/255.0, blue: 187/255.0, alpha: 1)
    static var darkMainColor = UIColor(red: 167/255.0, green: 110/255.0, blue: 175/255.0, alpha: 1)
    static var lightMainColor = UIColor(red: 201/255.0, green: 138/255.0, blue: 210/255.0, alpha: 1)
    static var deleteColor = UIColor(red: 223/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1)
    static var fbColor = UIColor(red: 66/255.0, green: 103/255.0, blue: 178/255.0, alpha: 1)
    static var notificationShowing = false
    
    static func animateUpdateLayout(vc: UIViewController) {
        UIView.animateWithDuration(0.35) {
            vc.view.layoutIfNeeded()
        }
    }
    
    static func showFeed(vc: UIViewController) -> FeedViewController? {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController {
            vc.presentViewController(newVC, animated: true, completion: nil)
            
            return newVC
        }
        
        return nil
    }
    
    static func showLogIn(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("LogInViewController") as? LogInViewController {
            vc.presentViewController(newVC, animated: false, completion: nil)
        }
    }
    
    static func showSend(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("SendViewController") as? SendViewController {
            vc.presentViewController(newVC, animated: true, completion: nil)
        }
    }
    
    static func showRequest(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("RequestViewController") as? RequestViewController {
            vc.presentViewController(newVC, animated: true, completion: nil)
        }
    }
    
    static func showSettings(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController {
            vc.presentViewController(newVC, animated: true, completion: nil)
        }
    }
    
    static func showNotificationRequest(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("NotificationRequestViewController") as? NotificationRequestViewController {
            vc.presentViewController(newVC, animated: true, completion: nil)
        }
    }
    
    static func showIntroduction(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("IntroductionViewController") as? IntroductionViewController {
            vc.presentViewController(newVC, animated: true, completion: nil)
        }
    }
    
    static func ago(date:NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.year >= 1){
            return "\(components.year)y"
        }
        else if (components.month >= 1){
            return "\(components.month)m"
        }
        else if (components.weekOfYear >= 1){
            return "\(components.weekOfYear)w"
        }
        else if (components.day >= 1){
            return "1d"
        }
        else if (components.hour >= 1){
            return "\(components.hour)h"
        }
        else if (components.minute >= 1){
            return "\(components.minute)m"
        }
        else if (components.second >= 3) {
            return "\(components.second)s"
        }
        else {
            return "now"
        }
        
    }
    
    static func showErrorMessage(message: String, vc: UIViewController) {
        if notificationShowing {
            return
        }
        
        notificationShowing = true
        let notification = UIView()
        let navBarHeight: CGFloat = 64.0
        let height: CGFloat = 30.0
        notification.frame = CGRectMake(0, navBarHeight - height, vc.view.frame.width, height)
        notification.backgroundColor = UIHelper.deleteColor
        
        let label = UILabel(frame: CGRectMake(0, 0, notification.frame.width, notification.frame.height))
        label.text = message
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        
        notification.addSubview(label)
        vc.view.addSubview(notification)
        
        let toolbar = vc.view.subviews[0]
        vc.view.bringSubviewToFront(notification)
        vc.view.bringSubviewToFront(toolbar)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            notification.frame.origin.y += height
            }) { (completed) -> Void in
                UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    notification.frame.origin.y -= height
                    }, completion: { (completed) -> Void in
                        notification.removeFromSuperview()
                        vc.view.sendSubviewToBack(toolbar)
                        notificationShowing = false
                })
        }
    }
    
    static func showConnectionLostErrorMessage(vc: UIViewController) {
        showErrorMessage("Connection Lost", vc: vc)
    }
    
    static func showAlertView(withTitle title: String, message: String) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}

extension UIImageView{
    
    func circle() {
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
    
}