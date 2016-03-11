//
//  Note.swift
//  lovely
//
//  Created by Max Hudson on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

class Note : NSObject {
    var id: Int = 0
    var text: String = ""
    
    func Note(text: String) {
        
    }
    
    func Note(id: Int, text: String) {
        self.id = id
        self.text = text
    }
}