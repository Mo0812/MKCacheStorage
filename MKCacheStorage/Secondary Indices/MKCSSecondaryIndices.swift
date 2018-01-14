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
   
    func add(for index: MKCSIndex, values: [String]) {
        if let values = self.relations[index] {
            var set = values
            values.forEach({ (value) in
                set.insert(value)
            })
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
    
}
