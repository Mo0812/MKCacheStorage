//
//  MKCacheStorage.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

open class MKCacheStorage {
    
    static let sharedInstance = MKCacheStorage(debugInfo: false)
    
    var storageItems = [String: NSObject]()
    let storageHandler: MKCSStorageHandler?
    let indexHandler: MKCSSecondaryIndices?
    
    init(debugInfo: Bool) {
        MKCacheStorageGlobals.debugMode = debugInfo
        
        do {
            self.storageHandler = try MKCSStorageHandler()
        } catch {
            self.storageHandler = nil
            print(error.localizedDescription)
        }
        
        self.indexHandler = MKCSSecondaryIndices()
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
        MKCacheStorageGlobals.dispatchQueue.sync {
            //Saving in dict
            self.storageItems[identifier] = object
        }
        MKCacheStorageGlobals.dispatchQueue.async {
            //Saving on disk
            guard let storageHandler = self.storageHandler else {
                DispatchQueue.main.async {
                    result(false)
                }
                return
            }
            do {
                let saving = try storageHandler.save(object: object, under: identifier)
                DispatchQueue.main.async {
                    result(saving)
                }
                return
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    result(false)
                }
                return
            }
        }
    }
    
    open func save(object:NSObject, under identifier: String, with label: String, result:@escaping (Bool) -> ()) {
        self.save(object: object, under: identifier) { (success) in
            MKCacheStorageGlobals.dispatchQueue.sync {
                guard let indexHandler = self.indexHandler else {
                    DispatchQueue.main.async {
                        result(false)
                    }
                    return
                }
                
                if success {
                    indexHandler.add(for: MKCSIndex(label), values: [identifier])
                    DispatchQueue.main.async {
                        result(true)
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        result(false)
                    }
                    return
                }
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
        MKCacheStorageGlobals.dispatchQueue.async {
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
    
    open func get(label: String, result:@escaping ([NSObject]) -> ()) {
        MKCacheStorageGlobals.dispatchQueue.async {
            var objects = [NSObject]()
            
            guard let indexHandler = self.indexHandler else {
                DispatchQueue.main.async {
                    result(objects)
                }
                return
            }
            
            let indices = indexHandler.get(for: MKCSIndex(label))
            indices.forEach { (index) in
                if let val = self.get(identifier: index) {
                    objects.append(val)
                }
            }
            DispatchQueue.main.async {
                result(objects)
            }
            return
        }
    }
    
    open func clearStorage() {
        MKCacheStorageGlobals.dispatchQueue.sync {
            self.storageItems = [String: NSObject]()
            try? self.storageHandler?.clearAll()
        }
    }
    
    deinit {
        print("deinit")
    }
}
