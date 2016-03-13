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
    private var currentUser: User
    static var state: AppState?
    private var publicFeed: [Note]
    private var privateFeed: [Note]
    private var friendsList: [User]
    private var pageNumber: Int
    
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
        self.currentUser = User(id: 1, fbId: "", name: "Name", email: "email")
        self.friendsList = []
        self.publicFeed = []
        self.privateFeed = []
        self.pageNumber = 0
        
        // Check if user is authenticated
        let token = FBSDKAccessToken.currentAccessToken()
        // Get User Info
        let params = ["fields":"id,email,name"]
        let request = FBSDKGraphRequest(graphPath: "/" + token.userID, parameters: params, HTTPMethod: "GET")
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            let res = result as! [String : String]
            let id = DatabaseWrapper.getUser(res["id"]!).id
            
            // Set current User
            self.currentUser = User(id: id, fbId: res["id"]!, name: res["name"]!, email: res["email"]!)
        })
        
        // Load friends list
    }
    
    /**
     * Determine if the Facebook token is valid
     */
    static func isAuthenticated() -> Bool {
        return FBSDKAccessToken.currentAccessToken() != nil && !FBSDKAccessToken.currentAccessToken().isExpired()
    }
    
    func refreshNotes() {
    
    }
    
    /**
     * Gets batch of most recent notes
     */
    func getNotes(isPublic: Bool) -> [Note] {
        let notes = DatabaseWrapper.getNotes(isPublic)
        
        //set [Note] to publicFeed/privateFeed
        
        return notes
    }
    
    func getCurrentUser() -> User {
        return User(id: 1, fbId: "", name: "Name", email: "email") //TODO
    }
    
    func suggestRecipientFromFriendList(name : String) -> [User] {
        return [User(id: 1, fbId: "", name: "Name", email: "email")] // TODO
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
        let lastNote = Note(message: "", recipient: getCurrentUser(), isPublic: true, type: "note", subType: NoteSubType.Love) //TODO - this is just a random note
        
        let notes = DatabaseWrapper.getNotes(lastNote, isPublic: isPublic)
        //append [Note] to publicFeed/privateFeed
        
        return notes
    }

}