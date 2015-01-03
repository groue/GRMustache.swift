//
//  StandardLibraryTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 20/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

//class StandardLibraryTests: XCTestCase {
//    
//    func testStandardLibraryHasLocalizer() {
//        // From Box
//        let standardLibrary = StandardLibrary()
//        XCTAssertNotNil(standardLibrary.valueForMustacheKey("localize")!.value() as Localizer?)
//        
//        // From Context
//        let context = Context(Box(standardLibrary))
//        let localizerValue = context["localize"]
//        XCTAssertNotNil(localizerValue.value() as Localizer?)
//    }
//    
//    func testStandardLibraryHTMLEscapeDoesEscapeText() {
//        let renderer = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return Rendering("<")
//        })
//        
//        var template = Template(string: "{{# HTML.escape }}{{ object }}{{/ }}")!
//        var rendering = template.render(Box(["object": renderer]))!
//        XCTAssertEqual(rendering, "&amp;lt;")
//        
//        template = Template(string: "{{# HTML.escape }}{{{ object }}}{{/ }}")!
//        rendering = template.render(Box(["object": renderer]))!
//        XCTAssertEqual(rendering, "&lt;")
//    }
//    
//    func testStandardLibraryHTMLEscapeDoesEscapeHTML() {
//        let renderer = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return Rendering("<br>", .HTML)
//        })
//        
//        var template = Template(string: "{{# HTML.escape }}{{ object }}{{/ }}")!
//        var rendering = template.render(Box(["object": renderer]))!
//        XCTAssertEqual(rendering, "&lt;br&gt;")
//        
//        template = Template(string: "{{# HTML.escape }}{{{ object }}}{{/ }}")!
//        rendering = template.render(Box(["object": renderer]))!
//        XCTAssertEqual(rendering, "&lt;br&gt;")
//    }
//    
//    func testStandardLibraryJavascriptEscapeDoesEscapeRenderer() {
//        let renderer = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return Rendering("\"double quotes\" and 'single quotes'")
//        })
//        let template = Template(string: "{{# javascript.escape }}{{ object }}{{/ }}")!
//        let rendering = template.render(Box(["object": renderer]))!
//        XCTAssertEqual(rendering, "\\u0022double quotes\\u0022 and \\u0027single quotes\\u0027")
//    }
//    
//    func testStandardLibraryURLEscapeDoesEscapeRenderers() {
//        let renderer = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return Rendering("&")
//        })
//        let template = Template(string: "{{# URL.escape }}{{ object }}{{/ }}")!
//        let rendering = template.render(Box(["object": renderer]))!
//        XCTAssertEqual(rendering, "%26")
//    }
//}
