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
    static func send(note: Note, callback: (() -> ())?) {
        HttpHelper.post_async([
            "message": note.message,
            "sub-type": note.subType.rawValue,
            "type": note.type,
            "sender-id": String(note.sender.id),
            "sender-name": note.sender.name,
            "recipient-id": String(note.recipient.id),
            "is-public": note.isPublic ? "1" : "0"
        ], url: "send-note.php") { (response) -> () in
            if let id = Int(response) {
                note.setId(id)
                
                callback?()
            }
        }
    }
    
    /**
     * Deletes note from db
     */
    static func deleteNote(note: Note) {
        HttpHelper.post_async([
            "mode": "delete",
            "note-id": String(note.id)
        ], url: "note.php", callback: nil)
    }
    
    /**
     * Sends post request to the server to insert note
     * @return note id
     */
    static func likeNote(note: Note) {
        if let state = AppState.getInstance() {
            HttpHelper.post_async([
                "mode": "like",
                "user-id": String(state.currentUser.id),
                "user-name": state.currentUser.name,
                "note-id": String(note.id)
                ], url: "note.php") { (response) -> () in
                    print(response)
            }
        }
    }
    
    /**
     * Sends post request to the server to insert note
     * @return note id
     */
    static func unlikeNote(note: Note) {
        if let state = AppState.getInstance() {
            HttpHelper.post_async([
                "mode": "unlike",
                "user-id": String(state.currentUser.id),
                "note-id": String(note.id)
            ], url: "note.php", callback: nil)
        }
    }
    
    /**
     * Requests block of recent notes
     * @return array of notes
     */
    static func getNotes(isPublic: Bool, callback: ((notes: [Note]) -> ())?) {
        DatabaseWrapper.getNotes(0, isPublic: isPublic, callback: callback)
    }
    
    /**
     * Request block of notes from before last note
     */
    static func getNotes(lastNoteId: Int, isPublic : Bool, callback: ((notes: [Note]) -> ())?) {
        if let state = AppState.getInstance() {
            do {
                let ids = Array(state.friendsList.keys)
                let idsJsonData = try NSJSONSerialization.dataWithJSONObject(ids, options: NSJSONWritingOptions.PrettyPrinted)
                let idsString = NSString(data: idsJsonData, encoding: NSUTF8StringEncoding)
                
                HttpHelper.post_async([
                    "user-id": String(state.currentUser.id),
                    "is-public": isPublic ? "1" : "0",
                    "last-note-id": String(lastNoteId),
                    "ids": idsString as! String
                ], url: "notes.php") { (response) -> () in
                    if callback != nil {
                        callback!(notes: getNotesArrayFromPostData(response))
                    }
                }
            }
            catch {
                print("Couldn't convert ids to json")
            }
        }
    }
    
    /**
     * Convert post result to structured notes array
     */
    static func getNotesArrayFromPostData(postData: String) -> [Note] {
        if let notesData = HttpHelper.jsonToDictionaryArray(postData) {
            var notes : [Note] = []
            
            for noteData in notesData {
                if let note = DatabaseWrapper.noteFromNoteData(noteData, mode: "bulk") {
                    notes.append(note)
                }
            }
            
            return notes
        }
        
        return []
    }
    
    static func getNote(id: Int, callback: ((note: Note) -> ())?) {
        HttpHelper.post_async([
            "mode": "request",
            "note-id": String(id)
        ], url: "note.php") { (response) -> () in
            if let noteData = HttpHelper.jsonToDictionary(response) {
                if let note = DatabaseWrapper.noteFromNoteData(noteData, mode: "individual") {
                    callback?(note: note)
                }
            }
        }

    }
    
    static func noteFromNoteData(noteData: [String: AnyObject], mode: String) -> Note? {
        if let state = AppState.getInstance() {
            print(noteData)
            let senderId = Int(noteData["sender_id"] as! String)!
            let recipientId = Int(noteData["recipient_id"] as! String)!
            let id = Int(noteData["id"] as! String)!
            let message = noteData["message"] as! String
            let isPublic = noteData["is_public"] as! String == "1"
            let type = noteData["type"] as! String
            let subType = NoteSubType(rawValue: (noteData["sub_type"] as! String))!
            let date = NSDate(timeIntervalSince1970: Double(noteData["date"] as! String)!)
            
            if let sender = state.friendsList[senderId] {
                var recipient : User?
                
                if type == "request" && recipientId == 0 {
                    recipient = AppState.getPublicUser()
                }
                else if (state.friendsList[recipientId] != nil) {
                    recipient = state.friendsList[recipientId]!
                }
                
                if recipient != nil {
                    let note = Note(id: id, message: message, sender: sender, recipient: recipient!, isPublic: isPublic, type: type, subType: subType, date: date)
                    
                    if mode == "bulk" {
                        note.likes = Int(noteData["like_count"] as! String)!
                        note.liked = (noteData["liked"] as! String) == "1"
                        note.comments = Int(noteData["comment_count"] as! String)!
                    }
                    
                    return note
                }
            }
        }
        
        return nil
    }
    
    /**
     * Get user from db by fbId
     */
    static func getUserIdForFbId(fbId: String, callback: ((id: Int) -> ())?) {
        HttpHelper.post_async([
            "mode": "select",
            "fb-id": fbId,
        ], url: "user.php") { (response) -> () in
            if let userData = HttpHelper.jsonToDictionary(response) {
                if callback != nil {
                    callback!(id: Int(userData["id"] as! String)!)
                }
            }
        }
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
    
    /**
     * Sends post request to the server to insert user
     * @return user id
     */
    static func createUser(user: User, fbResult: [String : AnyObject]?, callback: ((id: Int, fbResult: [String : AnyObject]?) -> ())?) {
        HttpHelper.post_async([
            "mode": "insert",
            "email": user.email,
            "fb-id": user.fbId,
            "name": user.name
        ], url: "user.php") { (response) -> () in
            if let id = Int(response) {
                if callback != nil {
                    callback!(id: id, fbResult: fbResult)
                }
            }
        }
    }
    
    /**
     * Sends post request to the server to insert device token
     */
    static func createDevice(token: String) {
        if let state = AppState.getInstance() {
            HttpHelper.post_async([
                "mode": "insert",
                "token": token,
                "user-id": String(state.currentUser.id)
            ], url: "device.php", callback: nil)
        }
    }
    
    /**
     * Joins fb friends with users in db
     */
    static func getFriendIds(friends: [User], callback: ((friends: [Int: User]) -> ())?) {
        var fbIdArray = [String]()
        
        var completeFriends = [Int: User]()
        
        for friend in friends {
            fbIdArray.append(friend.fbId)
        }
        
        do {
            let fbIdJsonData = try NSJSONSerialization.dataWithJSONObject(fbIdArray, options: NSJSONWritingOptions.PrettyPrinted)
            let fbIdString = NSString(data: fbIdJsonData, encoding: NSUTF8StringEncoding)
            
            HttpHelper.post_async([
                "mode": "fb-join",
                "fb-id-array": fbIdString as! String,
                ], url: "user.php") { (response) -> () in
                    if let fbIdPairs = HttpHelper.jsonToDictionary(response) {
                        for var i = 0; i < friends.count; i++ {
                            if let id = fbIdPairs[friends[i].fbId] as? String {
                                friends[i].setId(Int(id)!)
                                completeFriends[friends[i].id] = friends[i]
                            }
                        }
                        
                        if callback != nil {
                            callback!(friends: completeFriends)
                        }
                    }
                }
        }
        catch {
            print("Couldn't get pair FB ids with user ids")
        }
    }
    
    /**
     * Gets array of basic comment data
     */
    static func getComments(note: Note, callback: (comments: [Comment]) -> ()) {
        HttpHelper.post_async([
            "mode" : "request",
            "note-id": String(note.id)
        ], url: "comment.php") { (response) -> () in
            if let commentsData = HttpHelper.jsonToDictionaryArray(response) {
                var comments = [Comment]()
                
                for commentData in commentsData {
                    let id = Int(commentData["id"] as! String)!
                    let fbId = commentData["fb_id"] as! String
                    let userId = Int(commentData["user_id"] as! String)!
                    let message = commentData["message"] as! String
                    let date = NSDate(timeIntervalSince1970: Double(commentData["date"] as! String)!)
                    
                    comments.append(Comment(id: id, userFbId: fbId, userId: userId, note: note, message: message, date: date))
                }
                
                callback(comments: comments)
            }
        }
    }
    
    /**
     * Sends post request to the server to insert note
     * @return note id
     */
    static func comment(message: String, note: Note, callback: ((comment: Comment) -> ())?) {
        if let state = AppState.getInstance() {
            HttpHelper.post_async([
                "mode": "insert",
                "message": message,
                "note-id": String(note.id),
                "user-id": String(state.currentUser.id),
                "sender-name": state.currentUser.name
            ], url: "comment.php") { (response) -> () in
                if let id = Int(response) {
                    callback?(comment: Comment(id: id, userFbId: state.currentUser.fbId, userId: state.currentUser.id, note: note, message: message, date: NSDate()))
                }
            }
        }
    }
    
    /**
     * Deletes comment from db
     */
    static func deleteComment(comment: Comment) {
        HttpHelper.post_async([
            "mode": "delete",
            "comment-id": String(comment.id)
        ], url: "comment.php", callback: nil)
    }
}