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
    
    let storageHandler: MKCSStorageHandler?
    let indexHandler: MKCSSecondaryIndices?
    let cacheHandler: MKCSCacheHandler?
    
    init(debugInfo: Bool) {
        MKCacheStorageGlobals.debugMode = debugInfo
        
        self.storageHandler = try? MKCSStorageHandler()
        self.indexHandler = try? MKCSSecondaryIndices()
        self.cacheHandler = MKCSCacheHandler()
        
    }
    
    private func save<T: Codable>(object: T, under identifier: String) -> Bool {
        //Saving in cache
        self.cacheHandler?.cache(object: object, under: identifier)
        
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
        if let memObj: T = self.cacheHandler?.getCacheResult(identifier: identifier) {
            return memObj
        }
        
        guard let storageHandler = self.storageHandler else { return nil }
        do {
            if let object: T = try storageHandler.get(identifier: identifier) {
                self.cacheHandler?.cache(object: object, under: identifier)
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
                if let obj: T = self.get(identifier: identifier) {
                    retVal.append(obj)
                }
            }
        }
        
        return retVal
    }
    
    open func get<T: Codable>(identifier: String, result:@escaping (T?) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.async {
            let obj: T? = self.get(identifier: identifier)
            result(obj)
        }
    }
    
    open func get<T: Codable>(label: String, result:@escaping ([T]) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.async {
            let objects: [T] = self.get(label: label)
            result(objects)
        }
    }
        
    open func clearStorage() {
        MKCacheStorageGlobals.dispatchQueue.sync {
            try? self.storageHandler?.clearAll()
            try? self.indexHandler?.clearSecondaryIndices()
            self.cacheHandler?.clearCache()
        }
    }
    
    open func close() {
        guard let indexHandler = self.indexHandler else { return }
        do {
            try indexHandler.saveRelations()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    deinit {
        self.close()
    }
}
