//
//  FoundationCollectionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache;

class FoundationCollectionTests: XCTestCase {
    
    var arrayValue: Value!
    var setValue: Value!
    var orderedSetValue: Value!
    
    override func setUp() {
        arrayValue = {
            var array = NSMutableArray()
            array.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(array, forKey: "collection")
            return Value(data)
        }()
        setValue = {
            var set = NSMutableSet()
            set.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(set, forKey: "collection")
            return Value(data)
            }()
        orderedSetValue = {
            var orderedSet = NSMutableOrderedSet()
            orderedSet.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(orderedSet, forKey: "collection")
            return Value(data)
            }()
    }
    
    func testNSArrayIsIterated() {
        let rendering = Template.render(arrayValue, fromString: "{{#collection}}{{key}}{{/collection}}")!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template.render(arrayValue, fromString: "{{#collection.key}}{{.}}{{/collection.key}}")!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSArrayCount() {
        let rendering = Template.render(arrayValue, fromString: "{{collection.count}}")!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSArrayFirstObject() {
        let rendering = Template.render(arrayValue, fromString: "{{collection.firstObject.key}}")!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayLastObject() {
        let rendering = Template.render(arrayValue, fromString: "{{collection.lastObject.key}}")!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsIterated() {
        let rendering = Template.render(setValue, fromString: "{{#collection}}{{key}}{{/collection}}")!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template.render(setValue, fromString: "{{#collection.key}}{{.}}{{/collection.key}}")!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSSetCount() {
        let rendering = Template.render(setValue, fromString: "{{collection.count}}")!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSSetAnyObject() {
        let rendering = Template.render(setValue, fromString: "{{collection.anyObject.key}}")!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsIterated() {
        let rendering = Template.render(orderedSetValue, fromString: "{{#collection}}{{key}}{{/collection}}")!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template.render(orderedSetValue, fromString: "{{#collection.key}}{{.}}{{/collection.key}}")!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSOrderedSetCount() {
        let rendering = Template.render(orderedSetValue, fromString: "{{collection.count}}")!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSOrderedSetFirstObject() {
        let rendering = Template.render(orderedSetValue, fromString: "{{collection.firstObject.key}}")!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetLastObject() {
        let rendering = Template.render(orderedSetValue, fromString: "{{collection.lastObject.key}}")!
        XCTAssertEqual(rendering, "value")
    }
    
}
