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
            let testObjJSON = TestObject(name: "name" + String(i), age: i)
            self.objContainer[i] = testObjJSON
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
        self.storage.close()
        
        waitForExpectations(timeout: 10) { (error) in
            print("\(cnt) / \(self.max)")
        }
    }
    
    func testGetObjectSync() {
        var expecArr = [XCTestExpectation]()
        
        for(id, obj) in self.objContainer {
            let expec = expectation(description: "Sync get id: " + String(id))
            expecArr.append(expec)
            self.storage.get(identifier: "id" + String(id), result: { (object: TestObject?) in
                if let retrievedObj: TestObject = object {
                    if obj.name == retrievedObj.name && obj.age == retrievedObj.age {
                        expec.fulfill()
                    }
                }
            })
        }
         
        wait(for: expecArr, timeout: 10)
    }
    
    func testMultiEntryOverwritten() {
        var expecArr = [XCTestExpectation]()
        
        let expec1 = expectation(description: "Get entry")
        expecArr.append(expec1)
        let expec2 = self.expectation(description: "Write double entry")
        expecArr.append(expec2)
        let expec3 = self.expectation(description: "Read doubled entry")
        expecArr.append(expec3)

        self.storage.get(identifier: "id98") { (object: TestObject?) in
            if self.objContainer[98]?.name == object?.name {
                expec1.fulfill()
                
                DispatchQueue.main.async {
                    
                    
                    let doubleObj = TestObject(name: "id98", age: 111111)
                    self.storage.save(object: doubleObj, under: "id98", with: ["even"], result: { (success) in
                        if success {
                            expec2.fulfill()
                            
                            DispatchQueue.main.async {
                                self.storage.get(identifier: "id98", result: { (object: TestObject?) in
                                    if object?.age == doubleObj.age {
                                        expec3.fulfill()
                                        DispatchQueue.main.async {
                                            self.storage.save(object: TestObject(name: "name98", age: 98), under: "id98", with: ["even"], result: { (result) in
                                                
                                            })
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
        
        wait(for: expecArr, timeout: 10)
    }
    
    func testEmptyLabel() {
        let expec = expectation(description: "Empty label")
        self.storage.get(label: "empty") { (objects: [TestObject]) in
            XCTAssertTrue(objects.isEmpty)
            expec.fulfill()
        }
        
        wait(for: [expec], timeout: 10)
    }
    
    func testLabel() {
        let expec = expectation(description: "Label counting")
        self.storage.get(label: "odd") { (objects: [TestObject]) in
            XCTAssert(objects.count == (self.objContainer.count / 2))
            expec.fulfill()
        }
    
        wait(for: [expec], timeout: 10)
    }
    
    func testLabelNewInstance() {
        let expec = expectation(description: "Label counting")

        let storage = MKCacheStorage(debugInfo: false)
        
        storage.get(label: "odd") { (objects: [TestObject]) in
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
            self.storage.get(identifier: "id" + String(id), result: { (object: TestObject?) in
                XCTAssertNil(object)
                expec.fulfill()
            })
        }
        
        wait(for: expecArr, timeout: 10)
    }
    
    func testPerformanceOnSync() {
        self.measure {
            self.testGetObjectSync()
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
