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
    
    class ClassWithObjectForKeyedSubscript: NSObject, GRMustacheSafeKeyAccess {
        class func safeMustacheKeys() -> NSSet {
            return NSSet(objects: "foo", "bar")
        }
        
        func objectForKeyedSubscript(key: String) -> AnyObject? {
            return key
        }
        
        override func valueForKey(key: String) -> AnyObject? {
            return key.uppercaseString
        }
    }
    
    class ClassWithProperties: NSObject {
        let property: String = "property"
        func method() -> String { return "method" }
    }
    
    class ClassWithCustomSafeMustacheKeys: NSObject, GRMustacheSafeKeyAccess {
        let disallowedProperty: String = "disallowedProperty"

        class func safeMustacheKeys() -> NSSet {
            return NSSet(object: "allowedMethod")
        }
        
        func allowedMethod() -> String {
            return "allowedMethod"
        }
    }


    func testObjectForKeyedSubscriptReplacesValueForKey() {
        let object = ClassWithObjectForKeyedSubscript()
        
        // test setup
        XCTAssertTrue(object.dynamicType.respondsToSelector("safeMustacheKeys"))
        XCTAssertTrue(object.dynamicType.safeMustacheKeys().containsObject("foo"))
        XCTAssertTrue(object.dynamicType.safeMustacheKeys().containsObject("bar"))
        XCTAssertEqual(object.objectForKeyedSubscript("foo") as String, "foo")
        XCTAssertEqual(object.objectForKeyedSubscript("bar") as String, "bar")
        XCTAssertEqual(object.valueForKey("foo") as String, "FOO")
        XCTAssertEqual(object.valueForKey("bar") as String, "BAR")
        
        // test context
        let context = Context(Box(object))
        XCTAssertEqual(context["foo"].value as String, "foo")
        XCTAssertEqual(context["bar"].value as String, "bar")
        
        // test that GRMustacheSafeKeyAccess is not used
        XCTAssertEqual(context["baz"].value as String, "baz")
    }
    
    func testPropertiesAreSafeAndAvailable() {
        let object = ClassWithProperties()
    
        // test setup
        XCTAssertFalse(object.dynamicType.respondsToSelector("safeMustacheKeys"))
        XCTAssertFalse(object.respondsToSelector("objectForKeyedSubscript:"))
        XCTAssertEqual(object.property, "property")
        XCTAssertEqual(object.valueForKey("property") as String, "property")
        
        // test context
        let context = Context(Box(object))
        XCTAssertEqual(context["property"].value as String, "property")
    }

    func testMethodsAreUnsafeAndNotAvailable() {
        let object = ClassWithProperties()
        
        // test setup
        XCTAssertFalse(object.dynamicType.respondsToSelector("safeMustacheKeys"))
        XCTAssertFalse(object.respondsToSelector("objectForKeyedSubscript:"))
        XCTAssertEqual(object.method(), "method")
        XCTAssertEqual(object.valueForKey("method") as String, "method")
    
        // test context
        let context = Context(Box(object))
        XCTAssertTrue(context["method"].value == nil)
    }
    
    func testCustomSafeMustacheKeys() {
        let object = ClassWithCustomSafeMustacheKeys()
        
        // test setup
        XCTAssertTrue(object.dynamicType.respondsToSelector("safeMustacheKeys"))
        XCTAssertTrue(object.dynamicType.safeMustacheKeys().containsObject("allowedMethod"))
        XCTAssertFalse(object.dynamicType.safeMustacheKeys().containsObject("disallowedProperty"))
        XCTAssertFalse(object.respondsToSelector("objectForKeyedSubscript:"))
        XCTAssertEqual(object.disallowedProperty, "disallowedProperty")
        XCTAssertEqual(object.allowedMethod(), "allowedMethod")
        XCTAssertEqual(object.valueForKey("disallowedProperty") as String, "disallowedProperty")
        XCTAssertEqual(object.valueForKey("allowedMethod") as String, "allowedMethod")
    
        // test context
        let context = Context(Box(object))
        XCTAssertTrue(context["disallowedProperty"].value == nil)
        XCTAssertEqual(context["allowedMethod"].value as String, "allowedMethod")
    }
}
