//
//  Absen.swift
//  Sunday School
//
//  Created by David Gunawan on 10/5/16.
//  Copyright © 2016 Davidgun. All rights reserved.
//

import UIKit

class Absen {
    
    private var _name: String!
    private var _grade: String!
    private var _ibadah: String!
    private var _discKey: String!
    
    var name: String {
        
        return _name
    }
    
    var grade: String {
        
        return _grade
    }
    
    var ibadah: String {
        
        return _ibadah
    }
    
    var discKey: String {
        return _discKey
    }
    
    init(name: String, grade: String, ibadah: String) {
        
        self._name = name
        self._grade = grade
        self._ibadah = ibadah
        
    }
    
    init(discKey: String, discData: Dictionary<String, AnyObject>) {
        self._discKey = discKey
        
        if let name = discData["name"] as? String {
            self._name = name
        }
        
        if let grade = discData["class"] as? String {
            self._grade = grade
        }
        
        if let ibadah = discData["ibadah"] as? String {
            self._ibadah = ibadah
        }
        
    }
    
}
