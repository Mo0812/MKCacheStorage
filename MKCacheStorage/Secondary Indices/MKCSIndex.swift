//
//  MKCSIndex.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 14.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

struct MKCSIndex: Hashable {
    var hashValue: Int {
        return index.hashValue
    }
    var index: String
    
    init(_ index: String) {
        self.index = index
    }
    
    static func ==(lhs: MKCSIndex, rhs: MKCSIndex) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
