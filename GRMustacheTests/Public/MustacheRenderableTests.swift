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
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}")!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderablePerformsSectionRendering() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}")!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfEscapedVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}")!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfUnescapedVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}")!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfEscapedVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}")!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectExplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}")!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectImplicitTextRenderingOfEscapedVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}")!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}")!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfSectionTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}")!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfSectionTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}")!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfSectionTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}")!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectCanSetErrorFromVariableTag() {
        let errorDomain = "MustacheClusterTests"
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanSetErrorFromSectionTag() {
        let errorDomain = "MustacheClusterTests"
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "<{{.}}>")!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromSectionTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        }
        let rendering = MustacheTemplate.render(MustacheValue(renderable), fromString: "<{{#.}}{{/.}}>")!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanAccessVariableTagType() {
        var variableTagDetections = 0
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return nil
        }
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}")
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return nil
        }
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{/.}}")
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = tag.innerTemplateString
            return nil
        }
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{#.}}{{subject}}{{/.}}")
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = tag.innerTemplateString
            return nil
        }
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{^.}}{{#.}}{{subject}}{{/.}}")
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRenderableObjectCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = tag.innerTemplateString
            return nil
        }
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}")
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderableObjectCanAccessRenderedContentFromSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        MustacheTemplate.render(value, fromString: "{{#renderable}}{{subject}}={{subject}}{{/renderable}}")
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromExtensionSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        MustacheTemplate.render(value, fromString: "{{^renderable}}{{#renderable}}{{subject}}={{subject}}{{/renderable}}")
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromEscapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{.}}")
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromUnescapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        MustacheTemplate.render(MustacheValue(renderable), fromString: "{{{.}}}")
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = MustacheTemplate(string:"{{subject}}")!
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return altTemplate.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{renderable}}")!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = MustacheTemplate(string:"{{subject}}")!
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return altTemplate.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{#renderable}}{{/renderable}}")!
        XCTAssertEqual(rendering, "-")
    }

    func testRenderableObjectDoesNotAutomaticallyEntersVariableContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
                return MustacheValue("value")
            }
            func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return MustacheTemplate(string:"key:{{key}}")!.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
            }
        }
        let value = MustacheValue(["renderable": MustacheValue(TestedRenderable())])
        let rendering = MustacheTemplate.render(value, fromString: "{{renderable}}")!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectDoesNotAutomaticallyEntersSectionContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
                return MustacheValue("value")
            }
            func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                // TODO: "tag.renderContent(renderingInfo" is not a nice API.
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        }
        let value = MustacheValue(["renderable": MustacheValue(TestedRenderable())])
        let rendering = MustacheTemplate.render(value, fromString: "{{#renderable}}key:{{key}}{{/renderable}}")!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectCanExtendValueContextStackInVariableTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(["subject2": MustacheValue("+++")]))
            let template = MustacheTemplate(string: "{{subject}}{{subject2}}")!
            return template.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{renderable}}")!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendValueContextStackInSectionTag() {
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(["subject2": MustacheValue("+++")]))
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{#renderable}}{{subject}}{{subject2}}{{/renderable}}")!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendTagObserverStackInVariableTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
                let template = MustacheTemplate(string: "{{subject}}{{subject}}")!
                return template.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
            }
            func mustacheTag(tag: MustacheTag, willRenderValue value: MustacheValue) -> MustacheValue {
                ++tagWillRenderCount
                return value
            }
            func mustacheTag(tag: MustacheTag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        let renderable = TestedRenderable()
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{subject}}{{renderable}}{{subject}}{{subject}}{{subject}}{{subject}}")!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectCanExtendTagObserverStackInSectionTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
                // TODO: "tag.renderContent(renderingInfo" is not a nice API.
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
            func mustacheTag(tag: MustacheTag, willRenderValue value: MustacheValue) -> MustacheValue {
                ++tagWillRenderCount
                return value
            }
            func mustacheTag(tag: MustacheTag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        let renderable = TestedRenderable()
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let rendering = MustacheTemplate.render(value, fromString: "{{subject}}{{#renderable}}{{subject}}{{subject}}{{/renderable}}{{subject}}{{subject}}{{subject}}{{subject}}")!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectTriggersTagObserverCallbacks() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: MustacheTag, willRenderValue value: MustacheValue) -> MustacheValue {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return MustacheValue("delegate")
                }
            }
            
            func mustacheTag(tag: MustacheTag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
        
        let template = MustacheTemplate(string: "{{#renderable}}{{subject}}{{/renderable}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromVariableTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: MustacheTag, willRenderValue value: MustacheValue) -> MustacheValue {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return MustacheValue("delegate")
                }
            }
            
            func mustacheTag(tag: MustacheTag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let template = MustacheTemplate(string: "{{subject}}")!
            return template.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        
        let template = MustacheTemplate(string: "{{renderable}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromSectionTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: MustacheTag, willRenderValue value: MustacheValue) -> MustacheValue {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return MustacheValue("delegate")
                }
            }
            
            func mustacheTag(tag: MustacheTag, didRender rendering: String?, forValue: MustacheValue) {
            }
        }
        
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let template = MustacheTemplate(string: "{{subject}}")!
            return template.render(renderingInfo, contentType: outContentType, error: outError)
        }
        
        let template = MustacheTemplate(string: "{{#renderable}}{{/renderable}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderableObjectsInSectionTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "1"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "2"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{#items}}{{/items}}")!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "1"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "2"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}")!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfExplicitHTMLRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}")!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfExplicitHTMLRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{{items}}}")!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfExplicitTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}")!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfExplicitTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{{items}}}")!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfImplicitTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}")!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfImplicitTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        let rendering = MustacheTemplate.render(value, fromString: "{{{items}}}")!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInVariableTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        var error: NSError?
        let rendering = MustacheTemplate.render(value, fromString: "{{items}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInSectionTag() {
        let renderable1 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = MustacheValue(["items": MustacheValue([MustacheValue(renderable1), MustacheValue(renderable2)])])
        var error: NSError?
        let rendering = MustacheTemplate.render(value, fromString: "{{#items}}{{/items}}", error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testMustacheTemplateAsRenderableObject() {
        let repository = MustacheTemplateRepository(templates: ["partial": "{{subject}}"])
        let template = repository.template(named: "partial")!
        let value = MustacheValue(["partial": MustacheValue(template), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{partial}}")!
        XCTAssertEqual(rendering, "---")
    }
    
    func testMustacheTemplateAsRenderableObjectInNotHTMLEscaped() {
        let repository = MustacheTemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = repository.template(named: "partial")!
        let value = MustacheValue(["partial": MustacheValue(template), "subject": MustacheValue("---")])
        let rendering = MustacheTemplate.render(value, fromString: "{{partial}}")!
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testRenderableObjectCanAccessSiblingPartialTemplatesOfCurrentlyRenderedTemplate() {
        let templates = [
            "template": "{{renderable}}",
            "partial": "{{subject}}",
        ]
        let repository = MustacheTemplateRepository(templates: templates)
        let renderable = { (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let altTemplate = MustacheTemplate(string: "{{>partial}}")!
            return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
        }
        let value = MustacheValue(["renderable": MustacheValue(renderable), "subject": MustacheValue("-")])
        let template = repository.template(named: "template")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderableObjectCanAccessSiblingPartialTemplatesOfMustacheTemplateAsRenderableObject() {
        let repository1 = MustacheTemplateRepository(templates: [
            "template1": "{{ renderable }}|{{ template2 }}",
            "partial": "partial1"])
        let repository2 = MustacheTemplateRepository(templates: [
            "template2": "{{ renderable }}",
            "partial": "partial2"])
        let value = MustacheValue([
            "template2": MustacheValue(repository2.template(named: "template2")!),
            "renderable": MustacheValue({ (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{>partial}}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        let template = repository1.template(named: "template1")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "partial1|partial2")
    }
    
    func testRenderableObjectInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
        let value = MustacheValue([
            "object": MustacheValue("&"),
            "renderable": MustacheValue({ (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{ object }}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        
        let template = MustacheTemplate(string: "{{%CONTENT_TYPE:HTML}}{{renderable}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectInheritTextContentTypeOfCurrentlyRenderedTemplate() {
        let value = MustacheValue([
            "object": MustacheValue("&"),
            "renderable": MustacheValue({ (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{ object }}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        
        let template = MustacheTemplate(string: "{{%CONTENT_TYPE:TEXT}}{{renderable}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectInheritContentTypeFromPartial() {
        let repository = MustacheTemplateRepository(templates: [
            "templateHTML": "{{ renderable }}|{{> templateText }}",
            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ renderable }}"])
        let value = MustacheValue([
            "value": MustacheValue("&"),
            "renderable": MustacheValue({ (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{ value }}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        let template = repository.template(named: "templateHTML")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&amp;|&amp;")
    }
    
    func testRenderableObjectInheritContentTypeFromMustacheTemplateAsRenderableObject() {
        let repository1 = MustacheTemplateRepository(templates: [
            "templateHTML": "{{ renderable }}|{{ templateText }}"])
        let repository2 = MustacheTemplateRepository(templates: [
            "templateText": "{{ renderable }}"])
        repository2.configuration.contentType = .Text
        
        let value = MustacheValue([
            "value": MustacheValue("&"),
            "templateText": MustacheValue(repository2.template(named: "templateText")!),
            "renderable": MustacheValue({ (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = MustacheTemplate(string: "{{{ value }}}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        let template = repository1.template(named: "templateHTML")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&|&amp;")
    }
}
