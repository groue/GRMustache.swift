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
    var mustacheBox: MustacheBox { return Box(int) }
    
    static func ==(lhs: CustomHashableBoxable, rhs: CustomHashableBoxable) -> Bool {
        return lhs.int == rhs.int
    }
}

private struct CustomBoxable : MustacheBoxable {
    let int: Int
    init(_ int: Int) { self.int = int }
    var hashValue: Int { return int }
    var mustacheBox: MustacheBox { return Box(int) }
}

class BoxTests: XCTestCase {
    
    
    // MARK: - Box(MustacheBoxable)
    
    func testInt() {
        do {
            // Explicit type
            let value: Int = 1
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: MustacheBoxable = 1
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = 1
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(1)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testCustomBoxable() {
        do {
            // Explicit type
            let value: CustomBoxable = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: MustacheBoxable = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(CustomBoxable(1))
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - Box(MustacheBoxable?)
    
    func testOptionalInt() {
        do {
            // Explicit type
            let value: Int? = 1
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: MustacheBoxable? = 1
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = 1 as Int?
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(1 as Int?)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testOptionalMustacheBoxable() {
        do {
            // Explicit type
            let value: CustomBoxable? = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: MustacheBoxable? = CustomBoxable(1)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = CustomBoxable(1) as CustomBoxable?
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(CustomBoxable(1) as CustomBoxable?)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - Box(Set<MustacheBoxable>)
    
    func testSetOfInt() {
        do {
            // Explicit type
            let value: Set<Int> = [0,1,2]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Infered element type
            let value: Set = [0,1,2]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([0,1,2] as Set)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
    }
    
    func testSetOfCustomHashableBoxable() {
        do {
            // Explicit type
            let value: Set<CustomHashableBoxable> = [CustomHashableBoxable(0),CustomHashableBoxable(1),CustomHashableBoxable(2)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Infered element type
            let value: Set = [CustomHashableBoxable(0),CustomHashableBoxable(1),CustomHashableBoxable(2)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([CustomHashableBoxable(0),CustomHashableBoxable(1),CustomHashableBoxable(2)] as Set)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
    }
    
    
    // MARK: - Box([String: MustacheBoxable])
    
    func testDictionaryOfStringInt() {
        do {
            // Explicit type
            let value: [String: Int] = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: [String: MustacheBoxable] = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": 1])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfStringCustomBoxable() {
        do {
            // Explicit type
            let value: [String: CustomBoxable] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: [String: MustacheBoxable] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": CustomBoxable(1)])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - Box([String: MustacheBoxable?])
    
    func testDictionaryOfStringOptionalInt() {
        do {
            // Explicit type
            let value: [String: Int?] = ["name": 1]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: [String: MustacheBoxable?] = ["name": 1 as Int?]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": 1 as Int?]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": 1 as Int?]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": 1 as Int?])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfStringOptionalCustomBoxable() {
        do {
            // Explicit type
            let value: [String: CustomBoxable?] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: [String: MustacheBoxable?] = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": CustomBoxable(1)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": CustomBoxable(1)])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    
    // MARK: - Box([String: Any])
    
    func testDictionaryOfStringAny() {
        do {
            // Explicit type
            let value: [String: Any] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // As MustacheBoxable (won't compile)
//            let value: [String: MustacheBoxable & Hashable] = ["int": 1, "string": "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Dictionary = ["int": 1, "string": "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type (won't compile)
//            let value = ["int": 1, "string": "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(["int": 1, "string": "foo"])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
    }
    
    
    // MARK: - Box([String: Any?])
    
    func testDictionaryOfStringOptionalAny() {
        do {
            // Explicit type
            let value: [String: Any?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // As MustacheBoxable?
            let value: [String: MustacheBoxable?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered element type (won't compile)
//            let value: Dictionary = ["int": 1 as Int?, "string": "foo" as String?, "missing": nil as CustomBoxable?]
//            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type (won't compile)
//            let value = ["int": 1 as Int?, "string": "foo" as String?, "missing": nil as CustomBoxable?]
//            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(["int": 1 as Int?, "string": "foo" as String?, "missing": nil as CustomBoxable?])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
    }
    
    
    // MARK: - Box([AnyHashable: Any])
    
    func testDictionaryOfAnyHashableAny() {
        do {
            // Explicit type
            let value: [AnyHashable: Any] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // As MustacheBoxable
            let value: [AnyHashable: MustacheBoxable] = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Dictionary = [AnyHashable("int"): 1, AnyHashable("string"): "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type (won't compile)
//            let value = [AnyHashable("int"): 1, AnyHashable("string"): "foo"]
//            let template = try! Template(string: "{{int}}, {{string}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box([AnyHashable("int"): 1, AnyHashable("string"): "foo"])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
    }
    
    func testDictionaryOfArray() {
        do {
            // Explicit type
            let value: [AnyHashable: Any] = ["int": [1, 2], "string": ["foo", "bar"]]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "12, foobar")
        }
        do {
            // Infered element type (won't compile)
            let value: Dictionary = ["int": [1, 2], "string": ["foo", "bar"]]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "12, foobar")
        }
        do {
            // Infered type (won't compile)
            let value = ["int": [1, 2], "string": ["foo", "bar"]]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "12, foobar")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(["int": [1, 2], "string": ["foo", "bar"]])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "12, foobar")
        }
    }
    
    func testDictionaryOfDictionary() {
        do {
            // Explicit type
            let value: [AnyHashable: Any] = ["int": ["name": 1], "string": ["name": "foo"]]
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered element type (won't compile)
            let value: Dictionary = ["int": ["name": 1], "string": ["name": "foo"]]
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type (won't compile)
            let value = ["int": ["name": 1], "string": ["name": "foo"]]
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int.name}}, {{string.name}}")
            let box = Box(["int": ["name": 1], "string": ["name": "foo"]])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
    }
    
    
    // MARK: - Box([AnyHashable: Any?])
    
    func testDictionaryOfAnyHashableOptionalAny() {
        do {
            // Explicit type
            let value: [AnyHashable: Any?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // As MustacheBoxable?
            let value: [AnyHashable: MustacheBoxable?] = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered element type
            let value: Dictionary = [AnyHashable("int"): 1 as Any?, AnyHashable("string"): "foo" as Any?, AnyHashable("missing"): nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type
            let value = [AnyHashable("int"): 1 as Any?, AnyHashable("string"): "foo" as Any?, AnyHashable("missing"): nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type (won't compile)
//            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
//            let box = Box([AnyHashable("int"): 1 as Any?, AnyHashable("string"): "foo" as Any?, AnyHashable("missing"): nil])
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "1, foo, ")
        }
    }
    
    
    // MARK: - Box([MustacheBoxable])
    
    func testArrayOfInt() {
        do {
            // Explicit type
            let value: [Int] = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable
            let value: [MustacheBoxable] = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([0,1,2,3])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    func testArrayOfCustomBoxable() {
        do {
            // Explicit type
            let value: [CustomBoxable] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable
            let value: [MustacheBoxable] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    
    // MARK: - Box([MustacheBoxable?])
    
    func testArrayOfOptionalInt() {
        do {
            // Explicit type
            let value: [Int?] = [0,1,2,3,nil]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable?
            let value: [MustacheBoxable?] = [0,1,2,3,nil]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [0 as Int?, 1 as Int?, 2 as Int?,3 as Int?, nil as Int?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [0 as Int?, 1 as Int?, 2 as Int?, 3 as Int?, nil as Int?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([0 as Int?, 1 as Int?, 2 as Int?, 3 as Int?, nil as Int?])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
    }

    func testArrayOfOptionalCustomBoxable() {
        do {
            // Explicit type
            let value: [CustomBoxable?] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable?
            let value: [MustacheBoxable?] = [CustomBoxable(0), CustomBoxable(1), CustomBoxable(2), CustomBoxable(3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [CustomBoxable(0) as CustomBoxable?, CustomBoxable(1) as CustomBoxable?, CustomBoxable(2) as CustomBoxable?, CustomBoxable(3) as CustomBoxable?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [CustomBoxable(0) as CustomBoxable?, CustomBoxable(1) as CustomBoxable?, CustomBoxable(2) as CustomBoxable?, CustomBoxable(3) as CustomBoxable?]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([CustomBoxable(0) as CustomBoxable?, CustomBoxable(1) as CustomBoxable?, CustomBoxable(2) as CustomBoxable?, CustomBoxable(3) as CustomBoxable?])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    
    // MARK: - Box([Any])
    
    func testArrayOfAny() {
        do {
            // Explicit type
            let value: [Any] = [0,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Array = [0,"foo"]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type (won't compile)
//            let value = [0,"foo"]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([0,"foo"])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    func testArrayOfArray() {
        do {
            // Explicit type
            let value: [Any] = [[0,"foo"]]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type
            let value: Array = [[0,"foo"]]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type
            let value = [[0,"foo"]]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([[0,"foo"]])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    func testArrayOfDictionary() {
        do {
            // Explicit type
            let value: [Any] = [["name": 1]]
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type (won't compile)
            let value: Array = [["name": 1]]
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = [["name": 1]]
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{name}}{{/}}")
            let box = Box([["name": 1]])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }

    
    // MARK: - Box([Any?])
    
    func testArrayOfOptionalAny() {
        do {
            // Explicit type
            let value: [Any?] = [0,nil,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // As MustacheBoxable?
            let value: [MustacheBoxable?] = [0,nil,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type (won't compile)
//            let value: Array = [0 as Int?, nil as CustomBoxable?, "foo" as String?]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type (won't compile)
//            let value = [0 as Int?, nil as CustomBoxable?, "foo" as String?]
//            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
//            let box = Box(value)
//            let rendering = try! template.render(box)
//            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([0 as Int?, nil as CustomBoxable?, "foo" as String?])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    
    // MARK: - Box([non boxable])
    
    func testArrayOfNonMustacheBoxable() {
        class Class { }
        let array: [Any] = [Class()]
        let context = Context(Box(array))
        let box = context.mustacheBoxForKey("first")
        XCTAssertTrue(box.value == nil)
    }
    
    
    // MARK: - Box(NSArray)
    
    func testNSArrayOfInt() {
        let value: NSArray = [0,1,2,3]
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "0123")
    }
    
    func testNSArrayOfMustacheBoxable() {
        class Class: MustacheBoxable {
            var mustacheBox: MustacheBox {
                return MustacheBox(keyedSubscript: { (key: String) in
                    return Box(key)
                })
            }
        }
        
        let array = NSArray(object: Class())
        let context = Context(Box(array))
        let box = try! context.mustacheBoxForExpression("first.foo")
        XCTAssertEqual((box.value as! String), "foo")
    }
    
    func testNSArrayOfNonMustacheBoxable() {
        class Class {
        }
        
        let array = NSArray(object: Class())
        let context = Context(Box(array))
        let box = context.mustacheBoxForKey("first")
        XCTAssertTrue(box.value == nil)
    }
    
    
    // MARK: - Box(Range)
    
    func testRange() {
        let value = 0..<10
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(Array(value))
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "0123456789")
    }
}
