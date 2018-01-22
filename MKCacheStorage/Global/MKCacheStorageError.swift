//
//  MKCacheStorageError.swift
//  MKCacheStorage
//
//  Created by Moritz Kanzler on 15.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import Foundation

enum MKCacheStorageError: Error {
    case invalidPath
    case storageNotFound
    case secondaryIndexNotFound
    case wrongObjectFormat
    case cacheEmpty
    case cacheError
}
