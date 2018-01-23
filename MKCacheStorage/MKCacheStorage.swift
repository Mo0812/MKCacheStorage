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
    let cacheLimit = 50
    var cacheLFU = [String: Int]()
    let storageHandler: MKCSStorageHandler?
    let indexHandler: MKCSSecondaryIndices?
    
    init(debugInfo: Bool) {
        MKCacheStorageGlobals.debugMode = debugInfo
        
        self.storageHandler = try? MKCSStorageHandler()
        self.indexHandler = try? MKCSSecondaryIndices()
        
    }
    
    private func save<T: Codable>(object: T, under identifier: String) -> Bool {
        //Saving in cache
        self.cache(object: object, under: identifier)
        
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
        if let memObj: T = self.getCacheResult(identifier: identifier) {
            return memObj
        }
        
        guard let storageHandler = self.storageHandler else { return nil }
        do {
            if let object: T = try storageHandler.get(identifier: identifier) {
                self.cache(object: object, under: identifier)
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
    
    private func isCacheFree() -> Bool {
        return self.storageItems.count <= self.cacheLimit
    }
    
    private func insertCacheEntry(for identifier: String) {
        let lfuIndex = 1
        if self.cacheLFU[identifier] == nil {
            self.cacheLFU[identifier] = lfuIndex
        }
    }
    
    private func removeCacheEntry() throws {
        let sortedArr = Array(self.cacheLFU.values).sorted(by: <)
        guard let lfu = sortedArr.first else { throw MKCacheStorageError.cacheEmpty }
        
        let filteredEntries = self.cacheLFU.filter {
            $0.value == lfu
        }
        
        guard let removedKey = filteredEntries.first?.key else { throw MKCacheStorageError.cacheError }
        
        self.storageItems[removedKey] = nil
        self.cacheLFU[removedKey] = nil
    }
    
    private func getCacheResult<T: Codable>(identifier: String) -> T? {
        let retVal = self.storageItems[identifier] as? T
        /*if let oldLFU = self.cacheLFU[identifier] {
            self.cacheLFU[identifier] = oldLFU + 1
        } else {
            self.cacheLFU[identifier] = 1
        }*/
        
        return retVal
    }
    
    private func cache<T: Codable>(object: T, under identifier: String) {
        /*if !self.isCacheFree() {
            do {
                try self.removeCacheEntry()
            } catch {
                print(error.localizedDescription)
            }
        }*/
        self.storageItems[identifier] = object
        //self.insertCacheEntry(for: identifier)
    }
    
    open func clearStorage() {
        MKCacheStorageGlobals.dispatchQueue.sync {
            self.storageItems = [String: Any]()
            try? self.storageHandler?.clearAll()
            try? self.indexHandler?.clearSecondaryIndices()
        }
    }
    
    open func close() {
        if let indexHandler = self.indexHandler {
            if let _ = try? indexHandler.saveRelations() {
                //TODO
            }
        }
    }
    
    deinit {
        self.close()
    }
}
