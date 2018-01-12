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
    
    open func save(object: NSObject, under identifier: String, result:@escaping (Bool) -> ()) {
        MKCacheStorageOptions.dispatchQueue.async {
            //Saving in dict
            self.storageItems[identifier] = object
            
            //Saving on disk
            guard let storageHandler = self.storageHandler else {
                DispatchQueue.main.sync {
                    result(false)
                }
                return
            }
            do {
                let saving = try storageHandler.save(object: object, under: identifier)
                DispatchQueue.main.sync {
                    result(saving)
                }
                return
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.sync {
                    result(false)
                }
                return
            }
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
    
    open func get(identifier: String, result:@escaping (NSObject?) -> ()) {
        MKCacheStorageOptions.dispatchQueue.async {
            //Get object from memory
            if let object = self.storageItems[identifier] {
                DispatchQueue.main.async {
                    result(object)
                }
                return
            }
            
            //Else get object from disk
            guard let storageHandler = self.storageHandler else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            do {
                if let object = try storageHandler.get(identifier: identifier) {
                    self.storageItems[identifier] = object
                    DispatchQueue.main.async {
                        result(object)
                    }
                    return
                }
            } catch {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                result(nil)
            }
        }
    }
    
    open func clearStorage() {
        MKCacheStorageOptions.dispatchQueue.sync {
            self.storageItems = [String: NSObject]()
            try? self.storageHandler?.clearAll()
        }
    }
    
    deinit {
        print("deinit")
    }
}
