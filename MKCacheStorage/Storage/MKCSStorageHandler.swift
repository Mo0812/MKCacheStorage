//
//  MKCSStorageHandler.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

enum MKCSStorageError: Error {
    case invalidPath
    case saveFailure
    case fileNotFound
}

class MKCSStorageHandler {
    
    var path: String? {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return url?.appendingPathComponent("MKCSData").path
    }
    
    init() {
        
    }
    
    public func save(object: NSObject) throws -> Bool {
        guard let path = self.path else { throw MKCSStorageError.invalidPath }
        return NSKeyedArchiver.archiveRootObject(object, toFile: path)
    }
    
    public func get(identifier: String) throws -> NSObject? {
        guard let path = self.path else { throw MKCSStorageError.invalidPath }
        
        let o = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        guard let object = o as? NSObject else {
            return nil
        }
        return object
    }
}
