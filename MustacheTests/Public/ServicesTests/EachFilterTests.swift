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

class EachFilterTests: XCTestCase {
    
    func testEachFilterEnumeratesSet() {
        let set = Set(["a", "b"])
        let template = Template(string: "{{#each(set)}}({{@index}},{{.}}){{/}}")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        let rendering = template.render(Box(["set": set]))!
        XCTAssertTrue(find(["(0,a)(1,b)", "(0,b)(1,a)"], rendering) != nil)
    }
    
    func testEachFilterEnumeratesNSSet() {
        let set = NSSet(objects: "a", "b")
        let template = Template(string: "{{#each(set)}}({{@index}},{{.}}){{/}}")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        let rendering = template.render(Box(["set": set]))!
        XCTAssertTrue(find(["(0,a)(1,b)", "(0,b)(1,a)"], rendering) != nil)
    }
    
    func testEachFilterTriggersRenderFunctionsInArray() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("<\(rendering.string)>", rendering.contentType)
        }
        let box = Box(["array": Box([Box(render)])])
        let template = Template(string: "{{#each(array)}}{{@index}}{{/}}")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "<0>")
    }

    func testEachFilterTriggersRenderFunctionsInDictionary() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("<\(rendering.string)>", rendering.contentType)
        }
        let box = Box(["dictionary": Box(["a": Box(render)])])
        let template = Template(string: "{{#each(dictionary)}}{{@key}}{{/}}")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "<a>")
    }
    
    func testEachFilterDoesNotMessWithItemValues() {
        let increment = Filter { (int: Int?, _) -> MustacheBox? in
            return Box(int! + 1)
        }
        let items = [1,2,3]
        let template = Template(string: "{{#each(items)}}({{@index}},{{increment(.)}}){{/}}")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        template.registerInBaseContext("increment", Box(increment))
        let rendering = template.render(Box(["items": items]))!
        XCTAssertEqual(rendering, "(0,2)(1,3)(2,4)")
    }
    
    func testEachFilterDoesNotMessWithItemKeyedSubscriptFunction() {
        let items = ["a","bb","ccc"]
        let template = Template(string: "{{#each(items)}}({{@index}},{{length}}){{/}}")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        let rendering = template.render(Box(["items": items]))!
        XCTAssertEqual(rendering, "(0,1)(1,2)(2,3)")
    }
    
    func testEachFilterDoesNotMessWithItemRenderFunction() {
        let item = Lambda { "foo" }
        let items = [Box(item)]
        let template = Template(string: "{{#each(items)}}({{@index}},{{.}}){{/}}")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))
        let rendering = template.render(Box(["items": items]))!
        XCTAssertEqual(rendering, "(0,foo)")
    }
}
