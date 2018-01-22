//
//  MKCSSecondaryIndices.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 14.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSSecondaryIndices {
    
    private let cacheSize: Int = 100
    private var relations = [String: Set<String>]()
    private var path: URL? {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return url?.appendingPathComponent("MKCSDataSI", isDirectory: false)
    }
    
    init() throws {
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        
        if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: path.path) as? [String: Set<String>] {
            self.relations = dict
        }
    }
   
    func add(for index: String, values: [String]) {
        if let savedValues = self.relations[index] {
            var set = savedValues
            for value in values {
                set.insert(value)
            }
            self.relations[index] = set
        } else {
            var set = Set<String>()
            set = set.union(values)
            self.relations[index] = set
        }
    }
    
    func get(for index: String) -> [String] {
        if let values = self.relations[index] {
            return Array(values)
        }
        
        return [String]()
    }
    
    func have(index: String) -> Bool {
        if self.relations.index(forKey: index) != nil {
            return true
        } else {
            return false
        }
    }
    
    func remove(value: String, from index: String) -> Bool {
        if let values = self.relations[index] {
            var set = values
            set.remove(value)
            self.relations[index] = values
            return true
        } else {
            return false
        }
    }
    
    func saveRelations() throws -> Bool {
        if let path = self.path {
            return NSKeyedArchiver.archiveRootObject(self.relations, toFile: path.path)
        } else {
            throw MKCacheStorageError.invalidPath
        }
    }
    
    func clearSecondaryIndices() throws {
        self.relations = [String: Set<String>]()
        
        let manager = FileManager.default
        guard let path = self.path else { throw MKCacheStorageError.invalidPath }
        
        if manager.fileExists(atPath: path.path) {
            do {
                try manager.removeItem(atPath: path.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    deinit {
        if let success = try? self.saveRelations() {
            if !success {
                //TODO
            }
        }
    }
    
}
