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
import Mustache

private struct CustomHashableBoxable : MustacheBoxable, Hashable {
    let int: Int
    init(_ int: Int) { self.int = int }
    var hashValue: Int { return int }
    var mustacheBox: MustacheBox {
        // Don't inherit the boolean nature of int
        return MustacheBox(
            value: self,
            boolValue: true,
            render: { _ in Rendering("\(self.int)") })
    }
    
    static func ==(lhs: CustomHashableBoxable, rhs: CustomHashableBoxable) -> Bool {
        return lhs.int == rhs.int
    }
}

private struct CustomBoxable : MustacheBoxable {
    let int: Int
    init(_ int: Int) { self.int = int }
    var hashValue: Int { return int }
    var mustacheBox: MustacheBox {
        // Don't inherit the boolean nature of int
        return MustacheBox(
            value: self,
            boolValue: true,
            render: { _ in Rendering("\(self.int)") })
    }
}

class BoxTests: XCTestCase {
    
    
    // MARK: - MustacheBoxable
    
    func testInt() {
        do {
            // Explicit type
            let value: Int = 1
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: MustacheBoxable = 1
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = 1
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(1)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: Int = 1
            let template = try! Template(string: "{{#nested}}1{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testCustomBoxable() {
        do {
            // Explicit type
            let value: CustomBoxable = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: MustacheBoxable = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(CustomBoxable(1))
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: CustomBoxable = CustomBoxable(1)
            let template = try! Template(string: "{{#nested}}{{.}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - MustacheBoxable?
    
    func testOptionalInt() {
        do {
            // Explicit type
            let value: Int? = 1
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: MustacheBoxable? = 1
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = 1 as Int?
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(1 as Int?)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: Int? = 1
            let template = try! Template(string: "{{#nested}}1{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testOptionalMustacheBoxable() {
        do {
            // Explicit type
            let value: CustomBoxable? = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: MustacheBoxable? = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = CustomBoxable(1) as CustomBoxable?
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{.}}")
            let rendering = try! template.render(CustomBoxable(1) as CustomBoxable?)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: CustomBoxable? = CustomBoxable(1)
            let template = try! Template(string: "{{#nested}}{{.}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - Set<MustacheBoxable>
    
    func testSetOfInt() {
        do {
            // Explicit type
            let value: Set<Int> = [0,1,2]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Infered element type
            let value: Set = [0,1,2]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([0,1,2] as Set)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Nested
            let value: Set<Int> = [0,1,2]
            let template = try! Template(string: "{{#nested}}{{.}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
    }
    
    func testSetOfCustomHashableBoxable() {
        do {
            // Explicit type
            let value: Set<CustomHashableBoxable> = [CustomHashableBoxable(0),CustomHashableBoxable(1),CustomHashableBoxable(2)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Infered element type
            let value: Set = [CustomHashableBoxable(0),CustomHashableBoxable(1),CustomHashableBoxable(2)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([CustomHashableBoxable(0),CustomHashableBoxable(1),CustomHashableBoxable(2)] as Set)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Nested
            let value: Set<CustomHashableBoxable> = [CustomHashableBoxable(0),CustomHashableBoxable(1),CustomHashableBoxable(2)]
            let template = try! Template(string: "{{#nested}}{{#.}}{{.}}{{/}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
    }
    
    
    // MARK: - [String: MustacheBoxable]
    
    func testDictionaryOfStringInt() {
        do {
            // Explicit type
            let value: [String: Int] = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: [String: MustacheBoxable] = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(["name": 1])
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: [String: Int] = ["name": 1]
            let template = try! Template(string: "{{#nested}}{{name}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfStringCustomBoxable() {
        do {
            // Explicit type
            let value: [String: CustomBoxable] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: [String: MustacheBoxable] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(["name": CustomBoxable(1)])
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: [String: CustomBoxable] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{#nested}}{{name}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - [String: MustacheBoxable?]
    
    func testDictionaryOfStringOptionalInt() {
        do {
            // Explicit type
            let value: [String: Int?] = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: [String: MustacheBoxable?] = ["name": 1 as Int?]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": 1 as Int?]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": 1 as Int?]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(["name": 1 as Int?])
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: [String: Int?] = ["name": 1]
            let template = try! Template(string: "{{#nested}}{{name}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfStringOptionalCustomBoxable() {
        do {
            // Explicit type
            let value: [String: CustomBoxable?] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: [String: MustacheBoxable?] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{name}}")
            let rendering = try! template.render(["name": CustomBoxable(1)])
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: [String: CustomBoxable?] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{#nested}}{{name}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - [String: Any]
    
    func testDictionaryOfStringAny() {
        do {
            // Explicit type
            let value: [String: Any] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // As MustacheBoxable (won't compile)
//            let value: [String: MustacheBoxable & Hashable] = ["int": 1, "string": "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Dictionary = ["int": 1, "string": "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type (won't compile)
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let value = ["int": 1, "string": "foo"]
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Nested
            let value: [String: Any] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{#nested}}{{int}}, {{string}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1, foo")
        }
    }
    
    
    // MARK: - [String: Any?]
    
    func testDictionaryOfStringOptionalAny() {
        do {
            // Explicit type
            let value: [String: Any?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // As MustacheBoxable?
            let value: [String: MustacheBoxable?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered element type (won't compile)
//            let value: Dictionary = ["int": 1 as Int?, "string": "foo" as String?, "missing": nil as CustomBoxable?]
//            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type (won't compile)
//            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
//            let value = ["int": 1 as Int?, "string": "foo" as String?, "missing": nil as CustomBoxable?]
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Nested
            let value: [String: Any?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{#nested}}{{int}}, {{string}}, {{missing}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1, foo, ")
        }
    }
    
    
    // MARK: - [AnyHashable: Any]
    
    func testDictionaryOfAnyHashableAny() {
        do {
            // Explicit type
            let value: [AnyHashable: Any] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // As MustacheBoxable
            let value: [AnyHashable: MustacheBoxable] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Dictionary = [AnyHashable("int"): 1, AnyHashable("string"): "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type (won't compile)
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let value = [AnyHashable("int"): 1, AnyHashable("string"): "foo"]
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Nested
            let value: [AnyHashable: Any] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{#nested}}{{int}}, {{string}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1, foo")
        }
    }
    
    func testDictionaryOfArray() {
        do {
            // Explicit type
            let value: [AnyHashable: Any] = ["int": [1, 2], "string": ["foo", "bar"]]
            let template = try! Template(string: "{{int}}, {{string}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "12, foobar")
        }
        do {
            // Infered element type (won't compile)
            let value: Dictionary = ["int": [1, 2], "string": ["foo", "bar"]]
            let template = try! Template(string: "{{int}}, {{string}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "12, foobar")
        }
        do {
            // Infered type (won't compile)
            let value = ["int": [1, 2], "string": ["foo", "bar"]]
            let template = try! Template(string: "{{int}}, {{string}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "12, foobar")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int}}, {{string}}")
            let value = ["int": [1, 2], "string": ["foo", "bar"]]
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "12, foobar")
        }
        do {
            // Nested
            let value: [AnyHashable: Any] = ["int": [1, 2], "string": ["foo", "bar"]]
            let template = try! Template(string: "{{#nested}}{{int}}, {{string}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "12, foobar")
        }
    }
    
    func testDictionaryOfDictionary() {
        do {
            // Explicit type
            let value: [AnyHashable: Any] = ["int": ["name": 1], "string": ["name": "foo"]]
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered element type (won't compile)
            let value: Dictionary = ["int": ["name": 1], "string": ["name": "foo"]]
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type (won't compile)
            let value = ["int": ["name": 1], "string": ["name": "foo"]]
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let value = ["int": ["name": 1], "string": ["name": "foo"]]
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Nested
            let value: [AnyHashable: Any] = ["int": ["name": 1], "string": ["name": "foo"]]
            let template = try! Template(string: "{{#nested}}{{int.name}}, {{string.name}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1, foo")
        }
    }
    
    
    // MARK: - [AnyHashable: Any?]
    
    func testDictionaryOfAnyHashableOptionalAny() {
        do {
            // Explicit type
            let value: [AnyHashable: Any?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // As MustacheBoxable?
            let value: [AnyHashable: MustacheBoxable?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered element type
            let value: Dictionary = [AnyHashable("int"): 1 as Any?, AnyHashable("string"): "foo" as Any?, AnyHashable("missing"): nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type
            let value = [AnyHashable("int"): 1 as Any?, AnyHashable("string"): "foo" as Any?, AnyHashable("missing"): nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type (won't compile)
//            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
//            let value = [AnyHashable("int"): 1 as Any?, AnyHashable("string"): "foo" as Any?, AnyHashable("missing"): nil]
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Nested
            let value: [AnyHashable: Any?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{#nested}}{{int}}, {{string}}, {{missing}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1, foo, ")
        }
    }
    
    
    // MARK: - [MustacheBoxable]
    
    func testArrayOfInt() {
        do {
            // Explicit type
            let value: [Int] = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable
            let value: [MustacheBoxable] = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([0,1,2,3])
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Nested
            let value: [Int] = [0,1,2,3]
            let template = try! Template(string: "{{#nested}}{{.}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    func testArrayOfCustomBoxable() {
        do {
            // Explicit type
            let value: [CustomBoxable] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable
            let value: [MustacheBoxable] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)])
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Nested
            let value: [CustomBoxable] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#nested}}{{#.}}{{.}}{{/}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    
    // MARK: - [MustacheBoxable?]
    
    func testArrayOfOptionalInt() {
        do {
            // Explicit type
            let value: [Int?] = [0,1,2,3,nil]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable?
            let value: [MustacheBoxable?] = [0,1,2,3,nil]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [0 as Int?, 1 as Int?, 2 as Int?,3 as Int?, nil as Int?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [0 as Int?, 1 as Int?, 2 as Int?, 3 as Int?, nil as Int?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([0 as Int?, 1 as Int?, 2 as Int?, 3 as Int?, nil as Int?])
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Nested
            let value: [Int?] = [0,1,2,3,nil]
            let template = try! Template(string: "{{#nested}}{{.}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "0123")
        }
    }

    func testArrayOfOptionalCustomBoxable() {
        do {
            // Explicit type
            let value: [CustomBoxable?] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable?
            let value: [MustacheBoxable?] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [CustomBoxable(0) as CustomBoxable?, CustomBoxable(1) as CustomBoxable?, CustomBoxable(2) as CustomBoxable?, CustomBoxable(3) as CustomBoxable?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [CustomBoxable(0) as CustomBoxable?, CustomBoxable(1) as CustomBoxable?, CustomBoxable(2) as CustomBoxable?, CustomBoxable(3) as CustomBoxable?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([CustomBoxable(0) as CustomBoxable?, CustomBoxable(1) as CustomBoxable?, CustomBoxable(2) as CustomBoxable?, CustomBoxable(3) as CustomBoxable?])
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Nested
            let value: [CustomBoxable?] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#nested}}{{#.}}{{.}}{{/}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    
    // MARK: - [Any]
    
    func testArrayOfAny() {
        do {
            // Explicit type
            let value: [Any] = [0,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Array = [0,"foo"]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type (won't compile)
//            let value = [0,"foo"]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([0,"foo"])
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Nested
            let value: [Any] = [0,"foo"]
            let template = try! Template(string: "{{#nested}}{{.}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    func testArrayOfArray() {
        do {
            // Explicit type
            let value: [Any] = [[0,"foo"]]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type
            let value: Array = [[0,"foo"]]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type
            let value = [[0,"foo"]]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([[0,"foo"]])
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Nested
            let value: [Any] = [[0,"foo"]]
            let template = try! Template(string: "{{#nested}}{{#.}}{{.}}{{/}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    func testArrayOfDictionary() {
        do {
            // Explicit type
            let value: [Any] = [["name": 1]]
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type (won't compile)
            let value: Array = [["name": 1]]
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = [["name": 1]]
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let rendering = try! template.render([["name": 1]])
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Nested
            let value: [Any] = [["name": 1]]
            let template = try! Template(string: "{{#nested}}{{#.}}{{name}}{{/}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "1")
        }
    }

    
    // MARK: - [Any?]
    
    func testArrayOfOptionalAny() {
        do {
            // Explicit type
            let value: [Any?] = [0,nil,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // As MustacheBoxable?
            let value: [MustacheBoxable?] = [0,nil,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render(value)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Array = [0 as Int?, nil as CustomBoxable?, "foo" as String?]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type (won't compile)
//            let value = [0 as Int?, nil as CustomBoxable?, "foo" as String?]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let rendering = try! template.render(value)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let rendering = try! template.render([0, nil, "foo"])
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Nested
            let value: [Any?] = [0,nil,"foo"]
            let template = try! Template(string: "{{#nested}}{{.}}{{/}}")
            let rendering = try! template.render(["nested": value])
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    
    // MARK: - NSArray
    
    func testNSArrayOfInt() {
        let value: NSArray = [0,1,2,3]
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "0123")
    }
    
    func testNSArrayOfMustacheBoxable() {
        class Class: MustacheBoxable {
            var mustacheBox: MustacheBox {
                return MustacheBox(keyedSubscript: { (key: String) in
                    return key
                })
            }
        }
        
        let array = NSArray(object: Class())
        let context = Context(array)
        let box = try! context.mustacheBox(forExpression: "first.foo")
        XCTAssertEqual((box.value as! String), "foo")
    }
    
    
    // MARK: - Range
    
    func testRange() {
        let value = 0..<10
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let rendering = try! template.render(Array(value))
        XCTAssertEqual(rendering, "0123456789")
    }
}
