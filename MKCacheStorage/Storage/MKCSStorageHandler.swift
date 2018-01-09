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
    case storageNotFound
}

class MKCSStorageHandler {
        
    var localPath = ""
    var path: String? {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return url?.appendingPathComponent("MKCSData").appendingPathComponent(self.localPath).path
    }
    
    init(localPath: String) {
        self.localPath = localPath
    }
    
    public func save(storage: [String: NSObject]) throws -> Bool {
        guard let path = self.path else { throw MKCSStorageError.invalidPath }
        return NSKeyedArchiver.archiveRootObject(storage, toFile: path)
    }
    
    public func get() throws -> [String: NSObject]? {
        guard let path = self.path else { throw MKCSStorageError.invalidPath }
        
        let s = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        guard let storage = s as? [String: NSObject] else {
            return nil
        }
        return storage
    }
}
