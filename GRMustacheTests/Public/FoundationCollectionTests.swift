//
//  FoundationCollectionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class FoundationCollectionTests: XCTestCase {
    
    var arrayValue: MustacheValue!
    var setValue: MustacheValue!
    var orderedSetValue: MustacheValue!
    
    override func setUp() {
        arrayValue = {
            var array = NSMutableArray()
            array.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(array, forKey: "collection")
            return MustacheValue(data)
        }()
        setValue = {
            var set = NSMutableSet()
            set.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(set, forKey: "collection")
            return MustacheValue(data)
            }()
        orderedSetValue = {
            var orderedSet = NSMutableOrderedSet()
            orderedSet.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(orderedSet, forKey: "collection")
            return MustacheValue(data)
            }()
    }
    
    func testNSArrayIsIterated() {
        let rendering = MustacheTemplate.render(arrayValue, fromString: "{{#collection}}{{key}}{{/collection}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayIsNotIteratedWithNSArrayValueForKey() {
        let rendering = MustacheTemplate.render(arrayValue, fromString: "{{#collection.key}}{{.}}{{/collection.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "")
    }
    
    func testNSArrayCount() {
        let rendering = MustacheTemplate.render(arrayValue, fromString: "{{collection.count}}", error: nil)!.string
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSArrayFirstObject() {
        let rendering = MustacheTemplate.render(arrayValue, fromString: "{{collection.firstObject.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayLastObject() {
        let rendering = MustacheTemplate.render(arrayValue, fromString: "{{collection.lastObject.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsIterated() {
        let rendering = MustacheTemplate.render(setValue, fromString: "{{#collection}}{{key}}{{/collection}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = MustacheTemplate.render(setValue, fromString: "{{#collection.key}}{{.}}{{/collection.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "")
    }
    
    func testNSSetCount() {
        let rendering = MustacheTemplate.render(setValue, fromString: "{{collection.count}}", error: nil)!.string
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSSetAnyObject() {
        let rendering = MustacheTemplate.render(setValue, fromString: "{{collection.anyObject.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsIterated() {
        let rendering = MustacheTemplate.render(orderedSetValue, fromString: "{{#collection}}{{key}}{{/collection}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = MustacheTemplate.render(orderedSetValue, fromString: "{{#collection.key}}{{.}}{{/collection.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "")
    }
    
    func testNSOrderedSetCount() {
        let rendering = MustacheTemplate.render(orderedSetValue, fromString: "{{collection.count}}", error: nil)!.string
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSOrderedSetFirstObject() {
        let rendering = MustacheTemplate.render(orderedSetValue, fromString: "{{collection.firstObject.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetLastObject() {
        let rendering = MustacheTemplate.render(orderedSetValue, fromString: "{{collection.lastObject.key}}", error: nil)!.string
        XCTAssertEqual(rendering, "value")
    }
    
}
