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
    var storage: MKCacheStorage?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let testObj = TestObject(name: "Michi Mustermann", age: 32)
        objContainer.append(testObj)
        
        self.storage = MKCacheStorage(debugInfo: false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expec = expectation(description: "Object save and retrieve")
        
        for obj in self.objContainer {
            do {
                if try self.storage!.save(object: obj, under: "id1") {
                    print("Saving successfull")
                } else {
                    print("Failure in saving")
                }
            } catch {
                print("Pathmapping wrong")
            }
            
            do {
                let storedObj = try self.storage!.get(identifier: "id1")
                if let retrievedObj = storedObj as? TestObject {
                    print(retrievedObj.name)
                    print(retrievedObj.age)
                    XCTAssertTrue(obj.name == retrievedObj.name, "No match")
                    expec.fulfill()
                }
            } catch {
                print("Pathmapping wrong")
            }
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
