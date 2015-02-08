// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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
