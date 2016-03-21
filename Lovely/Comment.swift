//
//  Comment.swift
//  Lovely
//
//  Created by Max Hudson on 3/20/16.
//  Copyright © 2016 Max Hudson. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class Comment {
    var id : Int
    
    private(set) var user : User?
    private(set) var userFbId : String
    private(set) var userId : Int
    private(set) var message : String
    private(set) var note : Note
    private(set) var date : NSDate
    
    private var loaded = false
    
    init(id: Int, userFbId: String, userId: Int, note: Note, message: String, date: NSDate) {
        self.id = id
        self.message = message
        self.note = note
        self.userFbId = userFbId
        self.userId = userId
        self.date = date
    }
    
    func joinFb(callback: (() -> ())?) {
        if !loaded {
            if let state = AppState.getInstance() {
                if userId == state.currentUser.id {
                    user = state.currentUser
                    loaded = true
                    
                    callback?()
                }
                else if let friend = state.friendsList[userId] {
                    user = friend
                    loaded = true
                    
                    callback?()
                }
                else {
                    let params = ["fields": "name, picture.width(200).height(200)"]
                    let request = FBSDKGraphRequest(graphPath: "/v2.5/" + userFbId, parameters: params, HTTPMethod: "GET")
                    
                    request.startWithCompletionHandler({ (connection, result, error) -> Void in
                        self.loaded = true
                        
                        if let res = result as? [String : AnyObject] {
                            let pictureData = (res["picture"] as! NSDictionary)["data"] as! NSDictionary
                            let profilePictureUrl = NSURL(string: pictureData["url"] as! String)
                            let profilePictureUrlData = NSData(contentsOfURL: profilePictureUrl!)
                            
                            if let profilePicture = UIImage(data: profilePictureUrlData!) {
                                self.user = User(id: self.userId, fbId: self.userFbId, name: res["name"] as! String, email: "", image: profilePicture)
                                
                                callback?()
                            }
                        }
                    })
                }
            }
        }
        else {
            callback?()
        }
    }
}