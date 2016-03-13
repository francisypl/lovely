//
//  SettingsViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        
        loginButton.delegate = self
        loginButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 100)
        
        self.view.addSubview(loginButton)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        AppState.clearState()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        UIHelper.showLogIn(self)
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
}