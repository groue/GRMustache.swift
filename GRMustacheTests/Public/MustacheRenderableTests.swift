//
//  MustacheRenderableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class MustacheRenderableTests: XCTestCase {

    func testRenderableInVariableTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderableInSectionTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderableInInvertedSectionTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{^.}}{{/.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "")
    }
    
    func testRenderableObjectHTMLRenderingOfEscapedVariableTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectHTMLRenderingOfUnescapedVariableTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{{.}}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectTextRenderingOfEscapedVariableTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectTextRenderingOfUnescapedVariableTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{{.}}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectHTMLRenderingOfSectionTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectTextRenderingOfSectionTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectCanSetErrorFromVariableTag() {
        let errorDomain = "ClusterTests"
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{.}}")!.render(BoxedRenderable(renderable), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanSetErrorFromSectionTag() {
        let errorDomain = "ClusterTests"
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(BoxedRenderable(renderable), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderableObjectCanAccessVariableTagType() {
        var variableTagDetections = 0
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(BoxedRenderable(renderable))
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{#.}}{{/.}}")!.render(BoxedRenderable(renderable))
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{#.}}{{subject}}{{/.}}")!.render(BoxedRenderable(renderable))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderableObjectCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{^.}}{{#.}}{{subject}}{{/.}}")!.render(BoxedRenderable(renderable))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRenderableObjectCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(BoxedRenderable(renderable))
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderableObjectCanAccessRenderedContentFromSectionTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("-")])
        Template(string: "{{#renderable}}{{subject}}={{subject}}{{/renderable}}")!.render(value)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromExtensionSectionTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("-")])
        Template(string: "{{^renderable}}{{#renderable}}{{subject}}={{subject}}{{/renderable}}")!.render(value)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromEscapedVariableTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        Template(string: "{{.}}")!.render(BoxedRenderable(renderable))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanAccessRenderedContentFromUnescapedVariableTag() {
        var tagRendering: Rendering? = nil
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        Template(string: "{{{.}}}")!.render(BoxedRenderable(renderable))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.render(info, error: error)
        }
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("-")])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderableObjectCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.render(info, error: error)
        }
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("-")])
        let rendering = Template(string: "{{#renderable}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "-")
    }

    func testRenderableObjectDoesNotAutomaticallyEntersVariableContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheInspectable {
            func valueForMustacheKey(key: String) -> Box? {
                return Box("value")
            }
            func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return Template(string:"key:{{key}}")!.render(info, error: error)
            }
        }
        let value = Box(["renderable": Box(TestedRenderable())])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectDoesNotAutomaticallyEntersSectionContextStack() {
        class TestedRenderable: MustacheRenderable, MustacheInspectable {
            func valueForMustacheKey(key: String) -> Box? {
                return Box("value")
            }
            func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return info.tag.render(info.context, error: error)
            }
        }
        let value = Box(["renderable": Box(TestedRenderable())])
        let rendering = Template(string: "{{#renderable}}key:{{key}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderableObjectCanExtendValueContextStackInVariableTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let context = info.context.extendedContext(box: Box(["subject2": Box("+++")]))
            let template = Template(string: "{{subject}}{{subject2}}")!
            return template.render(context, error: error)
        }
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("---")])
        let rendering = Template(string: "{{renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendValueContextStackInSectionTag() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context.extendedContext(box: Box(["subject2": Box("+++")])), error: error)
        }
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("---")])
        let rendering = Template(string: "{{#renderable}}{{subject}}{{subject2}}{{/renderable}}")!.render(value)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderableObjectCanExtendTagObserverStackInVariableTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func render(var info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                let context = info.context.extendedContext(tagObserver: self)
                let template = Template(string: "{{subject}}{{subject}}")!
                return template.render(context, error: error)
            }
            func mustacheTag(tag: Tag, willRender box: Box) -> Box {
                ++tagWillRenderCount
                return box
            }
            func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
            }
        }
        let renderable = TestedRenderable()
        let value = Box(["renderable": Box(renderable), "subject": Box("-")])
        let rendering = Template(string: "{{subject}}{{renderable}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(value)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectCanExtendTagObserverStackInSectionTag() {
        class TestedRenderable: MustacheRenderable, MustacheTagObserver {
            var tagWillRenderCount = 0
            func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                return info.tag.render(info.context.extendedContext(tagObserver: self), error: error)
            }
            func mustacheTag(tag: Tag, willRender box: Box) -> Box {
                ++tagWillRenderCount
                return box
            }
            func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
            }
        }
        let renderable = TestedRenderable()
        let value = Box(["renderable": Box(renderable), "subject": Box("-")])
        let rendering = Template(string: "{{subject}}{{#renderable}}{{subject}}{{subject}}{{/renderable}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(value)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(renderable.tagWillRenderCount, 2)
    }
    
    func testRenderableObjectTriggersTagObserverCallbacks() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRender box: Box) -> Box {
                switch tag.type {
                case .Section:
                    return box
                default:
                    return Box("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
            }
        }
        
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context, error: error)
        }
        
        let template = Template(string: "{{#renderable}}{{subject}}{{/renderable}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: TestedTagObserver())
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromVariableTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRender box: Box) -> Box {
                switch tag.type {
                case .Section:
                    return box
                default:
                    return Box("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
            }
        }
        
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.render(info.context, error: error)
        }
        
        let template = Template(string: "{{renderable}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: TestedTagObserver())
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderableObjectTriggersTagObserverCallbacksInAnotherTemplateFromSectionTag() {
        class TestedTagObserver: MustacheTagObserver {
            func mustacheTag(tag: Tag, willRender box: Box) -> Box {
                switch tag.type {
                case .Section:
                    return box
                default:
                    return Box("delegate")
                }
            }
            
            func mustacheTag(tag: Tag, didRender box: Box, asString string: String?) {
            }
        }
        
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.render(info.context, error: error)
        }
        
        let template = Template(string: "{{#renderable}}{{/renderable}}")!
        template.baseContext = template.baseContext.extendedContext(tagObserver: TestedTagObserver())
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("---")])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderableObjectsInSectionTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(value)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfHTMLRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfHTMLRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        let rendering = Template(string: "{{{items}}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfTextRenderableObjectsInEscapedVariableTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        let rendering = Template(string: "{{items}}")!.render(value)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfTextRenderableObjectsInUnescapedVariableTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        let rendering = Template(string: "{{{items}}}")!.render(value)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInVariableTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        var error: NSError?
        let rendering = Template(string: "{{items}}")!.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testArrayOfInconsistentContentTypeRenderableObjectsInSectionTag() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let value = Box(["items": Box([BoxedRenderable(renderable1), BoxedRenderable(renderable2)])])
        var error: NSError?
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testTemplateAsRenderableObject() {
        let repository = TemplateRepository(templates: ["partial": "{{subject}}"])
        let template = repository.template(named: "partial")!
        let value = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(value)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testTemplateAsRenderableObjectInNotHTMLEscaped() {
        let repository = TemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = repository.template(named: "partial")!
        let value = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(value)!
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testRenderableObjectCanAccessSiblingPartialTemplatesOfCurrentlyRenderedTemplate() {
        let templates = [
            "template": "{{renderable}}",
            "partial": "{{subject}}",
        ]
        let repository = TemplateRepository(templates: templates)
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{>partial}}")!
            return altTemplate.render(info, error: error)
        }
        let value = Box(["renderable": BoxedRenderable(renderable), "subject": Box("-")])
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
        let value = Box([
            "template2": Box(repository2.template(named: "template2")!),
            "renderable": BoxedRenderable({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{>partial}}")!
                return altTemplate.render(info, error: error)
            })])
        let template = repository1.template(named: "template1")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "partial1|partial2")
    }
    
    func testRenderableObjectInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
        let value = Box([
            "object": Box("&"),
            "renderable": BoxedRenderable({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(info, error: error)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:HTML}}{{renderable}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderableObjectInheritTextContentTypeOfCurrentlyRenderedTemplate() {
        let value = Box([
            "object": Box("&"),
            "renderable": BoxedRenderable({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(info, error: error)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:TEXT}}{{renderable}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderableObjectInheritContentTypeFromPartial() {
        let repository = TemplateRepository(templates: [
            "templateHTML": "{{ renderable }}|{{> templateText }}",
            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ renderable }}"])
        let value = Box([
            "value": Box("&"),
            "renderable": BoxedRenderable({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ value }}")!
                return altTemplate.render(info, error: error)
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
        
        let renderableValue = BoxedRenderable({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{{ value }}}")!
            return altTemplate.render(info, error: error)
        })
        let value = Box([
            "value": Box("&"),
            "templateText": Box(repository2.template(named: "templateText")!),
            "renderable": renderableValue])
        let template = repository1.template(named: "templateHTML")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "&|&amp;")
    }
    
    func testArrayOfRenderableObjectsInSectionTagDoesNotNeedExplicitInvocation() {
        let renderable1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("[1:\(rendering.string)]", rendering.contentType)
        }
        let renderable2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("[2:\(rendering.string)]", rendering.contentType)
        }
        let renderables = [BoxedRenderable(renderable1), BoxedRenderable(renderable2), Box(true), Box(false)]
        let template = Template(string: "{{#items}}---{{/items}},{{#items}}{{#.}}---{{/.}}{{/items}}")!
        let rendering = template.render(Box(["items":Box(renderables)]))!
        XCTAssertEqual(rendering, "[1:---][2:---]------,[1:---][2:---]---")
    }

}
