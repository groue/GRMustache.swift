//
//  RenderableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class RenderableTests: XCTestCase {

    func testRenderablePerformsVariableRendering() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        }
        let rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderablePerformsSectionRendering() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "---"
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfEscapedVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        }
        let rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfUnescapedVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        }
        let rendering = Template(string: "{{{.}}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfEscapedVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        }
        let rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectExplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        }
        let rendering = Template(string: "{{{.}}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectImplicitTextRenderingOfEscapedVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        }
        let rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfUnescapedVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        }
        let rendering = Template(string: "{{{.}}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitHTMLRenderingOfSectionTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "&"
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectExplicitTextRenderingOfSectionTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "&"
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectImplicitTextRenderingOfSectionTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "&"
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectCanSetErrorFromVariableTag() {
        let errorDomain = "ClusterTests"
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{.}}")!.render(Value(renderable), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanSetErrorFromSectionTag() {
        let errorDomain = "ClusterTests"
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outError.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        }
        let rendering = Template(string: "<{{.}}>")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanRenderNilWithoutSettingErrorFromSectionTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return nil
        }
        let rendering = Template(string: "<{{#.}}{{/.}}>")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testRenderableObjectCanAccessVariableTagType() {
        var variableTagDetections = 0
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return nil
        }
        Template(string: "{{.}}")!.render(Value(renderable))
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            switch tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return nil
        }
        Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = tag.innerTemplateString
            return nil
        }
        Template(string: "{{#.}}{{subject}}{{/.}}")!.render(Value(renderable))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = tag.innerTemplateString
            return nil
        }
        Template(string: "{{^.}}{{#.}}{{subject}}{{/.}}")!.render(Value(renderable))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRenderableObjectCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            innerTemplateString = tag.innerTemplateString
            return nil
        }
        Template(string: "{{.}}")!.render(Value(renderable))
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderableObjectCanAccessRenderedContentFromSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        Template(string: "{{#renderable}}{{subject}}={{subject}}{{/renderable}}")!.render(value)
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromExtensionSectionTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        Template(string: "{{^renderable}}{{#renderable}}{{subject}}={{subject}}{{/renderable}}")!.render(value)
        XCTAssertEqual(renderedContent!, "-=-")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromEscapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        Template(string: "{{.}}")!.render(Value(renderable))
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromUnescapedVariableTag() {
        var renderedContent: String? = nil
        var renderedContentType: ContentType? = nil
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            renderedContent = tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            renderedContentType = outContentType.memory
            return nil
        }
        Template(string: "{{{.}}}")!.render(Value(renderable))
        XCTAssertEqual(renderedContent!, "")
        XCTAssertEqual(renderedContentType!, ContentType.HTML)
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return altTemplate.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return altTemplate.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        let rendering = Template(string: "{{#renderable}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "-")
    }

    func testRenderableObjectDoesNotAutomaticallyEntersVariableContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value("value")
            }
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                return Template(string:"key:{{key}}")!.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
            }
        }
        let value = Value(["renderable": Value(TestedRenderable())])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectDoesNotAutomaticallyEntersSectionContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheTraversable {
            func valueForMustacheIdentifier(identifier: String) -> Value? {
                return Value("value")
            }
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                // TODO: "tag.renderContent(renderingInfo" is not a nice API.
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        }
        let value = Value(["renderable": Value(TestedRenderable())])
        let rendering = Template(string: "{{#renderable}}key:{{key}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectCanExtendValueContextStackInVariableTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(Value(["subject2": Value("+++")]))
            let template = Template(string: "{{subject}}{{subject2}}")!
            return template.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendValueContextStackInSectionTag() {
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(Value(["subject2": Value("+++")]))
            // TODO: "tag.renderContent(renderingInfo" is not a nice API.
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = Template(string: "{{#renderable}}{{subject}}{{subject2}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendTagObserverStackInVariableTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
                let template = Template(string: "{{subject}}{{subject}}")!
                return template.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
            }
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                ++tagWillRenderCount
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
            }
        }
        let renderable = TestedRenderable()
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        let rendering = Template(string: "{{subject}}{{renderable}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(value)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectCanExtendTagObserverStackInSectionTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
                // TODO: "tag.renderContent(renderingInfo" is not a nice API.
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                ++tagWillRenderCount
                return value
            }
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
            }
        }
        let renderable = TestedRenderable()
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        let rendering = Template(string: "{{subject}}{{#renderable}}{{subject}}{{subject}}{{/renderable}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(value)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectTriggersTagObserverCallbacks() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return Value("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
            }
        }
        
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
        }
        
        let template = Template(string: "{{#renderable}}{{subject}}{{/renderable}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromVariableTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return Value("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
            }
        }
        
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let template = Template(string: "{{subject}}")!
            return template.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
        
        let template = Template(string: "{{renderable}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromSectionTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
                switch tag.type {
                case .Section:
                    return value
                default:
                    return Value("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
            }
        }
        
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let template = Template(string: "{{subject}}")!
            return template.render(renderingInfo, contentType: outContentType, error: outError)
        }
        
        let template = Template(string: "{{#renderable}}{{/renderable}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderableObjectsInSectionTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "1"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "2"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(value)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "1"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "2"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfExplicitHTMLRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfExplicitHTMLRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{{items}}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfExplicitTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfExplicitTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{{items}}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfImplicitTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfImplicitTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{{items}}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInVariableTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        var error: NSError?
        let rendering = Template(string: "{{items}}")!.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInSectionTag() {
        let renderable1 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .Text
            return "<1>"
        }
        let renderable2 = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            outContentType.memory = .HTML
            return "<2>"
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        var error: NSError?
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testTemplateAsRenderableObject() {
        let repository = TemplateRepository(templates: ["partial": "{{subject}}"])
        let template = repository.template(named: "partial")!
        let value = Value(["partial": Value(template), "subject": Value("---")])
        let rendering = Template(string: "{{partial}}")!.render(value)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testTemplateAsRenderableObjectInNotHTMLEscaped() {
        let repository = TemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = repository.template(named: "partial")!
        let value = Value(["partial": Value(template), "subject": Value("---")])
        let rendering = Template(string: "{{partial}}")!.render(value)!
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testRenderableObjectCanAccessSiblingPartialTemplatesOfCurrentlyRenderedTemplate() {
        let templates = [
            "template": "{{renderable}}",
            "partial": "{{subject}}",
        ]
        let repository = TemplateRepository(templates: templates)
        let renderable = { (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let altTemplate = Template(string: "{{>partial}}")!
            return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        let template = repository.template(named: "template")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderableObjectCanAccessSiblingPartialTemplatesOfTemplateAsRenderableObject() {
        let repository1 = TemplateRepository(templates: [
            "template1": "{{ renderable }}|{{ template2 }}",
            "partial": "partial1"])
        let repository2 = TemplateRepository(templates: [
            "template2": "{{ renderable }}",
            "partial": "partial2"])
        let value = Value([
            "template2": Value(repository2.template(named: "template2")!),
            "renderable": Value({ (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = Template(string: "{{>partial}}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        let template = repository1.template(named: "template1")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "partial1|partial2")
    }
    
    func testRenderableObjectInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
        let value = Value([
            "object": Value("&"),
            "renderable": Value({ (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:HTML}}{{renderable}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectInheritTextContentTypeOfCurrentlyRenderedTemplate() {
        let value = Value([
            "object": Value("&"),
            "renderable": Value({ (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:TEXT}}{{renderable}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectInheritContentTypeFromPartial() {
        let repository = TemplateRepository(templates: [
            "templateHTML": "{{ renderable }}|{{> templateText }}",
            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ renderable }}"])
        let value = Value([
            "value": Value("&"),
            "renderable": Value({ (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
                let altTemplate = Template(string: "{{ value }}")!
                return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
            })])
        let template = repository.template(named: "templateHTML")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&amp;|&amp;")
    }
    
    func testRenderableObjectInheritContentTypeFromTemplateAsRenderableObject() {
        let repository1 = TemplateRepository(templates: [
            "templateHTML": "{{ renderable }}|{{ templateText }}"])
        let repository2 = TemplateRepository(templates: [
            "templateText": "{{ renderable }}"])
        repository2.configuration.contentType = .Text
        
        let renderableValue = Value({ (tag: Tag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?) in
            let altTemplate = Template(string: "{{{ value }}}")!
            return altTemplate.render(renderingInfo, contentType: outContentType, error: outError)
        })
        let value = Value([
            "value": Value("&"),
            "templateText": Value(repository2.template(named: "templateText")!),
            "renderable": renderableValue])
        let template = repository1.template(named: "templateHTML")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&|&amp;")
    }
}
