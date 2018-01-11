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
    let storageHandler: MKCSStorageHandler?
    
    init(debugInfo: Bool) {
        MKCacheStorageOptions.debugMode = debugInfo
        
        do {
            self.storageHandler = try MKCSStorageHandler()
        } catch {
            self.storageHandler = nil
            print(error.localizedDescription)
        }
    }
    
    open func save(object: NSObject, under identifier: String) -> Bool {
        //Saving in dict
        self.storageItems[identifier] = object
        
        //Saving on disk
        guard let storageHandler = self.storageHandler else { return false }
        do {
            return try storageHandler.save(object: object, under: identifier)
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    open func get(identifier: String) -> NSObject? {
        //Get object from memory
        if let object = self.storageItems[identifier] {
            return object
        }
        
        //Else get object from disk
        guard let storageHandler = self.storageHandler else { return nil }
        do {
            if let object = try storageHandler.get(identifier: identifier) {
                self.storageItems[identifier] = object
                return object
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    open func clearStorage() {
        self.storageItems = [String: NSObject]()
        try? self.storageHandler?.clearAll()
    }
    
    deinit {
        print("deinit")
    }
}
