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

class ObjcKeyAccessTests: XCTestCase {
    
    class ClassWithProperties: NSObject {
        let property: String = "property"
        func method() -> String { return "method" }
    }
    
    func testPropertiesAreSafeAndAvailable() {
        let object = ClassWithProperties()
    
        // test setup
        XCTAssertEqual(object.property, "property")
        XCTAssertEqual((object.value(forKey: "property") as! String), "property")
        
        // test context
        let context = Context(Box(object))
        XCTAssertEqual((context.mustacheBoxForKey("property").value as! String), "property")
    }

    func testMethodsAreUnsafeAndNotAvailable() {
        let object = ClassWithProperties()
        
        // test setup
        XCTAssertEqual(object.method(), "method")
        XCTAssertEqual((object.value(forKey: "method") as! String), "method")
    
        // test context
        let context = Context(Box(object))
        XCTAssertTrue(context.mustacheBoxForKey("method").value == nil)
    }
}
