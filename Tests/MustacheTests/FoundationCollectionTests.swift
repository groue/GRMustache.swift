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
    
    var array: [Any?]!
    var nsArray: NSArray!
    var set: Set<AnyHashable>!
    var nsSet: NSSet!
    var nsOrderedSet: NSOrderedSet!
    
    override func setUp() {
        array = [["key": "value"]]
        nsArray = [["key": "value"]]
        set = Set([["key": "value"] as NSDictionary])
        nsSet = NSSet(array: [["key": "value"]])
        nsOrderedSet = NSOrderedSet(array: [["key": "value"]])
    }
    
    func testNSArrayIsIterated() {
        let rendering = try! Template(string: "{{#collection}}{{key}}{{/collection}}").render(["collection": nsArray])
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayIsNotIteratedWithValueForKey() {
        let rendering = try! Template(string: "{{#collection.key}}{{.}}{{/collection.key}}").render(["collection": nsArray])
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
        XCTAssertEqual(try! Template(string: templateString).render(), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection":NSArray()]), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection":NSArray(object: "foo")]), "Not empty")
    }
    
    func testNSArrayCountKey() {
        let rendering = try! Template(string: "{{collection.count}}").render(["collection": nsArray])
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSArrayKeyFirst() {
        let rendering = try! Template(string: "{{collection.first.key}}").render(["collection": nsArray])
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSArrayLastKey() {
        let rendering = try! Template(string: "{{collection.last.key}}").render(["collection": nsArray])
        XCTAssertEqual(rendering, "value")
    }
    
    func testArrayIsIterated() {
        let rendering = try! Template(string: "{{#collection}}{{key}}{{/collection}}").render(["collection": array])
        XCTAssertEqual(rendering, "value")
    }
    
    func testArrayIsNotIteratedWithValueForKey() {
        let rendering = try! Template(string: "{{#collection.key}}{{.}}{{/collection.key}}").render(["collection": array])
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
        XCTAssertEqual(try! Template(string: templateString).render(), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection": [] as [String]]), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection": ["foo"]]), "Not empty")
    }
    
    func testArrayCountKey() {
        let rendering = try! Template(string: "{{collection.count}}").render(["collection": array])
        XCTAssertEqual(rendering, "1")
    }
    
    func testArrayKeyFirst() {
        let rendering = try! Template(string: "{{collection.first.key}}").render(["collection": array])
        XCTAssertEqual(rendering, "value")
    }
    
    func testArrayLastKey() {
        let rendering = try! Template(string: "{{collection.last.key}}").render(["collection": array])
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsIterated() {
        let rendering = try! Template(string: "{{#collection}}{{key}}{{/collection}}").render(["collection": nsSet])
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetIsNotIteratedWithValueForKey() {
        let rendering = try! Template(string: "{{#collection.key}}{{.}}{{/collection.key}}").render(["collection": nsSet])
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
        XCTAssertEqual(try! Template(string: templateString).render(), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection":NSSet()]), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection":NSSet(object: "foo")]), "Not empty")
    }
    
    func testNSSetCountKey() {
        let rendering = try! Template(string: "{{collection.count}}").render(["collection": nsSet])
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSSetFirstKey() {
        let rendering = try! Template(string: "{{collection.first.key}}").render(["collection": nsSet])
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSSetLastKey() {
        // There is no such thing as set.last
        let rendering = try! Template(string: "{{collection.last.key}}").render(["collection": nsSet])
        XCTAssertEqual(rendering, "")
    }
    
    func testSetIsIterated() {
        let rendering = try! Template(string: "{{#collection}}{{key}}{{/collection}}").render(["collection": set])
        XCTAssertEqual(rendering, "value")
    }
    
    func testSetIsNotIteratedWithValueForKey() {
        let rendering = try! Template(string: "{{#collection.key}}{{.}}{{/collection.key}}").render(["collection": set])
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
        XCTAssertEqual(try! Template(string: templateString).render(), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection": Set<String>()]), "Not empty")
        XCTAssertEqual(try! Template(string: templateString).render(["collection": Set(["foo"])]), "Not empty")
    }
    
    func testSetCountKey() {
        let rendering = try! Template(string: "{{collection.count}}").render(["collection": set])
        XCTAssertEqual(rendering, "1")
    }
    
    func testSetFirstKey() {
        let rendering = try! Template(string: "{{collection.first.key}}").render(["collection": set])
        XCTAssertEqual(rendering, "value")
    }
    
    func testSetLastKey() {
        // There is no such thing as set.last
        let rendering = try! Template(string: "{{collection.last.key}}").render(["collection": set])
        XCTAssertEqual(rendering, "")
    }
    
    func testNSOrderedSetIsIterated() {
        let rendering = try! Template(string: "{{#collection}}{{key}}{{/collection}}").render(["collection": nsOrderedSet])
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetIsNotIteratedWithValueForKey() {
        let rendering = try! Template(string: "{{#collection.key}}{{.}}{{/collection.key}}").render(["collection": nsOrderedSet])
        XCTAssertEqual(rendering, "")
    }
    
    func testNSOrderedSetCountKey() {
        let rendering = try! Template(string: "{{collection.count}}").render(["collection": nsOrderedSet])
        XCTAssertEqual(rendering, "1")
    }
    
    func testNSOrderedSetKeyFirst() {
        let rendering = try! Template(string: "{{collection.first.key}}").render(["collection": nsOrderedSet])
        XCTAssertEqual(rendering, "value")
    }
    
    func testNSOrderedSetLastKey() {
        let rendering = try! Template(string: "{{collection.last.key}}").render(["collection": nsOrderedSet])
        XCTAssertEqual(rendering, "value")
    }
    
}
