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
    
    var objContainer: [TestObject] = [TestObject]()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let testObj = TestObject(name: "Michi Mustermann", age: 32)
        objContainer.append(testObj)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSavingObjectOnMemory() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let storage = MKCacheStorage(localPath: "", debugInfo: false)

        for obj in self.objContainer {
            if storage.save(object: obj, under: "id1") {
                print("Saving successfull")
            } else {
                print("Failure in saving")
            }
            
            let storedObj = storage.get(identifier: "id1")
            if let retrievedObj = storedObj as? TestObject {
                print(retrievedObj.name)
                print(retrievedObj.age)
                XCTAssert(obj.name == retrievedObj.name)
                XCTAssert(obj.age == retrievedObj.age)
            }
        }
        
    }
    
    func testSavingObjectOnDisk() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let storage = MKCacheStorage(localPath: "", debugInfo: false)
        
        for obj in self.objContainer {
            let storedObj = storage.get(identifier: "id1")
            if let retrievedObj = storedObj as? TestObject {
                print(retrievedObj.name)
                print(retrievedObj.age)
                XCTAssert(obj.name == retrievedObj.name)
                XCTAssert(obj.age == retrievedObj.age)
            }
        }
        
    }
    
    func testWrongPath() {
        let storageWithWrongPath = MKCacheStorage(localPath: "wrong", debugInfo: false)
        let wrongObj = storageWithWrongPath.get(identifier: "id2")
        XCTAssert(wrongObj == nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
