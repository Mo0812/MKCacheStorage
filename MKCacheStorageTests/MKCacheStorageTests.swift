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
    var storage: MKCacheStorage = MKCacheStorage.shared
    var max: Int = 100
    
    override func setUp() {
        super.setUp()
        
        for i in 1...self.max {
            let testObj = TestObject(name: "name" + String(i), age: i)
            self.objContainer[i] = testObj
        }
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testASetObjects() {
        var expecArr = [XCTestExpectation]()
        
        var cnt = 0
        
        self.storage.clearStorage()
        for (id, object) in self.objContainer {
            let expec = expectation(description: "Async set")
            expecArr.append(expec)
            
            var labels = "odd"
            if id % 2 == 0 {
                labels = "even"
            }
            
            self.storage.save(object: object, under: "id" + String(id), with: [labels], result: { success in
                if !success {
                    print("Saving failed")
                } else {
                    expec.fulfill()
                    cnt += 1
                }
            })
            
        }
        self.storage.saveRelations()
        
        waitForExpectations(timeout: 10) { (error) in
            print("\(cnt) / \(self.max)")
        }
    }
    
    func testGetObjectAsync() {
        var expecArr = [XCTestExpectation]()
        
        for(id, obj) in self.objContainer {
            let expec = expectation(description: "Async get")
            expecArr.append(expec)
            self.storage.get(identifier: "id" + String(id), result: { object in
                if let retrievedObj = object as? TestObject {
                    if obj.name == retrievedObj.name && obj.age == retrievedObj.age {
                        expec.fulfill()
                    }
                }
            })
        }
        
        wait(for: expecArr, timeout: 10)
    }
    
    func testEmptyLabel() {
        let expec = expectation(description: "Empty label")
        self.storage.get(label: "empty") { (objects) in
            XCTAssertTrue(objects.isEmpty)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 10)
    }
    
    func testLabel() {
        let expec = expectation(description: "Label counting")
        self.storage.get(label: "odd") { (objects) in
            XCTAssert(objects.count == (self.objContainer.count / 2))
            expec.fulfill()
        }
    
        wait(for: [expec], timeout: 10)
    }
    
    func testLabelNewInstance() {
        let expec = expectation(description: "Label counting")

        let storage = MKCacheStorage(debugInfo: false)
        
        storage.get(label: "odd") { (objects) in
            XCTAssert(objects.count == (self.objContainer.count / 2))
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 10)
    }
    
    func testZClearAll() {
        var expecArr = [XCTestExpectation]()
        
        self.storage.clearStorage()
        
        for(id, _) in self.objContainer {
            let expec = expectation(description: "Deleted item")
            expecArr.append(expec)
            self.storage.get(identifier: "id" + String(id), result: { object in
                XCTAssertNil(object)
                expec.fulfill()
            })
        }
        
        wait(for: expecArr, timeout: 10)
    }
    
    func testPerformanceOnAsync() {
        self.measure {
            testGetObjectAsync()
        }
    }
    
    func testPerformanceOnLabel() {
        self.measure {
            testLabel()
        }
    }
    
    func testPerformanceOnWritingWithLabel() {
        self.measure {
            writeObjects(label: true)
        }
    }
    
    func testPerformanceOnWriting() {
        self.measure {
            writeObjects(label: false)
        }
    }
    
    func writeObjects(label: Bool = false) {
        var expecArr = [XCTestExpectation]()
        
        var cnt = 0
        
        self.storage.clearStorage()
        for (id, object) in self.objContainer {
            let expec = expectation(description: "Async set")
            expecArr.append(expec)
            
            if label {
                var labels = "odd"
                if id % 2 == 0 {
                    labels = "even"
                }
                
                self.storage.save(object: object, under: "id" + String(id), with: [labels], result: { success in
                    if !success {
                        print("Saving failed")
                    } else {
                        expec.fulfill()
                        cnt += 1
                    }
                })
            } else {
                self.storage.save(object: object, under: "id" + String(id), result: { success in
                    if !success {
                        print("Saving failed")
                    } else {
                        expec.fulfill()
                        cnt += 1
                    }
                })
            }
            
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print("\(cnt) / \(self.max)")
        }
    }
    
}
