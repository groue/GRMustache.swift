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

// TODO: write an equivalent test class for Swift collections
class FoundationCollectionTests: XCTestCase {
    
    var boxedArray: MustacheBox!
    var boxedNSArray: MustacheBox!
    var boxedSet: MustacheBox!
    var boxedNSSet: MustacheBox!
    var boxedNSOrderedSet: MustacheBox!
    
    override func setUp() {
        boxedArray = Box(["collection": [["key": "value"]]])
        boxedNSArray = {
            var array = NSMutableArray()
            array.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(array, forKey: "collection")
            return Box(data)
        }()
        boxedSet = Box(["collection": Set([["key": "value"]])])
        boxedNSSet = {
            var set = NSMutableSet()
            set.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(set, forKey: "collection")
            return Box(data)
            }()
        boxedNSOrderedSet = {
            var orderedSet = NSMutableOrderedSet()
            orderedSet.addObject(["key": "value"])
            var data = NSMutableDictionary()
            data.setObject(orderedSet, forKey: "collection")
            return Box(data)
            }()
    }
    
    func testNSArrayIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedNSArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayIsNotIteratedWithValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedNSArray)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSArrayIsEmpty() {
        // Arrays can NOT be queried for the key `isEmpty` on purpose.
        // This test makes sure no user request would activate such a bad idea.
        //
        // `array.isEmpty` would evaluate to false in case of a missing set, and
        // this would be soooo misleading. On the contrary, `array.count` is
        // falsey for both empty and missing sets, and this is why it is the
        // recommended technique.
        let templateString = "{{#collection.isEmpty}}Empty{{/}}{{^collection.isEmpty}}Not empty{{/}}"
        XCTAssertEqual(Template(string: templateString)!.render()!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":NSArray()]))!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":NSArray(object: "foo")]))!, "Not empty")
    }
    
    func testNSArrayCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedNSArray)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSArrayFirstObject() {
        let rendering = Template(string: "{{collection.firstObject.key}}")!.render(boxedNSArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayLastObject() {
        let rendering = Template(string: "{{collection.lastObject.key}}")!.render(boxedNSArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testArrayIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testArrayIsNotIteratedWithValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "")
    }
    
    func testArrayIsEmpty() {
        // Arrays can NOT be queried for the key `isEmpty` on purpose.
        // This test makes sure no user request would activate such a bad idea.
        //
        // `array.isEmpty` would evaluate to false in case of a missing set, and
        // this would be soooo misleading. On the contrary, `array.count` is
        // falsey for both empty and missing sets, and this is why it is the
        // recommended technique.
        let templateString = "{{#collection.isEmpty}}Empty{{/}}{{^collection.isEmpty}}Not empty{{/}}"
        XCTAssertEqual(Template(string: templateString)!.render()!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":[]]))!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":["foo"]]))!, "Not empty")
    }
    
    func testArrayCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testArrayFirstObject() {
        let rendering = Template(string: "{{collection.firstObject.key}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testArrayLastObject() {
        let rendering = Template(string: "{{collection.lastObject.key}}")!.render(boxedArray)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedNSSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsNotIteratedWithValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedNSSet)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSSetIsEmpty() {
        // Sets can NOT be queried for the key `isEmpty` on purpose.
        // This test makes sure no user request would activate such a bad idea.
        //
        // `set.isEmpty` would evaluate to false in case of a missing set, and
        // this would be soooo misleading. On the contrary, `set.count` is
        // falsey for both empty and missing sets, and this is why it is the
        // recommended technique.
        let templateString = "{{#collection.isEmpty}}Empty{{/}}{{^collection.isEmpty}}Not empty{{/}}"
        XCTAssertEqual(Template(string: templateString)!.render()!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":NSSet()]))!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":NSSet(object: "foo")]))!, "Not empty")
    }
    
    func testNSSetCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedNSSet)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSSetAnyObject() {
        let rendering = Template(string: "{{collection.anyObject.key}}")!.render(boxedNSSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testSetIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testSetIsNotIteratedWithValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "")
    }
    
    func testSetIsEmpty() {
        // Sets can NOT be queried for the key `isEmpty` on purpose.
        // This test makes sure no user request would activate such a bad idea.
        //
        // `set.isEmpty` would evaluate to false in case of a missing set, and
        // this would be soooo misleading. On the contrary, `set.count` is
        // falsey for both empty and missing sets, and this is why it is the
        // recommended technique.
        let templateString = "{{#collection.isEmpty}}Empty{{/}}{{^collection.isEmpty}}Not empty{{/}}"
        XCTAssertEqual(Template(string: templateString)!.render()!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":Set<String>()]))!, "Not empty")
        XCTAssertEqual(Template(string: templateString)!.render(Box(["collection":Set(["foo"])]))!, "Not empty")
    }
    
    func testSetCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testSetAnyObject() {
        let rendering = Template(string: "{{collection.anyObject.key}}")!.render(boxedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsIterated() {
        let rendering = Template(string: "{{#collection}}{{key}}{{/collection}}")!.render(boxedNSOrderedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsNotIteratedWithValueForKey() {
        let rendering = Template(string: "{{#collection.key}}{{.}}{{/collection.key}}")!.render(boxedNSOrderedSet)!
        XCTAssertEqual(rendering, "")
    }
    
    func testNSOrderedSetCount() {
        let rendering = Template(string: "{{collection.count}}")!.render(boxedNSOrderedSet)!
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSOrderedSetFirstObject() {
        let rendering = Template(string: "{{collection.firstObject.key}}")!.render(boxedNSOrderedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetLastObject() {
        let rendering = Template(string: "{{collection.lastObject.key}}")!.render(boxedNSOrderedSet)!
        XCTAssertEqual(rendering, "value")
    }
    
}
