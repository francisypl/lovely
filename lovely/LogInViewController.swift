//
//  LogInViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.backgroundColor = UIHelper.fbColor
        logInButton.layer.cornerRadius = 5
        logInButton.clipsToBounds = true
        
        self.view.backgroundColor = UIHelper.mainColor
    }
    
    @IBAction func logInPressed(sender: AnyObject) {
        //TODO fb framework stuff
        
        UIHelper.showFeed(self)
    }
    
}