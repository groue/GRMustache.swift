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
    
    func testCustomValueExtraction() {
        // Test that one can extract a custom value from MustacheBox.
        
        struct BoxableStruct {
            let name: String
            func mustacheBox() -> MustacheBox {
                return MustacheBox(value: self)
            }
        }
        
        struct Struct {
            let name: String
        }
        
        class BoxableClass {
            let name: String
            init(name: String) {
                self.name = name
            }
            func mustacheBox() -> MustacheBox {
                return MustacheBox(value: self)
            }
        }
        
        class Class {
            let name: String
            init(name: String) {
                self.name = name
            }
        }
        
        let boxableStruct = BoxableStruct(name: "BoxableStruct")
        let boxableClass = BoxableClass(name: "BoxableClass")
        let optionalBoxableClass: BoxableClass? = BoxableClass(name: "BoxableClass")
        let NSObject = NSDate()
        
        let boxedBoxableStruct = boxableStruct.mustacheBox()
        let boxedStruct = MustacheBox(value: Struct(name: "Struct"))
        let boxedBoxableClass = boxableClass.mustacheBox()
        let boxedOptionalBoxableClass = optionalBoxableClass!.mustacheBox()
        let boxedClass = MustacheBox(value: Class(name: "Class"))
        let boxedNSObject = Box(NSObject)
        
        let extractedBoxableStruct = boxedBoxableStruct.value as! BoxableStruct
        let extractedStruct = boxedStruct.value as! Struct
        let extractedBoxableClass = boxedBoxableClass.value as! BoxableClass
        let extractedOptionalBoxableClass = boxedOptionalBoxableClass.value as? BoxableClass
        let extractedClass = boxedClass.value as! Class
        let extractedNSObject = boxedNSObject.value as! NSDate
        
        XCTAssertEqual(extractedBoxableStruct.name, "BoxableStruct")
        XCTAssertEqual(extractedStruct.name, "Struct")
        XCTAssertEqual(extractedBoxableClass.name, "BoxableClass")
        XCTAssertEqual(extractedOptionalBoxableClass!.name, "BoxableClass")
        XCTAssertEqual(extractedClass.name, "Class")
        XCTAssertEqual(extractedNSObject, NSObject)
    }
    
    // TODO: why is this test commented out?
//    func testCustomValueFilter() {
//        // Test that one can define a filter taking a CustomValue as an argument.
//        
//        struct Boxable : MustacheBoxable {
//            let name: String
//            var mustacheBox: MustacheBox {
//                return Box(value: self)
//            }
//        }
//        
//        let filter1 = { (value: Boxable?) -> MustacheBox in
//            if let value = value {
//                return Box(value.name)
//            } else {
//                return Box("other")
//            }
//        }
//        
//        let filter2 = { (value: Boxable?) -> MustacheBox in
//            if let value = value {
//                return Box(value.name)
//            } else {
//                return Box("other")
//            }
//        }
//        
//        let filter3 = { (value: NSDate?) -> MustacheBox in
//            if let value = value {
//                return Box("custom3")
//            } else {
//                return Box("other")
//            }
//        }
//        
//        let template = Template(string:"{{f(custom)}},{{f(string)}}")!
//        
//        let value1 = Box([
//            "string": Box("success"),
//            "custom": Box(Boxable(name: "custom1")),
//            "f": Box(Filter(filter1))
//            ])
//        let rendering1 = template.render(value1)!
//        XCTAssertEqual(rendering1, "custom1,other")
//        
//        let value2 = Box([
//            "string": Box("success"),
//            "custom": Box(value: Boxable(name: "custom2")),
//            "f": Box(Filter(filter2))])
//        let rendering2 = template.render(value2)!
//        XCTAssertEqual(rendering2, "custom2,other")
//        
//        let value3 = Box([
//            "string": Box("success"),
//            "custom": Box(NSDate()),
//            "f": Box(Filter(filter3))])
//        let rendering3 = template.render(value3)!
//        XCTAssertEqual(rendering3, "custom3,other")
//    }
    
    func testSetOfInt() {
        let value: Set<Int> = [0,1,2]
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertTrue(["012", "021", "102", "120", "201", "210"].indexOf(rendering) != nil)
    }
    
    func testSetOfMustacheBoxable() {
        let value: Set<HashableBoxable> = [HashableBoxable(int:0),HashableBoxable(int:1),HashableBoxable(int:2)]
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertTrue(["012", "021", "102", "120", "201", "210"].indexOf(rendering) != nil)
    }
    
    func testDictionaryOfInt() {
        let value: Dictionary<String, Int> = ["name": 1]
        let template = try! Template(string: "{{name}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "1")
    }
    
    func testDictionaryOfOptionalInt() {
        let value: Dictionary<String, Int?> = ["name": 1]
        let template = try! Template(string: "{{name}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "1")
    }
    
    func testArrayOfInt() {
        let value: Array<Int> = [0,1,2,3]
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "0123")
    }
    
    func testArrayOfOptionalInt() {
        let value: Array<Int?> = [0,1,2,3, nil]
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "0123")
    }
    
    func testArrayOfArrayOfInt() {
        let value: Array<Array<Int>> = [[0,1],[2,3]]
        let template = try! Template(string: "{{#.}}[{{#.}}{{.}},{{/}}],{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "[0,1,],[2,3,],")
    }
    
    func testArrayOfArrayOfArrayOfInt() {
        let value: Array<Array<Array<Int>>> = [[[0,1],[2,3]], [[4,5],[6,7]]]
        let template = try! Template(string: "{{#.}}[{{#.}}[{{#.}}{{.}},{{/}}],{{/}}],{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "[[0,1,],[2,3,],],[[4,5,],[6,7,],],")
    }
    
    func testArrayOfArrayOfArrayOfDictionaryOfInt() {
        let value: Array<Array<Array<Dictionary<String, Int>>>> = [[[["a":0],["a":1]],[["a":2],["a":3]]], [[["a":4],["a":5]],[["a":6],["a":7]]]]
        let template = try! Template(string: "{{#.}}[{{#.}}[{{#.}}{{a}},{{/}}],{{/}}],{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "[[0,1,],[2,3,],],[[4,5,],[6,7,],],")
    }

    func testDictionaryOfArrayOfArrayOfArrayOfDictionaryOfInt() {
        let value: Dictionary<String, Array<Array<Array<Dictionary<String, Int>>>>> = ["a": [[[["1": 1], ["2": 2]], [["3": 3], ["4": 4]]], [[["5": 5], ["6": 6]], [["7": 7], ["8": 8]]]]]
        let template = try! Template(string: "{{#a}}[{{#.}}[{{#.}}[{{#each(.)}}{{@key}}:{{.}}{{/}}]{{/}}]{{/}}]{{/}}")
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "[[[1:1][2:2]][[3:3][4:4]]][[[5:5][6:6]][[7:7][8:8]]]")
    }
    
    func testRange() {
        let value = 0..<10
        let template = try! Template(string: "{{#.}}{{.}}{{/}}")
        let box = Box(value)
        let rendering = try! template.render(box)
        XCTAssertEqual(rendering, "0123456789")
    }
    
    func testArrayValueForArray() {
        let originalValue = [1,2,3]
        let box = Box(originalValue)
        let extractedValue = box.value as! [Int]
        XCTAssertEqual(extractedValue, originalValue)
        let extractedArray: [MustacheBox] = box.arrayValue!
        XCTAssertEqual(extractedArray.map { $0.value as! Int }, [1,2,3])
    }
    
    func testArrayValueForNSArray() {
        let originalValue = NSArray(object: "foo")
        let box = Box(originalValue)
        let extractedValue = box.value as! NSArray
        XCTAssertEqual(extractedValue, originalValue)
        let extractedArray: [MustacheBox] = box.arrayValue!
        XCTAssertEqual(extractedArray.map { $0.value as! String }, ["foo"])
    }
    
    func testArrayValueForNSOrderedSet() {
        let originalValue = NSOrderedSet(object: "foo")
        let box = Box(originalValue)
        let extractedValue = box.value as! NSOrderedSet
        XCTAssertEqual(extractedValue, originalValue)
        let extractedArray: [MustacheBox] = box.arrayValue!
        XCTAssertEqual(extractedArray.map { $0.value as! String }, ["foo"])
    }
    
    func testArrayValueForCollectionOfOne() {
        let originalValue = CollectionOfOne(123)
        let box = Box(originalValue)
        let extractedValue = box.value as! CollectionOfOne<Int>
        XCTAssertEqual(extractedValue[extractedValue.startIndex], originalValue[originalValue.startIndex])
        let extractedArray: [MustacheBox] = box.arrayValue!
        XCTAssertEqual(extractedArray.map { $0.value as! Int }, [123])
    }
    
    func testArrayValueForRange() {
        let originalValue = 1...3
        let box = Box(originalValue)
        let extractedValue = box.value as! Range<Int>
        XCTAssertEqual(extractedValue, originalValue)
        let extractedArray: [MustacheBox] = box.arrayValue!
        XCTAssertEqual(extractedArray.map { $0.value as! Int }, [1,2,3])
    }
    
    func testDictionaryValueForNSDictionary() {
        let originalValue = NSDictionary(object: "value", forKey: "key")
        let box = Box(originalValue)
        let extractedValue = box.value as! NSDictionary
        XCTAssertEqual(extractedValue, originalValue)
        let extractedDictionary: [String: MustacheBox] = box.dictionaryValue!
        XCTAssertEqual((extractedDictionary["key"]!.value as! String), "value")
    }
    
    func testBoxNSArrayOfMustacheBoxable() {
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
    
    func testBoxNSArrayOfNonMustacheBoxable() {
        class Class {
        }
        
        let array = NSArray(object: Class())
        let context = Context(Box(array))
        let box = context.mustacheBoxForKey("first")
        XCTAssertTrue(box.value == nil)
    }
}
