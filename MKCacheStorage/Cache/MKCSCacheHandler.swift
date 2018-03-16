//
//  MKCSCacheHandler.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 23.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSCacheHandler {
    
    var storageItems = [String: Any]()
    var cacheLimit = 50
    var cacheLFU = [String: Int]()
    
    init(cacheLimit: Int = 50) {
        self.cacheLimit = cacheLimit
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
    
    public func getCacheResult<T: Codable>(identifier: String) -> T? {
        let retVal = self.storageItems[identifier] as? T
        /*if let oldLFU = self.cacheLFU[identifier] {
         self.cacheLFU[identifier] = oldLFU + 1
         } else {
         self.cacheLFU[identifier] = 1
         }*/
        
        return retVal
    }
    
    public func cache<T: Codable>(object: T, under identifier: String) {
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
    
    public func clearCache() {
        self.storageItems = [String: Any]()
        self.cacheLFU = [String: Int]()
    }
}
