//
//  MKCacheStorageOptions.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

struct MKCacheStorageOptions {
    
    static var debugMode = false
    static let dispatchQueue = DispatchQueue(label: "de.mnoritzkanzler.mkcachestorage", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: .global()) //DispatchQueue.global(qos: .userInitiated)
    
}
