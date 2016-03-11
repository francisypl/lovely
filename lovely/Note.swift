//
//  Note.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

enum NoteSubType {
    case Love, FistBump
}

class Note {
    private(set) var id: Int = 0
    private(set) var sender: User
    private(set) var recipient: User
    private(set) var message: String
    private(set) var isPublic: Bool
    private(set) var type: String //"note" or "request"
    private(set) var subType: NoteSubType
    
    init(message: String, recipient: User, isPublic: Bool, type: String, subType: NoteSubType) {
        self.message = message
        self.recipient = recipient
        self.isPublic = isPublic
        self.type = type
        self.subType = subType
        
        self.sender = AppState.getCurrentUser()
    }
    
    init(id: Int, message: String, recipient: User, isPublic: Bool, type: String, subType: NoteSubType) {
        self.id = id
        self.message = message
        self.recipient = recipient
        self.isPublic = isPublic
        self.type = type
        self.subType = subType
        
        self.sender = AppState.getCurrentUser()
    }
    
    init(id: Int, message: String, sender: User, recipient: User, isPublic: Bool, type: String, subType: NoteSubType) {
        self.id = id
        self.message = message
        self.sender = sender
        self.recipient = recipient
        self.isPublic = isPublic
        self.type = type
        self.subType = subType
    }
    
    func setId(id: Int) {
        self.id = id
    }
    
    func getSubTypeString() -> String {
        switch self.subType {
        case .Love:
            return "love"
        case .FistBump:
            return "fist-bump"
        }
    }
    
    static func getStringFromSubType(subType: NoteSubType) -> String {
        switch subType {
        case .Love:
            return "love"
        case .FistBump:
            return "fist-bump"
        }
    }
    
    static func getSubTypeFromString(string: String) -> NoteSubType {
        switch string {
        case "love":
            return NoteSubType.Love
        case "fist-bump":
            return NoteSubType.FistBump
        default:
            return NoteSubType.Love
        }
    }
    
    func send() {
        self.id = DatabaseWrapper.send(self)
    }
}