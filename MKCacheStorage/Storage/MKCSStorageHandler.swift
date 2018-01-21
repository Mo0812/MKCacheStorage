//
//  MKCSJSONHandler.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 17.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSStorageHandler {
    var path: URL? {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return url?.appendingPathComponent("MKCSJSON", isDirectory: true)
    }
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
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
    
    public func save<T: Codable>(object: T, under identifier: String) throws -> Bool {
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        let objectPath = path.appendingPathComponent(identifier)
        
        if let encodedJSON = try? self.encoder.encode(object) {
            //save to disk under identifier
            do {
                try encodedJSON.write(to: objectPath)
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        }
        
        return false
    }
    
    public func get<T: Codable>(identifier: String) throws -> T? {
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        let objectPath = path.appendingPathComponent(identifier)
        
        //get object from disk with path
        guard let data = try? Data(contentsOf: objectPath) else { return nil }
        //get json to object serialization
        guard let object = try? self.decoder.decode(T.self, from: data) else { return nil }
        
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
