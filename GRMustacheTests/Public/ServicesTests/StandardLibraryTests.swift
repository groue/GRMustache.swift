//
//  StandardLibraryTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 20/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class StandardLibraryTests: XCTestCase {
    
    func testStandardLibraryHasLocalizer() {
        let context = Context(boxValue(StandardLibrary()))
        let localizer = context["localize"].value as? Localizer
        XCTAssertNotNil(localizer)
    }
    
    func testStandardLibraryHTMLEscapeDoesEscapeText() {
        let render = boxValue({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<")
        })
        
        var template = Template(string: "{{# HTML.escape }}{{ object }}{{/ }}")!
        var rendering = template.render(boxValue(["object": render]))!
        XCTAssertEqual(rendering, "&amp;lt;")
        
        template = Template(string: "{{# HTML.escape }}{{{ object }}}{{/ }}")!
        rendering = template.render(boxValue(["object": render]))!
        XCTAssertEqual(rendering, "&lt;")
    }
    
    func testStandardLibraryHTMLEscapeDoesEscapeHTML() {
        let render = boxValue({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<br>", .HTML)
        })
        
        var template = Template(string: "{{# HTML.escape }}{{ object }}{{/ }}")!
        var rendering = template.render(boxValue(["object": render]))!
        XCTAssertEqual(rendering, "&lt;br&gt;")
        
        template = Template(string: "{{# HTML.escape }}{{{ object }}}{{/ }}")!
        rendering = template.render(boxValue(["object": render]))!
        XCTAssertEqual(rendering, "&lt;br&gt;")
    }
    
    func testStandardLibraryJavascriptEscapeDoesEscapeRenderFunction() {
        let render = boxValue({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("\"double quotes\" and 'single quotes'")
        })
        let template = Template(string: "{{# javascript.escape }}{{ object }}{{/ }}")!
        let rendering = template.render(boxValue(["object": render]))!
        XCTAssertEqual(rendering, "\\u0022double quotes\\u0022 and \\u0027single quotes\\u0027")
    }
    
    func testStandardLibraryURLEscapeDoesEscapeRenderFunctions() {
        let render = boxValue({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        })
        let template = Template(string: "{{# URL.escape }}{{ object }}{{/ }}")!
        let rendering = template.render(boxValue(["object": render]))!
        XCTAssertEqual(rendering, "%26")
    }
}
