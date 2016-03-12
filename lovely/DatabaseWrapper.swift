//
//  DatabaseWrapper.swift
//  lovely
//
//  Created by Max Hudson on 3/11/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

struct DatabaseWrapper {
    
    /**
    * Sends post request to the server to insert note
    * @return note id
    */
    static func send(note: Note) -> Int {
        return Int(HttpHelper.post([
            "message": note.message,
            "sub-type": note.subType.rawValue,
            "type": note.type,
            "sender-id": String(note.sender.id),
            "recipient-id": String(note.recipient.id),
            "is-public": note.isPublic ? "1" : "0"
        ], url: "send-note.php"))!
    }
    
    /**
     * Requests block of recent notes
     * @return array of notes
     */
    static func getNotes(isPublic:Bool) -> [Note] {
        let postData = HttpHelper.post([
            "user-id": String(AppState.getCurrentUser().id),
            "is-public": isPublic ? "1" : "0"
            ], url: "notes.php")
        
        return getNotesArrayFromPostData(postData)
    }
    
    /**
     * Request block of notes from before last note
     */
    static func getNotes(lastNote: Note, isPublic : Bool) -> [Note] {
        let postData = HttpHelper.post([
            "user-id": String(AppState.getCurrentUser().id),
            "is-public": isPublic ? "1" : "0",
            "last-note-id": String(lastNote.id)
            ], url: "notes.php")
        
        return getNotesArrayFromPostData(postData)
    }
    
    /**
     * Convert post result to structured notes array
     */
    static func getNotesArrayFromPostData(postData: String) -> [Note] {
        let notesData = HttpHelper.jsonToDictionaryArray(postData)
        
        var notes : [Note] = []
        
        for noteData in notesData! {
            let id = Int(noteData["id"] as! String)!
            let message = noteData["message"] as! String
            let sender = AppState.getUserForId(Int(noteData["sender_id"] as! String)!)
            let recipient = AppState.getUserForId(Int(noteData["recipient_id"] as! String)!)
            let isPublic = noteData["is_public"] as! String == "1"
            let type = noteData["type"] as! String
            let subType = NoteSubType(rawValue: (noteData["sub_type"] as! String))!
            let date = NSDate() //TODO - convert date from db to ns date
            
            notes.append(Note(id: id, message: message, sender: sender, recipient: recipient, isPublic: isPublic, type: type, subType: subType, date: date))
        }
        
        return notes
    }
    
    /**
    * Get user from db by id
    */
    static func getUser(id: Int) -> User {
        let postData = HttpHelper.post([
            "mode": "select",
            "user-id": String(id)
            ], url: "user.php")
        
        let userData = HttpHelper.jsonToDictionary(postData)!
        
        return User(id: Int(userData["id"] as! String)!)
    }
}