//
//  MKCSObject.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSObject: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.object, forKey: "object")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let identifier = aDecoder.decodeObject(forKey: "identifier") as? String, let object = aDecoder.decodeObject(forKey: "object") as? NSObject else { return nil }
        self.init(identifier: identifier, object: object)
    }
    
    var identifier: String
    var object: NSObject
    
    init(identifier: String, object: NSObject) {
        self.identifier = identifier
        self.object = object
    }
}
