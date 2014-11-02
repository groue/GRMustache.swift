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
    
    func testRenderableObjectExplicitHTMLRenderingOfSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectCanSetErrorFromVariableTag() {
        let errorDomain = "MustacheRenderableTests"
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        })
        var error: NSError?
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanSetErrorFromSectionTag() {
        let errorDomain = "MustacheRenderableTests"
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        })
        var error: NSError?
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromVariableTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "<{{.}}>", error: nil)!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromSectionTag() {
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        })
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "<{{#.}}{{/.}}>", error: nil)!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanAccessVariableTagType() {
        var variableTagDetections = 0
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch renderingInfo.tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch renderingInfo.tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: nil)
        XCTAssertEqual(sectionTagDetections, 1)
    }
}
