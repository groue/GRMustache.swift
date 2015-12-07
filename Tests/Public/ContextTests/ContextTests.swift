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

class ContextTests: XCTestCase {
    
    func testContextWithValueConstructor() {
        let template = try! Template(string: "{{foo}}")
        
        var rendering = try! template.render()
        XCTAssertEqual(rendering, "")
        
        let box = Box(["foo": "bar"])
        template.baseContext = Context(box)
        rendering = try! template.render()
        XCTAssertEqual(rendering, "bar")
    }
    
    func testContextWithProtectedObjectConstructor() {
        // TODO: import test from GRMustache
    }
    
    func testContextWithWillRenderFunction() {
        var success = false
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
            success = true
            return box
        }
        let template = try! Template(string: "{{success}}")
        template.baseContext = Context(Box(willRender))
        try! template.render()
        XCTAssertTrue(success)
    }
    
    func testTopMustacheValue() {
        var context = Context()
        XCTAssertTrue(context.topBox.isEmpty)
        
        context = context.extendedContext(Box("object"))
        XCTAssertEqual((context.topBox.value as! String), "object")
        
        // TODO: import protected test from GRMustacheContextTopMustacheObjectTest.testTopMustacheObject
        
        // TODO: check if those commented lines are worth decommenting
//        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
//            return box
//        }
//        context = context.extendedContext(Box(willRender))
//        XCTAssertEqual(context.topBox.value as String, "object")

        context = context.extendedContext(Box("object2"))
        XCTAssertEqual((context.topBox.value as! String), "object2")
    }
    
    func testSubscript() {
        let context = Context(Box(["name": "name1", "a": ["name": "name2"]]))
        
        // '.' is an expression, not a key
        XCTAssertTrue(context.mustacheBoxForKey(".").isEmpty)
        
        // 'name' is a key
        XCTAssertEqual((context.mustacheBoxForKey("name").value as! String), "name1")
        
        // 'a.name' is an expression, not a key
        XCTAssertTrue(context.mustacheBoxForKey("a.name").isEmpty)
    }
}
