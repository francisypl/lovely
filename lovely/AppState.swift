//
//  AppState.swift
//  lovely
//
//  Created by Francis Yuen on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import Foundation

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
    private(set) var friendsList: [User]
    private var lastPublicNoteId: Int
    private var lastPrivateNoteId: Int
    
    private(set) var outOfPublicNotes: Bool = false
    private(set) var outOfPrivateNotes: Bool = false
    
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
        self.friendsList = []
        
        self.publicFeed = []
        self.privateFeed = []
        
        self.lastPublicNoteId = 0
        self.lastPrivateNoteId = 0
        
        // Check if user is authenticated
        //let token = FBSDKAccessToken.currentAccessToken()
        // Get User Info
        let params = ["fields":"id, email, name, picture.width(200).height(200)"]
        
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: params, HTTPMethod: "GET")
        
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            let res = result as! [String : AnyObject]
            var id = DatabaseWrapper.getUserIdForFbId(res["id"] as! String)
            
            //Verify user exists, create if they don't
            if id == -1 {
                id = DatabaseWrapper.createUser(User(fbId: res["id"] as! String, name: res["name"] as! String, email: res["email"] as! String, image: UIImage()))
            }
            
            //Profile picture
            let pictureData = (res["picture"] as! NSDictionary)["data"] as! NSDictionary
            let profilePictureUrl = NSURL(string: pictureData["url"] as! String)
            let profilePictureUrlData = NSData(contentsOfURL: profilePictureUrl!)
            let profilePicture = UIImage(data: profilePictureUrlData!)
            
            // Set current User
            self.currentUser = User(id: id, fbId: res["id"] as! String, name: res["name"] as! String, email: res["email"] as! String, image: profilePicture!)
            
            self.getFriendsList()
        })
        
        //I want these here but they make the app state initalize indefinitely
        //self.refreshNotes(true)
        //self.refreshNotes(false)
    }
    
    /**
     * Populate friendsList variable
     */
    func getFriendsList() {
        //taggable_friends -> all friends ... /friends -> friends with the app
        //sort alphabetically?
        //not paginated ideally
        let params = ["fields":"id, email, name, picture.width(50).height(50)"]
        let friendsRequest = FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: params, HTTPMethod: "GET")
        
        //Get friends list
        friendsRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
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
            
            let diary = User(id: self.currentUser.id, fbId: self.currentUser.fbId, name: "Diary", email: "", image: UIImage()) //need diary icon
            
            self.friendsList = [diary] + DatabaseWrapper.getFriendIds(friends)
            
            print(self.friendsList.count)
        })
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
    func refreshNotes(isPublic: Bool) {
        let notes = getNotes(isPublic)
        
        if isPublic {
            self.publicFeed = notes
            self.outOfPublicNotes = false
            
            if notes.last != nil {
                self.lastPublicNoteId = notes.last!.id
            }
        }
        else {
            self.privateFeed = notes
            self.outOfPrivateNotes = true
            
            if notes.last != nil {
                self.lastPrivateNoteId = notes.last!.id
            }
        }
    }
    
    /**
     * Get batch of notes to append to feeds
     */
    func appendNotes(isPublic: Bool) -> [Note] {
        let outOfNotes = isPublic ? self.outOfPublicNotes : self.outOfPrivateNotes
        
        if !outOfNotes {
            let notes = self.getMoreNotes(isPublic)
            
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
                    self.outOfPublicNotes = true
                }
            }
        }
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
     * Gets batch of most recent notes
     */
    func getNotes(isPublic: Bool) -> [Note] {
        let notes = DatabaseWrapper.getNotes(isPublic)
        
        return notes
    }
    
    /**
     * Clears the state.
     */
    static func clearState() {
        AppState.state = nil
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
     * Gets batch of notes for appending to bottom of list
     */
    private func getMoreNotes(isPublic: Bool) -> [Note] {
        let lastNoteId = isPublic ? self.lastPublicNoteId : self.lastPrivateNoteId
        
        let notes = DatabaseWrapper.getNotes(lastNoteId, isPublic: isPublic)
        
        return notes
    }

}