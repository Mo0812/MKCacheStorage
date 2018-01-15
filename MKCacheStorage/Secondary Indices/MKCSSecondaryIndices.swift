//
//  MKCSSecondaryIndices.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 14.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSSecondaryIndices {
    
    private var relations = [MKCSIndex: Set<String>]()
    private var path: URL? {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return url?.appendingPathComponent("MKCSDataSI", isDirectory: false)
    }
    
    init() throws {
        guard let path = self.path else { throw MKCSStorageError.invalidPath }
        
        if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: path.path) as? [MKCSIndex: Set<String>] {
            self.relations = dict
            print("loading si...")
            print(path.path)
        } else {
            throw MKCSStorageError.secondaryIndexNotFound
        }
    }
   
    func add(for index: MKCSIndex, values: [String]) {
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
    
    func get(for index: MKCSIndex) -> [String] {
        if let values = self.relations[index] {
            return Array(values)
        }
        
        return [String]()
    }
    
    func have(index: MKCSIndex) -> Bool {
        if self.relations.index(forKey: index) != nil {
            return true
        } else {
            return false
        }
    }
    
    func remove(value: String, from index: MKCSIndex) -> Bool {
        if let values = self.relations[index] {
            var set = values
            set.remove(value)
            self.relations[index] = values
            return true
        } else {
            return false
        }
    }
    
    func saveRelations() {
        if let path = self.path {
            print(NSKeyedArchiver.archiveRootObject(self.relations, toFile: path.path))
            print("saving si")
        }
    }
    
    deinit {
        self.saveRelations()
    }
    
}
