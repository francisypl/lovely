//
//  AppState.swift
//  lovely
//
//  Created by Max Hudson on 3/11/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import Foundation

///////////////////I know this isn't a singleton class at the moment I just had to quickly be able to use the methods and didn't know how to singleton
class AppState {
    
    /**
     * Gets user from database
    */
    static func getUserForId(id: Int) -> User {
        let user = DatabaseWrapper.getUser(id)
        
        //join with fb user data
        
        return user
    }
    
    static func getCurrentUser() -> User {
        return User(id: 1, fbId: 1, name: "Name", email: "email", image: UIImage()) //TODO
    }
    
    /**
     Gets batch of most recent notes
    */
    static func getNotes(isPublic: Bool) -> [Note] {
        let notes = DatabaseWrapper.getNotes(isPublic)
        
        //set [Note] to publicFeed/privateFeed
        
        return notes
    }
    
    /**
     Gets batch of notes for appending to bottom of list
    */
    static func getMoreNotes(isPublic: Bool) -> [Note] {
        let lastNote = Note(message: "", recipient: getCurrentUser(), isPublic: true, type: "note", subType: NoteSubType.Love) //TODO - this is just a random note
        
        let notes = DatabaseWrapper.getNotes(lastNote, isPublic: isPublic)
        //append [Note] to publicFeed/privateFeed
        
        return notes
    }
}