//
//  AppDelegate.swift
//  lovely
//
//  Created by Francis Yuen on 3/9/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var activated = false
    var backgrounded = false
    var notificationData: [NSObject : AnyObject]?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if launchOptions != nil {
            if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as! [NSObject : AnyObject]? {
                notificationData = remoteNotification
            }
        }
        
        return true
    }
    
    func handleBackgroundNotification(vc: UIViewController, userInfo: [NSObject : AnyObject]) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let noteId = Int(aps["note_id"] as! String) {
                DatabaseWrapper.getNote(noteId, callback: { (note: Note) -> () in
                    dispatch_async(dispatch_get_main_queue()) {
                        UIHelper.showNote(vc, note: note)
                    }
                })
            }
        }
    }
    
    /**
     * Determines which view should be presented first based
     * on whether user is logged in or not
     */
    func determineFirstView() {
        if !activated {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var rootViewController : UIViewController?
            
            // If the facebook token is valid
            if AppState.isAuthenticated() {
                let state = AppState.getInstance()! // spin up an app state if needed
                
                state.feedVC = mainStoryboard.instantiateViewControllerWithIdentifier("FeedViewController") as? FeedViewController
                
                rootViewController = state.feedVC
            }
            else {
                rootViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LogInViewController") as? LogInViewController
            }
            
            let navigationController = UINavigationController(rootViewController: rootViewController!)
            navigationController.navigationBarHidden = true // or not, your choice.
            
            self.window = UIWindow()
            self.window!.rootViewController = navigationController
            self.window!.makeKeyAndVisible()
            self.window!.frame = UIScreen.mainScreen().bounds
            
            activated = true
            
            if AppState.isAuthenticated() {
                if let data = notificationData {
                    handleBackgroundNotification(rootViewController!, userInfo: data)
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        backgrounded = true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        determineFirstView()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = NSString(format: "%@", deviceToken) as String
        
        DatabaseWrapper.createDevice(deviceTokenString)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if backgrounded {
            if let state = AppState.getInstance() {
                if let vc = state.feedVC {
                    handleBackgroundNotification(vc, userInfo: userInfo)
                }
            }
        
            backgrounded = false
        }
        else {
            if let state = AppState.getInstance() {
                if let aps = userInfo["aps"] as? NSDictionary {
                    if let type = aps["type"] as? NSString {
                        if type == "note" {
                            state.recievedNote()
                        }
                    }
                }
            }
        }
    }
}

