//
//  MustacheRenderableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class MustacheRenderableTests: XCTestCase {

    func testRenderablePerformsVariableRendering() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderablePerformsSectionRendering() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfEscapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfUnescapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfEscapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectExplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectImplicitTextRenderingOfEscapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
}
