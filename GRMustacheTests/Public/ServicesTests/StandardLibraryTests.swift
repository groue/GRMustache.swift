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
        // From Value
        let standardLibrary = StandardLibrary()
        XCTAssertNotNil(standardLibrary.valueForMustacheKey("localize")!.object() as Localizer?)
        
        // From Context
        let context = Context(Value(standardLibrary))
        let localizerValue = context["localize"]
        XCTAssertNotNil(localizerValue.object() as Localizer?)
    }
    
    func testStandardLibraryHTMLEscapeDoesEscapeText() {
        let renderable = Value({ (renderingInfo: RenderingInfo) -> (Rendering) in
            return .Success("<", .Text)
        })
        
        var template = Template(string: "{{# HTML.escape }}{{ object }}{{/ }}")!
        var rendering = template.render(Value(["object": renderable]))!
        XCTAssertEqual(rendering, "&amp;lt;")
        
        template = Template(string: "{{# HTML.escape }}{{{ object }}}{{/ }}")!
        rendering = template.render(Value(["object": renderable]))!
        XCTAssertEqual(rendering, "&lt;")
    }
    
    
    func testStandardLibraryHTMLEscapeDoesEscapeHTML() {
        let renderable = Value({ (renderingInfo: RenderingInfo) -> (Rendering) in
            return .Success("<br>", .HTML)
        })
        
        var template = Template(string: "{{# HTML.escape }}{{ object }}{{/ }}")!
        var rendering = template.render(Value(["object": renderable]))!
        XCTAssertEqual(rendering, "&lt;br&gt;")
        
        template = Template(string: "{{# HTML.escape }}{{{ object }}}{{/ }}")!
        rendering = template.render(Value(["object": renderable]))!
        XCTAssertEqual(rendering, "&lt;br&gt;")
    }
    
    func testStandardLibraryJavascriptEscapeDoesEscapeRenderable() {
        let renderable = Value({ (renderingInfo: RenderingInfo) -> (Rendering) in
            return .Success("\"double quotes\" and 'single quotes'", .Text)
        })
        let template = Template(string: "{{# javascript.escape }}{{ object }}{{/ }}")!
        let rendering = template.render(Value(["object": renderable]))!
        XCTAssertEqual(rendering, "\\u0022double quotes\\u0022 and \\u0027single quotes\\u0027")
    }
    
    func testStandardLibraryURLEscapeDoesEscapeRenderingObjects() {
        let renderable = Value({ (renderingInfo: RenderingInfo) -> (Rendering) in
            return .Success("&", .Text)
        })
        let template = Template(string: "{{# URL.escape }}{{ object }}{{/ }}")!
        let rendering = template.render(Value(["object": renderable]))!
        XCTAssertEqual(rendering, "%26")
    }
}
