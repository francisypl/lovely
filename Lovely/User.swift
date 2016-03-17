//
//  User.swift
//  lovely
//
//  Created by Max Hudson on 3/11/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class User {
    
    private(set) var id: Int = 0
    internal var fbId: String = ""
    private(set) var name: String = "Name"
    private(set) var email: String = ""
    private(set) var image: UIImage = UIImage()
    
    /**
    * For use by AppState.getUserById(id: Int)
    */
    init(id: Int) {
        self.id = id
    }
    
    /**
     * For user insertion
     */
    init(fbId: String, name: String, email: String, image: UIImage) {
        self.email = email
        self.fbId = fbId
        self.name = name
        self.image = image
    }
    
    /**
     * Generic
     */
    init(id: Int, fbId: String, name: String, email: String, image: UIImage) {
        self.id = id
        self.fbId = fbId
        self.name = name
        self.email = email
        self.image = image
    }
    
    /**
     * Inserts user into db
     */
    func insertIntoDb() {
        DatabaseWrapper.createUser(self, fbResult: nil) { (id, fbResult) -> () in
            self.id = id
        }
    }
    
    /**
     * Sets Id
     */
    func setId(id: Int) {
        self.id = id
    }
}