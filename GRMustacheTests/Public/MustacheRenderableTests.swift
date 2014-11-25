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
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderablePerformsSectionRendering() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderableObjectHTMLRenderingOfEscapedVariableTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectHTMLRenderingOfUnescapedVariableTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{{.}}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectTextRenderingOfEscapedVariableTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectTextRenderingOfUnescapedVariableTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{{.}}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectHTMLRenderingOfSectionTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectTextRenderingOfSectionTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectCanSetErrorFromVariableTag() {
        let errorDomain = "ClusterTests"
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{.}}")!.render(Value(renderable), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanSetErrorFromSectionTag() {
        let errorDomain = "ClusterTests"
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Value(renderable), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanAccessVariableTagType() {
        var variableTagDetections = 0
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch renderingInfo.tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(Value(renderable))
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch renderingInfo.tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{#.}}{{/.}}")!.render(Value(renderable))
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{#.}}{{subject}}{{/.}}")!.render(Value(renderable))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{^.}}{{#.}}{{subject}}{{/.}}")!.render(Value(renderable))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRenderableObjectCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = renderingInfo.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(Value(renderable))
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderableObjectCanAccessRenderedContentFromSectionTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = renderingInfo.render(error: error)
            return tagRendering
        }
        
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        Template(string: "{{#renderable}}{{subject}}={{subject}}{{/renderable}}")!.render(value)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromExtensionSectionTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = renderingInfo.render(error: error)
            return tagRendering
        }
        
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        Template(string: "{{^renderable}}{{#renderable}}{{subject}}={{subject}}{{/renderable}}")!.render(value)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromEscapedVariableTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = renderingInfo.render(error: error)
            return tagRendering
        }
        
        Template(string: "{{.}}")!.render(Value(renderable))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromUnescapedVariableTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = renderingInfo.render(error: error)
            return tagRendering
        }
        
        Template(string: "{{{.}}}")!.render(Value(renderable))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.mustacheRender(renderingInfo, error: error)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.mustacheRender(renderingInfo, error: error)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("-")])
        let rendering = Template(string: "{{#renderable}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "-")
    }

    func testRenderableObjectDoesNotAutomaticallyEntersVariableContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheInspectable {
            func valueForMustacheKey(key: String) -> Value? {
                return Value("value")
            }
            func mustacheRender(renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return Template(string:"key:{{key}}")!.mustacheRender(renderingInfo, error: error)
            }
        }
        let value = Value(["renderable": Value(TestedRenderable())])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectDoesNotAutomaticallyEntersSectionContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheInspectable {
            func valueForMustacheKey(key: String) -> Value? {
                return Value("value")
            }
            func mustacheRender(renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return renderingInfo.render(error: error)
            }
        }
        let value = Value(["renderable": Value(TestedRenderable())])
        let rendering = Template(string: "{{#renderable}}key:{{key}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectCanExtendValueContextStackInVariableTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let context = renderingInfo.context.contextByAddingValue(Value(["subject2": Value("+++")]))
            let template = Template(string: "{{subject}}{{subject2}}")!
            return template.render(context, error: error)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendValueContextStackInSectionTag() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return renderingInfo.render(renderingInfo.context.contextByAddingValue(Value(["subject2": Value("+++")])), error: error)
        }
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = Template(string: "{{#renderable}}{{subject}}{{subject2}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendTagObserverStackInVariableTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func mustacheRender(var renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                renderingInfo.context = renderingInfo.context.contextByAddingTagObserver(self)
                let template = Template(string: "{{subject}}{{subject}}")!
                return template.mustacheRender(renderingInfo, error: error)
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
            func mustacheRender(renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return renderingInfo.render(renderingInfo.context.contextByAddingTagObserver(self), error: error)
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
        
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return renderingInfo.render(error: error)
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
        
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.mustacheRender(renderingInfo, error: error)
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
        
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.mustacheRender(renderingInfo, error: error)
        }
        
        let template = Template(string: "{{#renderable}}{{/renderable}}")!
        template.baseContext = template.baseContext.contextByAddingTagObserver(TestedTagObserver())
        let value = Value(["renderable": Value(renderable), "subject": Value("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderableObjectsInSectionTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(value)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfHTMLRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfHTMLRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{{items}}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        let rendering = Template(string: "{{{items}}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInVariableTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let value = Value(["items": Value([Value(renderable1), Value(renderable2)])])
        var error: NSError?
        let rendering = Template(string: "{{items}}")!.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInSectionTag() {
        let renderable1 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
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
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{>partial}}")!
            return altTemplate.mustacheRender(renderingInfo, error: error)
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
            "renderable": Value({ (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{>partial}}")!
                return altTemplate.mustacheRender(renderingInfo, error: error)
            })])
        let template = repository1.template(named: "template1")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "partial1|partial2")
    }
    
    func testRenderableObjectInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
        let value = Value([
            "object": Value("&"),
            "renderable": Value({ (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.mustacheRender(renderingInfo, error: error)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:HTML}}{{renderable}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectInheritTextContentTypeOfCurrentlyRenderedTemplate() {
        let value = Value([
            "object": Value("&"),
            "renderable": Value({ (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.mustacheRender(renderingInfo, error: error)
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
            "renderable": Value({ (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ value }}")!
                return altTemplate.mustacheRender(renderingInfo, error: error)
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
        
        let renderableValue = Value({ (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{{ value }}}")!
            return altTemplate.mustacheRender(renderingInfo, error: error)
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
