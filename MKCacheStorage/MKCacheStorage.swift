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
    
    open func save(object: NSObject, under identifier: String) {
        self.storageHandler.save(object: object)
    }
    
    open func get(identifier: String) -> NSObject? {
        guard let object = self.storageHandler.get(identifier: identifier) as? NSObject else { return nil }
        return object
    }
}
