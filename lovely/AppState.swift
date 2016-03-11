//
//  AppState.swift
//  lovely
//
//  Created by Francis Yuen on 3/10/16.
//  Copyright © 2016 DweebsRUs. All rights reserved.
//

import Foundation

class AppState {
    private var loggedIn : Bool
    private var currentUser : User
    static var state : AppState?
    
    static func getInstance() -> AppState {
        if state == nil {
            state = AppState()
        }
        
        return state!
    }
    
    private init() {
        // Check if user is authenticated
        
    }
    
    func isAuthenticated() -> Bool {
        return true
    }

}