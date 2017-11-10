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
    
    func testBoxValue() {
        // Test how values can be extracted from boxes
        
        struct BoxableStruct : MustacheBoxable {
            var mustacheBox: MustacheBox {
                return MustacheBox(value: self)
            }
        }
        
        class BoxableClass : MustacheBoxable {
            init() {
            }
            var mustacheBox: MustacheBox {
                return MustacheBox(value: self)
            }
        }
        
        func assert<T>(value: Any, isBoxedAs: T.Type) {
            let template = try! Template(string: "{{#test(value)}}success{{/}}")
            let data: [String: Any] = [
                "value": value,
                "test": Filter { (box: MustacheBox) in
                    box.value is T
                }
            ]
            XCTAssertEqual(try! template.render(data), "success", "\(String(reflecting: value)) is not boxed as \(T.self)")
        }
        assert(value: BoxableStruct(), isBoxedAs: BoxableStruct.self)
        assert(value: BoxableClass(), isBoxedAs: BoxableClass.self)
        assert(value: NSObject(), isBoxedAs: NSObject.self)
        assert(value: NSDate(), isBoxedAs: NSDate.self)
        assert(value: Date(), isBoxedAs: Date.self)
        assert(value: [1, 2, 3], isBoxedAs: [Any?].self)
        assert(value: Set([1, 2, 3]), isBoxedAs: Set<AnyHashable>.self)
        assert(value: ["foo": 1], isBoxedAs: Dictionary<AnyHashable, Any?>.self)
        assert(value: NSArray(array: [1, 2, 3]), isBoxedAs: [Any?].self)
        assert(value: NSSet(array: [1, 2, 3]), isBoxedAs: Set<AnyHashable>.self)
        assert(value: NSDictionary(object: 1, forKey: "foo" as NSCopying), isBoxedAs: Dictionary<AnyHashable, Any?>.self)
    }
}
