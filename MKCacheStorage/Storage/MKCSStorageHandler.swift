//
//  MKCSStorageHandler.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSStorageHandler {
    
    init() {
        
    }
    
    public func save(object: NSObject) {
        NSKeyedArchiver.archiveRootObject(object, toFile: "archive/objects")
    }
    
    public func get(identifier: String) -> NSObject? {
        guard let object = NSKeyedUnarchiver.unarchiveObject(withFile: "archive/objects") as? NSObject else { return nil }
        return object
    }
}
