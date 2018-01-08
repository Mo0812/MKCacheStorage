//
//  TestObject.swift
//  MKCacheStorageTests
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class TestObject: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.age, forKey: "age")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var _name = ""
        var _age = 0
        
        if let name = aDecoder.decodeObject(forKey: "name") as? String {
            _name = name
        }
        if let age = aDecoder.decodeObject(forKey: "age") as? Int {
            _age = age
        }
        self.init(name: _name, age: _age)
    }
    
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
