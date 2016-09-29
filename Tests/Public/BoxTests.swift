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

struct HashableBoxable : MustacheBoxable, Hashable {
    let int: Int
    var hashValue: Int { return int }
    var mustacheBox: MustacheBox { return Box(int) }
}

func ==(lhs: HashableBoxable, rhs: HashableBoxable) -> Bool {
    return lhs.int == rhs.int
}

class BoxTests: XCTestCase {
    
    func testInt() {
        do {
            // Explicit type
            let value: Int = 0
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: MustacheBoxable = 0
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = 0
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(0)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testOptionalInt() {
        do {
            // Explicit type
            let value: Int? = 0
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: MustacheBoxable? = 0
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = Optional.some(0)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(Optional.some(0))
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testMustacheBoxable() {
        do {
            // Explicit type
            let value: HashableBoxable = HashableBoxable(int:0)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: MustacheBoxable = HashableBoxable(int:0)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = HashableBoxable(int:0)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(HashableBoxable(int:0))
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }

    func testOptionalMustacheBoxable() {
        do {
            // Explicit type
            let value: HashableBoxable? = HashableBoxable(int:0)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: MustacheBoxable? = HashableBoxable(int:0)
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = Optional.some(HashableBoxable(int:0))
            let template = try! Template(string: "{{.}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{.}}")
            let box = Box(Optional.some(HashableBoxable(int:0)))
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
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
    }
    
    func testSetOfMustacheBoxable() {
        do {
            // Explicit type
            let value: Set<HashableBoxable> = [HashableBoxable(int:0),HashableBoxable(int:1),HashableBoxable(int:2)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
        do {
            // Infered element type
            let value: Set = [HashableBoxable(int:0),HashableBoxable(int:1),HashableBoxable(int:2)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertTrue(["012", "021", "102", "120", "201", "210"].index(of: rendering) != nil)
        }
    }
    
    func testDictionaryOfInt() {
        do {
            // Explicit type
            let value: Dictionary<String, Int> = ["name": 0]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: Dictionary<String, MustacheBoxable> = ["name": 0]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": 0]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": 0]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": 0])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfOptionalInt() {
        do {
            // Explicit type
            let value: Dictionary<String, Int?> = ["name": 0]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: Dictionary<String, MustacheBoxable?> = ["name": Optional.some(0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": Optional.some(0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": Optional.some(0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": Optional.some(0)])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfMustacheBoxable() {
        do {
            // Explicit type
            let value: Dictionary<String, HashableBoxable> = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable
            let value: Dictionary<String, MustacheBoxable> = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": HashableBoxable(int:0)])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfOptionalMustacheBoxable() {
        do {
            // Explicit type
            let value: Dictionary<String, HashableBoxable?> = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // As MustacheBoxable?
            let value: Dictionary<String, MustacheBoxable?> = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered element type
            let value: Dictionary = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Infered type
            let value = ["name": HashableBoxable(int:0)]
            let template = try! Template(string: "{{name}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{name}}")
            let box = Box(["name": HashableBoxable(int:0)])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1")
        }
    }
    
    func testDictionaryOfAny() {
        do {
            // Explicit type
            let value: Dictionary<String, Any> = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // As MustacheBoxable
            let value: Dictionary<String, MustacheBoxable> = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered element type
            let value: Dictionary = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type
            let value = ["int": 1, "string": "foo"]
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int}}, {{string}}")
            let box = Box(["int": 1, "string": "foo"])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo")
        }
    }
    
    func testDictionaryOfOptionalAny() {
        do {
            // Explicit type
            let value: Dictionary<String, Any?> = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // As MustacheBoxable?
            let value: Dictionary<String, MustacheBoxable?> = ["int": 1, "string": "foo", "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered element type
            let value: Dictionary = ["int": Optional.some(1), "string": Optional.some("foo"), "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type
            let value = ["int": Optional.some(1), "string": Optional.some("foo"), "missing": nil]
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
        do {
            // Infered type
            let template = try! Template(string: "{{int}}, {{string}}, {{missing}}")
            let box = Box(["int": Optional.some(1), "string": Optional.some("foo"), "missing": nil])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "1, foo, ")
        }
    }
    
    func testArrayOfInt() {
        do {
            // Explicit type
            let value: Array<Int> = [0,1,2,3]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable
            let value: Array<MustacheBoxable> = [0,1,2,3]
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
    
    func testArrayOfOptionalInt() {
        do {
            // Explicit type
            let value: Array<Int?> = [0,1,2,3,nil]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable?
            let value: Array<MustacheBoxable?> = [0,1,2,3,nil]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [Optional.some(0),Optional.some(1),Optional.some(2),Optional.some(3),Optional.none]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type: won't compile
            let value = [Optional.some(0),Optional.some(1),Optional.some(2),Optional.some(3),Optional.none]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([0,1,2,3,nil])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    func testArrayOfMustacheBoxable() {
        do {
            // Explicit type
            let value: Array<HashableBoxable> = [HashableBoxable(int:0), HashableBoxable(int:1), HashableBoxable(int:2), HashableBoxable(int:3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable
            let value: Array<MustacheBoxable> = [HashableBoxable(int:0), HashableBoxable(int:1), HashableBoxable(int:2), HashableBoxable(int:3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [HashableBoxable(int:0), HashableBoxable(int:1), HashableBoxable(int:2), HashableBoxable(int:3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [HashableBoxable(int:0), HashableBoxable(int:1), HashableBoxable(int:2), HashableBoxable(int:3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([HashableBoxable(int:0), HashableBoxable(int:1), HashableBoxable(int:2), HashableBoxable(int:3)])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
    }

    func testArrayOfOptionalMustacheBoxable() {
        do {
            // Explicit type
            let value: Array<HashableBoxable?> = [HashableBoxable(int:0), HashableBoxable(int:1), HashableBoxable(int:2), HashableBoxable(int:3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // As MustacheBoxable?
            let value: Array<MustacheBoxable?> = [HashableBoxable(int:0), HashableBoxable(int:1), HashableBoxable(int:2), HashableBoxable(int:3)]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered element type
            let value: Array = [Optional.some(HashableBoxable(int:0)), Optional.some(HashableBoxable(int:1)), Optional.some(HashableBoxable(int:2)), Optional.some(HashableBoxable(int:3))]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Infered type
            let value = [Optional.some(HashableBoxable(int:0)), Optional.some(HashableBoxable(int:1)), Optional.some(HashableBoxable(int:2)), Optional.some(HashableBoxable(int:3))]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([Optional.some(HashableBoxable(int:0)), Optional.some(HashableBoxable(int:1)), Optional.some(HashableBoxable(int:2)), Optional.some(HashableBoxable(int:3))])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0123")
        }
    }
    
    func testArrayOfAny() {
        do {
            // Explicit type
            let value: Array<Any> = [0,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // As MustacheBoxable
            let value: Array<MustacheBoxable> = [0,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type
            let value: Array = [0,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type
            let value = [0,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([0,"foo"])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    func testArrayOfOptionalAny() {
        do {
            // Explicit type
            let value: Array<Any?> = [0,nil,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // As MustacheBoxable?
            let value: Array<MustacheBoxable?> = [0,nil,"foo"]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered element type
            let value: Array = [Optional.some(0),nil,Optional.some("foo")]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Infered type
            let value = [Optional.some(0),nil,Optional.some("foo")]
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box(value)
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
        do {
            // Direct Box argument
            let template = try! Template(string: "{{#.}}{{.}}{{/}}")
            let box = Box([Optional.some(0),nil,Optional.some("foo")])
            let rendering = try! template.render(box)
            XCTAssertEqual(rendering, "0foo")
        }
    }
    
    func testArrayOfNonMustacheBoxable() {
        class Class { }
        let array: Array<Any> = [Class()]
        let context = Context(Box(array))
        let box = context.mustacheBoxForKey("first")
        XCTAssertTrue(box.value == nil)
    }
    
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
    
    func testRange() {
        let value = 0..<10
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "0123456789")
    }
}
