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
    
    func testRenderableObjectCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{subject}}{{/.}}", error: nil)
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{^.}}{{#.}}{{subject}}{{/.}}", error: nil)
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRenderableObjectCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderableObjectCanAccessRenderedContentFromSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        MustacheTemplate.render(value, fromString: "{{#renderable}}{{subject}}={{subject}}{{/renderable}}", error: nil)
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromExtensionSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        MustacheTemplate.render(value, fromString: "{{^renderable}}{{#renderable}}{{subject}}={{subject}}{{/renderable}}", error: nil)
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromEscapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: nil)
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromUnescapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            renderedContent = renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        })
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}", error: nil)
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
}
