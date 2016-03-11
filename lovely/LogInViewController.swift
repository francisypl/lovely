//
//  LogInViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIHelper.mainColor
        
        let loginButton = FBSDKLoginButton()
        
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "user_friends", "email", "user_location", "user_relationships",
        "user_relationship_details"]
        loginButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 100)
        
        self.view.addSubview(loginButton)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
}