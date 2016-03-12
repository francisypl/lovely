//
//  AppState.swift
//  lovely
//
//  Created by Francis Yuen on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import Foundation

class AppState {
    private var loggedIn: Bool
    private var currentUser: User
    static var state: AppState?
    private var publicFeed: [Note]?
    private var privateFeed: [Note]?
    private var friendsList: [User]
    private var pageNumber: Int
    
    static func getInstance() -> AppState {
        if state == nil {
            state = AppState()
        }
        
        return state!
    }
    
    private init() {
        // Check if user is authenticated
        
    }
    
    func isAuthenticated() -> Bool {
        return true
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
        return User(id: 1, fbId: 1, name: "Name", email: "email", image: UIImage()) //TODO
    }
    
    func suggestRecipientFromFriendList(name : String) -> [User] {
        return [User(id: 1, fbId: 1, name: "Name", email: "email", image: UIImage())] // TODO
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