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

class BoxValueTests: XCTestCase {
    
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
        let nsObject = NSDate()
        let referenceConvertible = Date()
        
        let boxedBoxableStruct = boxableStruct.mustacheBox()
        let boxedStruct = MustacheBox(value: Struct(name: "Struct"))
        let boxedBoxableClass = boxableClass.mustacheBox()
        let boxedOptionalBoxableClass = optionalBoxableClass!.mustacheBox()
        let boxedClass = MustacheBox(value: Class(name: "Class"))
        let boxedNSObject = Box(nsObject)
        let boxedReferenceConvertible = Box(referenceConvertible)
        
        let extractedBoxableStruct = boxedBoxableStruct.value as! BoxableStruct
        let extractedStruct = boxedStruct.value as! Struct
        let extractedBoxableClass = boxedBoxableClass.value as! BoxableClass
        let extractedOptionalBoxableClass = boxedOptionalBoxableClass.value as? BoxableClass
        let extractedClass = boxedClass.value as! Class
        let extractedNSObject = boxedNSObject.value as! NSDate
        let extractedReferenceConvertible = boxedReferenceConvertible.value as! Date
        
        XCTAssertEqual(extractedBoxableStruct.name, "BoxableStruct")
        XCTAssertEqual(extractedStruct.name, "Struct")
        XCTAssertEqual(extractedBoxableClass.name, "BoxableClass")
        XCTAssertEqual(extractedOptionalBoxableClass!.name, "BoxableClass")
        XCTAssertEqual(extractedClass.name, "Class")
        XCTAssertEqual(extractedNSObject, nsObject)
        XCTAssertEqual(extractedReferenceConvertible, referenceConvertible)
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
    
    func testDictionaryValueForNSDictionary() {
        let originalValue = NSDictionary(object: "value", forKey: "key" as NSCopying)
        let box = Box(originalValue)
        let extractedValue = box.value as! NSDictionary
        XCTAssertEqual(extractedValue, originalValue)
        let extractedDictionary: [String: MustacheBox] = box.dictionaryValue!
        XCTAssertEqual((extractedDictionary["key"]!.value as! String), "value")
    }

}
