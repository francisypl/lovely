//
//  User.swift
//  lovely
//
//  Created by Max Hudson on 3/11/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import UIKit

class User {
    
    private(set) var id: Int
    private(set) var fbId: String
    private(set) var name: String
    private(set) var email: String
    
    /**
    * For use by AppState.getUserById(id: Int)
    */
    init(id: Int) {
        self.id = id
        
        self.email = ""
        self.fbId = ""
        self.name = ""
    }
    
    init(id: Int, fbId: String, name: String, email: String) {
        self.id = id
        self.fbId = fbId
        self.name = name
        self.email = email
    }
}