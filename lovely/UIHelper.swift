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
    static var fbColor = UIColor(red: 66/255.0, green: 103/255.0, blue: 178/255.0, alpha: 1)
    
    static func animateUpdateLayout(vc: UIViewController) {
        UIView.animateWithDuration(0.35) {
            vc.view.layoutIfNeeded()
        }
    }
    
    static func showFeed(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVC = storyBoard.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController
        
        if newVC != nil {
            vc.presentViewController(newVC!, animated: false, completion: nil)
        }
    }
    
    static func showSend(vc: UIViewController) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVC = storyBoard.instantiateViewControllerWithIdentifier("SendViewController") as? SendViewController
        
        if newVC != nil {
            vc.presentViewController(newVC!, animated: true, completion: nil)
        }
    }
}