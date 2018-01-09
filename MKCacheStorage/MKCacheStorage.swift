//
//  MKCacheStorage.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

open class MKCacheStorage {
    
    var storageItems = [String: NSObject]()
    
    let storageHandler: MKCSStorageHandler
    
    init(localPath: String, debugInfo: Bool) {
        MKCacheStorageOptions.debugMode = debugInfo
        
        self.storageHandler = MKCSStorageHandler(localPath: localPath)
    }
    
    open func save(object: NSObject, under identifier: String) -> Bool {
        self.storageItems[identifier] = object
        
        do {
            return try self.storageHandler.save(storage: self.storageItems)
        } catch MKCSStorageError.invalidPath {
            print("Pathmapping wrong")
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    open func get(identifier: String) -> NSObject? {
        guard let object = self.storageItems[identifier] else { return nil }
        return object
    }
}
