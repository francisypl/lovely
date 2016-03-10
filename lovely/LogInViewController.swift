//
//  LogInViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let contentViewController = storyBoard.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController
        
        if contentViewController != nil {
            self.presentViewController(contentViewController!, animated: true, completion: nil)
        }
    }
}