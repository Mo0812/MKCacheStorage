//
//  MKCSIndex.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 14.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

class MKCSIndex: NSObject, NSCoding, NSCopying {
    
    var index: String
    
    init(_ index: String) {
        self.index = index
    }
    
    required init(_ model: MKCSIndex) {
        index = model.index
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.index, forKey: "index")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var _index = ""
        if let index = aDecoder.decodeObject(forKey: "index") as? String {
            _index = index
        }
        
        self.init(_index)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(self)
    }
}
