//
//  FoundationCollectionTests.swift
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache;

class FoundationCollectionTests: XCTestCase {
    
    var boxedArray: MustacheBox!
    var boxedSet: MustacheBox!
    var boxedOrderedSet: MustacheBox!
    
    override func setUp() {
        boxedArray = {
            var array = NSMutableArray()
            array.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(array, forKey: "collection")
            return Box(data)
        }()
        boxedSet = {
            var set = NSMutableSet()
            set.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(set, forKey: "collection")
            return Box(data)
            }()
        boxedOrderedSet = {
            var orderedSet = NSMutableOrderedSet()
            orderedSet.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(orderedSet, forKey: "collection")
            return Box(data)
            }()
    }
    
    func testNSArrayIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSArrayCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSArrayFirstObject() {
        let rendering = Template(string: "{{collection.firstObject.key}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayLastObject() {
        let rendering = Template(string: "{{collection.lastObject.key}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSSetCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSSetAnyObject() {
        let rendering = Template(string: "{{collection.anyObject.key}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedOrderedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsNotIteratedWithNSArrayValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedOrderedSet)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSOrderedSetCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedOrderedSet)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSOrderedSetFirstObject() {
        let rendering = Template(string: "{{collection.firstObject.key}}")!.render(boxedOrderedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetLastObject() {
        let rendering = Template(string: "{{collection.lastObject.key}}")!.render(boxedOrderedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
}
