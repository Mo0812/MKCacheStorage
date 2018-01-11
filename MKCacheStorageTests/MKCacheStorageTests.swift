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
    var max: Int = 10000
    
    override func setUp() {
        super.setUp()
        
        self.storage = MKCacheStorage(debugInfo: false)
        for i in 1...self.max {
            let testObj = TestObject(name: "name" + String(i), age: i)
            self.objContainer[i] = testObj
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.storage = nil
        super.tearDown()
    }
    
    func t1estInitStorage() {
        for i in 1...self.max {
            let testObj = TestObject(name: "name" + String(i), age: i)
            
            if self.storage!.save(object: testObj, under: "id" + String(i)) {
            } else {
                print("Failure in saving")
            }
        }
    }
    
    func testGetObjectOnMemory() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        walkThroughObjects(storage: self.storage!)
        
    }
    
    func testGetObjectAsync() {
        var expecArr = [XCTestExpectation]()
        
        for(id, obj) in self.objContainer {
            let expec = expectation(description: "Async get")
            expecArr.append(expec)
            self.storage?.get(identifier: "id" + String(id), result: { object in
                if let retrievedObj = object as? TestObject {
                    if obj.name == retrievedObj.name && obj.age == retrievedObj.age {
                        expec.fulfill()
                    }
                }
            })
        }
        
        wait(for: expecArr, timeout: 10)
    }
    
    func testGetObjectOnDisk() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        self.storage = nil
        let storage = MKCacheStorage(debugInfo: false)
        walkThroughObjects(storage: storage)
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
    
    func testPerformanceOnAsync() {
        self.measure {
            testGetObjectAsync()
        }
    }
    
    func walkThroughObjects(storage: MKCacheStorage) {
        for (id, obj) in self.objContainer {
            let storedObj = storage.get(identifier: "id" + String(id))
            if let retrievedObj = storedObj as? TestObject {
                XCTAssert(obj.name == retrievedObj.name)
                XCTAssert(obj.age == retrievedObj.age)
            }
            else {
                XCTFail()
            }
        }
    }
    
}
