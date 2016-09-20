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

class StandardLibraryTests: XCTestCase {
    
    func testStandardLibraryHTMLEscapeDoesEscapeText() {
        let render = Box({ (info: RenderingInfo) -> Rendering in
            return Rendering("<")
        })
        
        var template = try! Template(string: "{{# HTMLEscape }}{{ object }}{{/ }}")
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        var rendering = try! template.render(Box(["object": render]))
        XCTAssertEqual(rendering, "&amp;lt;")
        
        template = try! Template(string: "{{# HTMLEscape }}{{{ object }}}{{/ }}")
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        rendering = try! template.render(Box(["object": render]))
        XCTAssertEqual(rendering, "&lt;")
    }
    
    func testStandardLibraryHTMLEscapeDoesEscapeHTML() {
        let render = Box({ (info: RenderingInfo) -> Rendering in
            return Rendering("<br>", .html)
        })
        
        var template = try! Template(string: "{{# HTMLEscape }}{{ object }}{{/ }}")
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        var rendering = try! template.render(Box(["object": render]))
        XCTAssertEqual(rendering, "&lt;br&gt;")
        
        template = try! Template(string: "{{# HTMLEscape }}{{{ object }}}{{/ }}")
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        rendering = try! template.render(Box(["object": render]))
        XCTAssertEqual(rendering, "&lt;br&gt;")
    }
    
    func testStandardLibraryJavascriptEscapeDoesEscapeRenderFunction() {
        let render = Box({ (info: RenderingInfo) -> Rendering in
            return Rendering("\"double quotes\" and 'single quotes'")
        })
        
        let template = try! Template(string: "{{# javascriptEscape }}{{ object }}{{/ }}")
        template.registerInBaseContext("javascriptEscape", Box(StandardLibrary.javascriptEscape))
        
        let rendering = try! template.render(Box(["object": render]))
        XCTAssertEqual(rendering, "\\u0022double quotes\\u0022 and \\u0027single quotes\\u0027")
    }
    
    func testStandardLibraryURLEscapeDoesEscapeRenderFunctions() {
        let render = Box({ (info: RenderingInfo) -> Rendering in
            return Rendering("&")
        })
        
        let template = try! Template(string: "{{# URLEscape }}{{ object }}{{/ }}")
        template.registerInBaseContext("URLEscape", Box(StandardLibrary.URLEscape))
        
        let rendering = try! template.render(Box(["object": render]))
        XCTAssertEqual(rendering, "%26")
    }
}
