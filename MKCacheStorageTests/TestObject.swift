//
//  TestObjectJSON.swift
//  MKCacheStorageTests
//
//  Created by Moritz Kanzler on 21.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation
import MKCacheStorage

class TestObject: Codable {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
}
