//
//  AppState.swift
//  lovely
//
//  Created by Francis Yuen on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit
import FBSDKCoreKit

extension FBSDKAccessToken {
    func isExpired() -> Bool {
        let token = FBSDKAccessToken.currentAccessToken()
        if token == nil {
            return true
        }
        return token.expirationDate!.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
}

class AppState {
    private(set) var currentUser: User
    static var state: AppState?
    private(set) var publicFeed: [Note]
    private(set) var privateFeed: [Note]
    private(set) var friendsList: [Int: User]
    private var lastPublicNoteId: Int
    private var lastPrivateNoteId: Int
    
    private(set) var outOfPublicNotes: Bool //no more public notes to load
    private(set) var outOfPrivateNotes: Bool //no more private notes to load
    
    private(set) var readyForUserControl: Bool //ready to let user reload page
    
    internal var feedVC: FeedViewController?
    internal var notificationCount: Int
    
    /**
     * Gets the current AppState instance.
     * If we don't have one, make one.
     * If the facebook token is not good, send app back to login screen.
     */
    static func getInstance() -> AppState? {
        let token = FBSDKAccessToken.currentAccessToken()
        // Send the user to login again if the token is expired
        if token == nil || token.isExpired() {
            print("Token is expired...")
            // TODO: Take them to the login screen
            return nil
        }
        
        if state == nil {
            print("Initializing App State...")
            state = AppState()
        }
        
        return state!
    }
    
    /**
     * Initialize a new App State.
     * @precondition: Facebook token must be a valid token.
     */
    private init() {
        // Load the stat with some dummy data
        self.currentUser = User(id: 0, fbId: "", name: "Name", email: "email", image: UIImage())
        self.friendsList = [Int: User]()
        
        self.publicFeed = []
        self.privateFeed = []
        
        self.lastPublicNoteId = 0
        self.lastPrivateNoteId = 0
        
        self.outOfPublicNotes = false
        self.outOfPrivateNotes = false
        
        self.readyForUserControl = false
        
        self.notificationCount = 0
        
        // Check if user is authenticated
        // Get User Info
        let params = ["fields":"id, email, name, picture.width(200).height(200)"]
        
        let request = FBSDKGraphRequest(graphPath: "/v2.5/me", parameters: params, HTTPMethod: "GET")
        
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            if let res = result as? [String : AnyObject] {
                DatabaseWrapper.getUserIdForFbId(res["id"] as! String) { ( id) -> () in
                    //Verify user exists, create if they don't
                    if id == -1 {
                        DatabaseWrapper.createUser(User(fbId: res["id"] as! String, name: res["name"] as! String, email: res["email"] as! String, image: UIImage()), fbResult: res, callback: self.buildCurrentUser)
                    }
                    else {
                        self.buildCurrentUser(id, fbResult: res)
                    }
                }
            }
        })
    }
    
    /**
     * Sets up current user
     */
    func buildCurrentUser(id: Int, fbResult: [String : AnyObject]?) {
        if let res = fbResult {
            //Profile picture
            let pictureData = (res["picture"] as! NSDictionary)["data"] as! NSDictionary
            let profilePictureUrl = NSURL(string: pictureData["url"] as! String)
            let profilePictureUrlData = NSData(contentsOfURL: profilePictureUrl!)
            let profilePicture = UIImage(data: profilePictureUrlData!)
            
            // Set current User
            self.currentUser = User(id: id, fbId: res["id"] as! String, name: res["name"] as! String, email: res["email"] as! String, image: profilePicture!)
            
            self.getFriendsList()
        }
    }
    
    /**
     * Populate friendsList variable
     */
    func getFriendsList() {
        //has to be inside main queue block for FBSDK to work
        dispatch_async(dispatch_get_main_queue()) {
            //taggable_friends -> all friends ... /friends -> friends with the app
            //sort alphabetically?
            //not paginated ideally
            let params = ["fields":"id, email, name, picture.width(100).height(100)"]
            let friendsRequest = FBSDKGraphRequest(graphPath: "/v2.5/me/friends", parameters: params, HTTPMethod: "GET")
            
            //Get friends list
            friendsRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                /////////////////////Won't come inside here for some reason
                let res = result as! NSDictionary
               
                let friendsData = res["data"] as! [NSDictionary]
                
                var friends: [User] = []
                
                //Build [User] array
                for friendData in friendsData {
                    
                    //Profile picture
                    let pictureData = (friendData["picture"] as! NSDictionary)["data"] as! NSDictionary
                    let profilePictureUrl = NSURL(string: pictureData["url"] as! String)
                    let profilePictureUrlData = NSData(contentsOfURL: profilePictureUrl!)
                    let profilePicture = UIImage(data: profilePictureUrlData!)
                    
                    let friend = User(id: 0, fbId: friendData["id"] as! String, name: friendData["name"] as! String, email: friendData["id"] as! String, image: profilePicture!)
                    
                    friends.append(friend)
                }
                
                DatabaseWrapper.getFriendIds(friends) { (friends: [Int: User]) -> () in
                    self.friendsList = friends
                    self.friendsList[self.currentUser.id] = self.getJournal()
                    
                    self.loadFeed()
                }
            })
        }
    }
    
    /**
     * App is all ready to show feed
     */
    func loadFeed() {
        if let feed = self.feedVC {
            self.refreshNotes(true) { Void -> () in
                feed.extraPrivateCells = 2
                feed.reloadTable()
                
                self.readyForUserControl = true
                
                print("Initialized...")
            }
            
            self.refreshNotes(false, callback: nil)
        }
    }
    
    /**
     * Gets generic journal user
     */
    func getJournal() -> User{
        return User(id: self.currentUser.id, fbId: self.currentUser.fbId, name: "Journal", email: "", image: UIImage(named: "journal-icon")!)
    }
    
    /**
     * Gets generic public user for requests
     */
    static func getPublicUser() -> User {
        return User(id: 0, fbId: "", name: "Public", email: "", image: UIImage())
    }
    
    /**
     * Determine if the Facebook token is valid
     */
    static func isAuthenticated() -> Bool {
        return FBSDKAccessToken.currentAccessToken() != nil && !FBSDKAccessToken.currentAccessToken().isExpired()
    }
    
    /**
     * Updates feed variables
     */
    func refreshNotes(isPublic: Bool, callback: (Void -> ())?) {
        DatabaseWrapper.getNotes(isPublic) { (notes) -> () in
            if isPublic {
                self.publicFeed = notes
                self.outOfPublicNotes = false
                
                if notes.last != nil {
                    self.lastPublicNoteId = notes.last!.id
                }
            }
            else {
                self.privateFeed = notes
                self.outOfPrivateNotes = false
                
                if notes.last != nil {
                    self.lastPrivateNoteId = notes.last!.id
                }
            }
            
            if callback != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    callback!()
                }
            }
        }
    }
    
    /**
     * Get batch of notes to append to feeds
     */
    func appendNotes(isPublic: Bool, callback: (() -> ())?) -> [Note] {
        let outOfNotes = isPublic ? self.outOfPublicNotes : self.outOfPrivateNotes
        
        if !outOfNotes {
            let lastNoteId = isPublic ? self.lastPublicNoteId : self.lastPrivateNoteId
            
            DatabaseWrapper.getNotes(lastNoteId, isPublic: isPublic) { (notes) -> () in
                if isPublic {
                    self.publicFeed += notes
                    
                    if notes.last != nil {
                        self.lastPublicNoteId = notes.last!.id
                    }
                    else {
                        self.outOfPublicNotes = true
                    }
                }
                else {
                    self.privateFeed += notes
                    
                    if notes.last != nil {
                        self.lastPrivateNoteId = notes.last!.id
                    }
                    else {
                        self.outOfPrivateNotes = true
                    }
                }
                
                if callback != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        callback!()
                    }
                }
            }
        }
        
        return []
    }
    
    /**
     * Allows public note deletion
     */
    func deletePublicNoteAtIndex(index: Int) {
        self.publicFeed.removeAtIndex(index)
    }
    
    /**
     * Allows private note deletion
     */
    func deletePrivateNoteAtIndex(index: Int) {
        self.privateFeed.removeAtIndex(index)
    }
    
    /**
     * Gets user from database
     */
    static func getUserForId(id: Int) -> User {
        let user = DatabaseWrapper.getUser(id)
        
        //join with fb user data
        
        return user
    }
    
    /**
     * Handler for note notification
     */
    func recievedNote() {
        self.notificationCount++
        
        if let feed = self.feedVC {
            feed.privacyToggle.setTitle("Private (" + String(self.notificationCount) + ")", forSegmentAtIndex: 1)
            feed.privacyToggle.apportionsSegmentWidthsByContent = true
            
            self.refreshNotes(false, callback: nil)
            
            //tableView.reloadData() if viewing private?
        }
    }
    
    func suggestRecipientFromFriendList(name : String) -> [User] {
        return []
    }
    
    /**
     * Clears the state.
     */
    static func clearState() {
        AppState.state = nil
    }

}