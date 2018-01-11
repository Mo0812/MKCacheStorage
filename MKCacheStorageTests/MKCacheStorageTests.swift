//
//  MKCacheStorageTests.swift
//  MKCacheStorageTests
//
//  Created by Moritz Kanzler on 02.01.18.
//  Copyright © 2018 Moritz Kanzler. All rights reserved.
//

import XCTest
@testable import MKCacheStorage

class MKCacheStorageTests: XCTestCase {
    
    var objContainer: [Int: TestObject] = [Int: TestObject]()
    var storage: MKCacheStorage?
    
    override func setUp() {
        super.setUp()
        
        self.storage = MKCacheStorage(debugInfo: false)
        
        if objContainer.isEmpty {
            for i in 1...100 {
                let testObj = TestObject(name: self.randomString(length: 10), age: Int(arc4random_uniform(100)))
                self.objContainer[i] = testObj
                
                if self.storage!.save(object: testObj, under: "id" + String(i)) {
                    print("Saving successfull")
                } else {
                    print("Failure in saving")
                }
            }
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.storage?.clearStorage()
        self.storage = nil
        super.tearDown()
    }
    
    func testGetObjectOnMemory() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        for (id, obj) in self.objContainer {
            let storedObj = self.storage!.get(identifier: "id" + String(id))
            if let retrievedObj = storedObj as? TestObject {
                print(retrievedObj.name)
                print(retrievedObj.age)
                XCTAssert(obj.name == retrievedObj.name)
                XCTAssert(obj.age == retrievedObj.age)
            } else {
                XCTFail()
            }
        }
        
    }
    
    func testGetObjectOnDisk() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        self.storage = nil
        let storage = MKCacheStorage(debugInfo: false)
        
        for (id, obj) in self.objContainer {
            let storedObj = storage.get(identifier: "id" + String(id))
            if let retrievedObj = storedObj as? TestObject {
                print(retrievedObj.name)
                print(retrievedObj.age)
                XCTAssert(obj.name == retrievedObj.name)
                XCTAssert(obj.age == retrievedObj.age)
            }
            else {
                XCTFail()
            }
        }
        
    }
    
    func testPerformanceOnMemory() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            testGetObjectOnMemory()
        }
    }
    
    func testPerformanceOnDisk() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            testGetObjectOnDisk()
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
