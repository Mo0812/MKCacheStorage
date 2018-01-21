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
    
    var storageItems = [String: Any]()
    let storageHandler: MKCSJSONHandler?
    let indexHandler: MKCSSecondaryIndices?
    
    init(debugInfo: Bool) {
        MKCacheStorageGlobals.debugMode = debugInfo
        
        self.storageHandler = try? MKCSJSONHandler()
        self.indexHandler = try? MKCSSecondaryIndices()
    }
    
    private func save<T: Codable>(object: T, under identifier: String) -> Bool {
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
    
    private func save<T: Codable>(object: T, under identifier: String, with labels: [String]) -> Bool {
        let retVal = self.save(object: object, under: identifier)
        
        if let indexHandler = self.indexHandler {
            labels.forEach({ label in
                indexHandler.add(for: String(label), values: [identifier])
            })
        }
        
        return retVal
        
    }
    
    open func save<T: Codable>(object: T, under identifier: String, result:@escaping (Bool) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.sync {
            let retVal = self.save(object: object, under: identifier)
            result(retVal)
        }
    }
    
    open func save<T: Codable>(object: T, under identifier: String, with labels: [String], result:@escaping (Bool) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.sync {
            let retVal = self.save(object: object, under: identifier, with: labels)
            result(retVal)
        }
    }
    
    private func get<T: Codable>(identifier: String) -> T? {
        do {
            if let object: T = try self.storageHandler?.get(identifier: identifier) {
                self.storageItems[identifier] = object
                return object
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func get<T: Codable>(label: String) -> [T] {
        var retVal = [T]()
        
        if let indexHandler = self.indexHandler {
            let indices = indexHandler.get(for: String(label))
            for identifier in indices {
                if let object: T = self.get(identifier: identifier) {
                    retVal.append(object)
                }
            }
        }
        
        return retVal
    }
    
    open func get<T: Codable>(identifier: String, result:@escaping (T?) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.async {
            var retVal: T? = nil
            if let memObj = self.storageItems[identifier] as? T {
                retVal = memObj
            } else if let storageObj: T = self.get(identifier: identifier) {
                retVal = storageObj
            }
            
            //let object: T = self.storageItems[identifier] ?? self.get(identifier: identifier) as? T
            result(retVal)
        }
    }
    
    open func get<T: Codable>(label: String, result:@escaping ([T]) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.sync {
            let objects: [T] = self.get(label: label)
            result(objects)
        }
    }
    
    open func clearStorage() {
        MKCacheStorageGlobals.dispatchQueue.sync {
            self.storageItems = [String: MKCSModel]()
            try? self.storageHandler?.clearAll()
            try? self.indexHandler?.clearSecondaryIndices()
        }
    }
    
    open func saveRelations() {
        if let indexHandler = self.indexHandler {
            if let success = try? indexHandler.saveRelations() {
                //TODO
            }
        }
    }
    
    deinit {
    }
}
