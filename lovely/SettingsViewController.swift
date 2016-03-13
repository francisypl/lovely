//
//  SettingsViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusBarBackground.backgroundColor = UIHelper.mainColor
        
        navBar.barTintColor = UIHelper.mainColor
        navBar.clipsToBounds = true
        
        let loginButton = FBSDKLoginButton()
        
        loginButton.delegate = self
        loginButton.frame.size.width = 240
        loginButton.frame.size.height = 40
        loginButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 100)
        loginButton.titleLabel!.font = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)
        
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
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}