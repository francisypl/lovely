//
//  Note.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

enum NoteSubType : String {
    case Love = "love", FistBump = "fist-bump"
}

class Note {
    private(set) var id: Int = 0
    private(set) var sender: User
    private(set) var recipient: User
    private(set) var message: String
    private(set) var isPublic: Bool
    private(set) var type: String //"note" or "request"
    private(set) var subType: NoteSubType
    private(set) var date: NSDate
    
    /**
    * Primarily used for creating a new note
    */
    init(message: String, recipient: User, isPublic: Bool, type: String, subType: NoteSubType) {
        self.message = message
        self.recipient = recipient
        self.isPublic = isPublic
        self.type = type
        self.subType = subType
        
        self.sender = AppState.getInstance()!.getCurrentUser()
        self.date = NSDate()
    }
    
    /**
    * Used for pulling existing notes
    */
    init(id: Int, message: String, sender: User, recipient: User, isPublic: Bool, type: String, subType: NoteSubType, date: NSDate) {
        self.id = id
        self.message = message
        self.sender = sender
        self.recipient = recipient
        self.isPublic = isPublic
        self.type = type
        self.subType = subType
        self.date = date
    }
    
    /**
     * Inserts note into db and gets id
     */
    func send() {
        self.id = DatabaseWrapper.send(self)
    }
}