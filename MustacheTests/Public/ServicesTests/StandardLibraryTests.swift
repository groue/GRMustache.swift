//
//  StandardLibraryTests.swift
//
//  Created by Gwendal Roué on 20/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class StandardLibraryTests: XCTestCase {
    
    func testStandardLibraryHTMLEscapeDoesEscapeText() {
        let render = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<")
        })
        
        var template = Template(string: "{{# HTMLEscape }}{{ object }}{{/ }}")!
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        var rendering = template.render(Box(["object": render]))!
        XCTAssertEqual(rendering, "&amp;lt;")
        
        template = Template(string: "{{# HTMLEscape }}{{{ object }}}{{/ }}")!
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        rendering = template.render(Box(["object": render]))!
        XCTAssertEqual(rendering, "&lt;")
    }
    
    func testStandardLibraryHTMLEscapeDoesEscapeHTML() {
        let render = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<br>", .HTML)
        })
        
        var template = Template(string: "{{# HTMLEscape }}{{ object }}{{/ }}")!
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        var rendering = template.render(Box(["object": render]))!
        XCTAssertEqual(rendering, "&lt;br&gt;")
        
        template = Template(string: "{{# HTMLEscape }}{{{ object }}}{{/ }}")!
        template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
        rendering = template.render(Box(["object": render]))!
        XCTAssertEqual(rendering, "&lt;br&gt;")
    }
    
    func testStandardLibraryJavascriptEscapeDoesEscapeRenderFunction() {
        let render = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("\"double quotes\" and 'single quotes'")
        })
        
        let template = Template(string: "{{# javascriptEscape }}{{ object }}{{/ }}")!
        template.registerInBaseContext("javascriptEscape", Box(StandardLibrary.javascriptEscape))
        
        let rendering = template.render(Box(["object": render]))!
        XCTAssertEqual(rendering, "\\u0022double quotes\\u0022 and \\u0027single quotes\\u0027")
    }
    
    func testStandardLibraryURLEscapeDoesEscapeRenderFunctions() {
        let render = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        })
        
        let template = Template(string: "{{# URLEscape }}{{ object }}{{/ }}")!
        template.registerInBaseContext("URLEscape", Box(StandardLibrary.URLEscape))
        
        let rendering = template.render(Box(["object": render]))!
        XCTAssertEqual(rendering, "%26")
    }
}
