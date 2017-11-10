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
        
        static
        let property1Name = "property1"
        
        static
        let property1Value = "property1Value"
        
        static
        let method2Name = "method2"
        
        static
        let method2ReturnValue = "method2ReturnValue"
        
        @objc let property1: String = ClassWithProperties.property1Value
        @objc func method2() -> String { return ClassWithProperties.method2ReturnValue }
    }
    
    func testPropertiesAreSafeAndAvailable() {
        let object = ClassWithProperties()
    
        // test setup
        XCTAssertEqual(object.property1, ClassWithProperties.property1Value)
        XCTAssertEqual((object.value(forKey: ClassWithProperties.property1Name) as! String), ClassWithProperties.property1Value)
        
        // test context
        let context = Context(object)
        XCTAssertEqual((context.mustacheBox(forKey: "property1").value as! String), ClassWithProperties.property1Value)
    }

    func testMethodsAreUnsafeAndNotAvailable() {
        let object = ClassWithProperties()
        
        // test setup
        XCTAssertEqual(object.method2(),
                       ClassWithProperties.method2ReturnValue)
        
        XCTAssertEqual((object.value(forKey: ClassWithProperties.method2Name) as! String),
                       ClassWithProperties.method2ReturnValue)
    
        // test context
        let context = Context(object)
        XCTAssertTrue(context.mustacheBox(forKey: ClassWithProperties.method2Name).value == nil)
    }
}
