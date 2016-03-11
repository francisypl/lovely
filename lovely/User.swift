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
    private(set) var fbId: Int
    private(set) var name: String
    private(set) var email: String
    private(set) var image: UIImage
    
    init(id: Int) {
        self.id = id
        
        self.email = ""
        self.fbId = -1
        self.name = ""
        self.image = UIImage()
    }
    
    init(id: Int, fbId: Int, name: String, email: String, image: UIImage) {
        self.id = id
        self.fbId = fbId
        self.name = name
        self.email = email
        self.image = image
    }
}