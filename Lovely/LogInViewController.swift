//
//  LogInViewController.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let fbPermissions : [String] = ["public_profile", "user_friends", "email"]
    let loginButton : FBSDKLoginButton! = FBSDKLoginButton()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIHelper.mainColor
        
        loginButton.delegate = self
        loginButton.readPermissions = fbPermissions
        loginButton.frame.size.width = 240
        loginButton.frame.size.height = 40
        loginButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 100)
        loginButton.titleLabel!.font = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)
        
        self.view.addSubview(loginButton)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (result.declinedPermissions == nil || result.declinedPermissions.count == 0)
            && !result.isCancelled
            && result.token != nil {
            
            displayLoading()
            
            // Get User info
            let params = ["fields":"id,email,name"]
            let request = FBSDKGraphRequest(graphPath: "/" + result.token.userID, parameters: params, HTTPMethod: "GET")
            request.startWithCompletionHandler({ (connection, result, error) -> Void in
                if let res = result as? [String : AnyObject] {
                    DatabaseWrapper.getUserIdForFbId(res["id"] as! String) { (id) -> () in
                        if id == -1 {
                            DatabaseWrapper.createUser(User(fbId: res["id"] as! String, name: res["name"] as! String, email: res["email"] as! String, image: UIImage()), fbResult: res) { (newId, fbResult) -> () in
                                self.loggedIn()
                            }
                        }
                        else {
                            self.loggedIn()
                        }
                    }
                }
            })
        }
        else {
            // Display failed login message
        }
    }
    
    private func loggedIn() {
        dispatch_async(dispatch_get_main_queue()) {
            _ = AppState.getInstance()
            
            self.removeLoading()
        }
    }
    
    private func displayLoading() {
        print("Logging In...")
        self.loginButton.removeFromSuperview()
        
        indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        indicator.center = CGPointMake(self.view.center.x, self.view.frame.height - 100)
        self.view.addSubview(indicator)
        indicator.bringSubviewToFront(self.view)
        indicator.startAnimating()
    }
    
    private func removeLoading() {
        print("Logged In...")
        // Transition to Feed View
        indicator.stopAnimating()
        indicator.removeFromSuperview()
        
        if let feedVC = UIHelper.showFeed(self) {
            let state = AppState.getInstance()!
            
            state.feedVC = feedVC
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        AppState.clearState()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
}