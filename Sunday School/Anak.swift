//
//  Anak.swift
//  Sunday School
//
//  Created by David Gunawan on 8/11/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit

class Anak {
    
    private var _name: String!
    private var _grade: String!
    private var _address: String!
    private var _birthday: String!
    private var _gender: String!
    private var _origin: String!
    private var _phone: String!
    private var _classCapacity: Int!
    private var _discKey: String!
    
    var name: String {
        
        return _name
    }
    
    var grade: String {
        
        return _grade
    }
    
    var address: String {
        
        return _address
    }
    
    var birthday: String {
        
        return _birthday
    }
    
    var gender: String {
        
        return _gender
    }
    
    var origin: String {
        
        return _origin
    }
    
    var phone: String {
        
        return _phone
    }
    
    var discKey: String {
        return _discKey
    }
    
    init(name: String, grade: String, address: String, birthday: String, gender: String, origin: String, phone: String) {
        
        self._name = name
        self._grade = grade
        self._address = address
        self._birthday = birthday
        self._gender = gender
        self._origin = origin
        self._phone = phone
        
    }
    
    init(discKey: String, discData: Dictionary<String, AnyObject>) {
        self._discKey = discKey
        
        if let name = discData["name"] as? String {
            self._name = name
        }
        
        if let grade = discData["class"] as? String {
            self._grade = grade
        }
        
        if let address = discData["address"] as? String {
            self._address = address
        }
        
        if let birthday = discData["birthday"] as? String {
            self._birthday = birthday
        }
        
        if let gender = discData["gender"] as? String {
            self._gender = gender
        }
        
        if let origin = discData["origin"] as? String {
            self._origin = origin
        }
        
        if let phone = discData["phone"] as? String {
            self._phone = phone
        }        
        
    }
    
}
