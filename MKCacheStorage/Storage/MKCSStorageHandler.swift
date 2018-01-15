//
//  MKCSStorageHandler.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSStorageHandler {
        
    var path: URL? {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return url?.appendingPathComponent("MKCSData", isDirectory: true)
    }
    
    init() throws {
        try self.initStorageFolder()
    }
    
    private func initStorageFolder() throws {
        let manager = FileManager.default
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        
        if !manager.fileExists(atPath: path.path) {
            do {
                try manager.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error.localizedDescription)
                throw MKCacheStorageError.storageNotFound
            }
        }
    }
    
    public func save(object: NSObject, under identifier: String) throws -> Bool {
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        let objectPath = path.appendingPathComponent(identifier)
        
        return NSKeyedArchiver.archiveRootObject(object, toFile: objectPath.path)
    }
    
    public func get(identifier: String) throws -> NSObject? {
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        let objectPath = path.appendingPathComponent(identifier).path
        
        let o = NSKeyedUnarchiver.unarchiveObject(withFile: objectPath)
        guard let object = o as? NSObject else {
            return nil
        }
        return object
    }
    
    public func clearAll() throws {
        let manager = FileManager.default
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        
        if manager.fileExists(atPath: path.path) {
            do {
                let files = try manager.contentsOfDirectory(atPath: path.path)
                for file in files {
                    try manager.removeItem(at: path.appendingPathComponent(file))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
