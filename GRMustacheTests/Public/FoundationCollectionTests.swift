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
    
    var arrayValue: Box!
    var setValue: Box!
    var orderedSetValue: Box!
    
    override func setUp() {
        arrayValue = {
            var array = NSMutableArray()
            array.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(array, forKey: "collection")
            return Box(data)
        }()
        setValue = {
            var set = NSMutableSet()
            set.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(set, forKey: "collection")
            return Box(data)
            }()
        orderedSetValue = {
            var orderedSet = NSMutableOrderedSet()
            orderedSet.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(orderedSet, forKey: "collection")
            return Box(data)
            }()
    }
    
    func testNSArrayIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(arrayValue)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(arrayValue)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSArrayCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(arrayValue)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSArrayFirstObject() {
        let rendering = Template(string: "{{collection.firstObject.key}}")!.render(arrayValue)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayLastObject() {
        let rendering = Template(string: "{{collection.lastObject.key}}")!.render(arrayValue)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(setValue)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(setValue)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSSetCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(setValue)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSSetAnyObject() {
        let rendering = Template(string: "{{collection.anyObject.key}}")!.render(setValue)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(orderedSetValue)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(orderedSetValue)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSOrderedSetCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(orderedSetValue)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSOrderedSetFirstObject() {
        let rendering = Template(string: "{{collection.firstObject.key}}")!.render(orderedSetValue)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetLastObject() {
        let rendering = Template(string: "{{collection.lastObject.key}}")!.render(orderedSetValue)!
        XCTAssertEqual(rendering, "value")
    }
    
}
