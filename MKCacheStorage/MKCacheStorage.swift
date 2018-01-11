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
        
        do {
            try self.initStorage()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func initStorage() throws {
        do {
            if let storageItems = try self.storageHandler.get() {
                self.storageItems = storageItems
            } else {
                throw MKCSStorageError.storageNotFound
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    open func save(object: NSObject, under identifier: String) -> Bool {
        self.storageItems[identifier] = object
        return true
    }
    
    open func get(identifier: String) -> NSObject? {
        guard let object = self.storageItems[identifier] else { return nil }
        return object
    }
    
    deinit {
        print("deinit")
        do {
            if try self.storageHandler.save(storage: self.storageItems) {
                print("Data saved to disk")
            } else {
                print("Data saving incomplete")
            }
        } catch MKCSStorageError.invalidPath {
            print("Pathmapping wrong")
        } catch {
            print(error.localizedDescription)
        }
    }
}
