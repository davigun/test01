//
//  DataService.swift
//  Sunday School
//
//  Created by David Gunawan on 8/31/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    // DB refereences
    private var _REF_BASE = DB_BASE
    private var _REF_DISCIPLES = DB_BASE.child("disciples")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_SCHEDULES = DB_BASE.child("schedules")
    
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_DISCIPLES: FIRDatabaseReference {
        return _REF_DISCIPLES
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_SCHEDULES: FIRDatabaseReference {
        return _REF_SCHEDULES
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
}
