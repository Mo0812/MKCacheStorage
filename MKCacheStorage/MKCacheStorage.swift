//
//  MKCacheStorage.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

open class MKCacheStorage {
    
    let storageHandler: MKCSStorageHandler
    
    init(debugInfo: Bool) {
        MKCacheStorageOptions.debugMode = debugInfo
        
        self.storageHandler = MKCSStorageHandler()
    }
    
    open func save(object: NSObject, under identifier: String) throws -> Bool {
        return try self.storageHandler.save(object: object)
    }
    
    open func get(identifier: String) throws -> NSObject? {
        let savedObject = try self.storageHandler.get(identifier: identifier)
        
        guard let object = savedObject as? NSObject else { return nil }
        return object
    }
}
