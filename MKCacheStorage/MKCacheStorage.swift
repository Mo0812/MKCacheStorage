//
//  MKCacheStorage.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

open class MKCacheStorage {
    
    static let shared = MKCacheStorage(debugInfo: false)
    
    var storageItems = [String: NSObject]()
    let storageHandler: MKCSStorageHandler?
    let indexHandler: MKCSSecondaryIndices?
    
    init(debugInfo: Bool) {
        MKCacheStorageGlobals.debugMode = debugInfo
        
        self.storageHandler = try? MKCSStorageHandler()
        self.indexHandler = try? MKCSSecondaryIndices()
    }
    
    private func save(object: NSObject, under identifier: String) -> Bool {
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
    
    private func save(object: NSObject, under identifier: String, with labels: [String]) -> Bool {
        let retVal = self.save(object: object, under: identifier)
        
        if let indexHandler = self.indexHandler {
            labels.forEach({ label in
                indexHandler.add(for: MKCSIndex(label), values: [identifier])
            })
        }
        
        return retVal
        
    }
    
    open func save(object: NSObject, under identifier: String, result:@escaping (Bool) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.sync {
            let retVal = self.save(object: object, under: identifier)
            result(retVal)
        }
    }
    
    open func save(object:NSObject, under identifier: String, with labels: [String], result:@escaping (Bool) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.sync {
            let retVal = self.save(object: object, under: identifier, with: labels)
            result(retVal)
        }
    }
    
    private func get(identifier: String) -> NSObject? {
        do {
            if let object = try self.storageHandler?.get(identifier: identifier) {
                self.storageItems[identifier] = object
                return object
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func get(label: String) -> [NSObject] {
        var retVal = [NSObject]()
        
        if let indexHandler = self.indexHandler {
            let indices = indexHandler.get(for: MKCSIndex(label))
            for identifier in indices {
                if let object = self.get(identifier: identifier) {
                    retVal.append(object)
                }
            }
        }
        
        return retVal
    }
    
    open func get(identifier: String, result:@escaping (NSObject?) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.async {
            let object = self.storageItems[identifier] ?? self.get(identifier: identifier)
            result(object)
        }
    }
    
    open func get(label: String, result:@escaping ([NSObject]) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.sync {
            let objects = self.get(label: label)
            result(objects)
        }
    }
    
    open func clearStorage() {
        MKCacheStorageGlobals.dispatchQueue.sync {
            self.storageItems = [String: NSObject]()
            try? self.storageHandler?.clearAll()
        }
    }
    
    open func saveRelations() {
        if let indexHandler = self.indexHandler {
            indexHandler.saveRelations()
        }
    }
    
    deinit {
        print("deinit")
    }
}
