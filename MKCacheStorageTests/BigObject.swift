//
//  BigObject.swift
//  MKCacheStorageTests
//
//  Created by Moritz Kanzler on 22.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation
import UIKit

class BigObject: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case img
    }
    
    var name: String
    var img: UIImage
    
    required init(name: String, image: UIImage) {
        self.name = name
        self.img = image
    }
    
    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let _name = try values.decode(String.self, forKey: .name)
        
        let data = try values.decode(Data.self, forKey: .img)
        let _img = UIImage(data: data)!
        
        self.init(name: _name, image: _img)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        
        let data = UIImageJPEGRepresentation(self.img, 1.0)
        try container.encode(data, forKey: .img)
    }
    
}
