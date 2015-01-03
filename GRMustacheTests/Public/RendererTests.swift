//
//  RendererTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class RendererTests: XCTestCase {

    func testRendererInVariableTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{.}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRendererInSectionTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRendererInInvertedSectionTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{^.}}{{/.}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "")
    }
    
    func testRendererHTMLRenderingOfEscapedVariableTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{.}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRendererHTMLRenderingOfUnescapedVariableTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{{.}}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRendererTextRenderingOfEscapedVariableTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{.}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRendererTextRenderingOfUnescapedVariableTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{{.}}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRendererHTMLRenderingOfSectionTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRendererTextRenderingOfSectionTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(renderer))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRendererCanSetErrorFromVariableTag() {
        let errorDomain = "ClusterTests"
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{.}}")!.render(Box(renderer), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRendererCanSetErrorFromSectionTag() {
        let errorDomain = "ClusterTests"
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(renderer), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRendererCanAccessVariableTagType() {
        var variableTagDetections = 0
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(Box(renderer))
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRendererCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{#.}}{{/.}}")!.render(Box(renderer))
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRendererCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{#.}}{{subject}}{{/.}}")!.render(Box(renderer))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRendererCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{^.}}{{#.}}{{subject}}{{/.}}")!.render(Box(renderer))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRendererCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(Box(renderer))
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRendererCanAccessRenderedContentFromSectionTag() {
        var tagRendering: Rendering? = nil
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        let box = Box(["renderer": Box(renderer), "subject": Box("-")])
        Template(string: "{{#renderer}}{{subject}}={{subject}}{{/renderer}}")!.render(box)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRendererCanAccessRenderedContentFromExtensionSectionTag() {
        var tagRendering: Rendering? = nil
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        let box = Box(["renderer": Box(renderer), "subject": Box("-")])
        Template(string: "{{^renderer}}{{#renderer}}{{subject}}={{subject}}{{/renderer}}")!.render(box)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRendererCanAccessRenderedContentFromEscapedVariableTag() {
        var tagRendering: Rendering? = nil
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        Template(string: "{{.}}")!.render(Box(renderer))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRendererCanAccessRenderedContentFromUnescapedVariableTag() {
        var tagRendering: Rendering? = nil
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        Template(string: "{{{.}}}")!.render(Box(renderer))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRendererCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.render(info, error: error)
        }
        let box = Box(["renderer": Box(renderer), "subject": Box("-")])
        let rendering = Template(string: "{{renderer}}")!.render(box)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRendererCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.render(info, error: error)
        }
        let box = Box(["renderer": Box(renderer), "subject": Box("-")])
        let rendering = Template(string: "{{#renderer}}{{/renderer}}")!.render(box)!
        XCTAssertEqual(rendering, "-")
    }

    func testRendererDoesNotAutomaticallyEntersVariableContextStack() {
        let inspector = { (key: String) -> Box? in
            return Box("value")
        }
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Template(string:"key:{{key}}")!.render(info, error: error)
        }
        let testedBox = Box(inspector: inspector, renderer: renderer)
        let box = Box(["renderer": testedBox])
        let rendering = Template(string: "{{renderer}}")!.render(box)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRendererDoesNotAutomaticallyEntersSectionContextStack() {
        let inspector = { (key: String) -> Box? in
            return Box("value")
        }
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context, error: error)
        }
        let testedBox = Box(inspector: inspector, renderer: renderer)
        let box = Box(["renderer": testedBox])
        let rendering = Template(string: "{{#renderer}}key:{{key}}{{/renderer}}")!.render(box)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRendererCanExtendValueContextStackInVariableTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let context = info.context.extendedContext(Box(["subject2": Box("+++")]))
            let template = Template(string: "{{subject}}{{subject2}}")!
            return template.render(context, error: error)
        }
        let box = Box(["renderer": Box(renderer), "subject": Box("---")])
        let rendering = Template(string: "{{renderer}}")!.render(box)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRendererCanExtendValueContextStackInSectionTag() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context.extendedContext(Box(["subject2": Box("+++")])), error: error)
        }
        let box = Box(["renderer": Box(renderer), "subject": Box("---")])
        let rendering = Template(string: "{{#renderer}}{{subject}}{{subject2}}{{/renderer}}")!.render(box)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRendererCanExtendTagObserverStackInVariableTag() {
        var tagWillRenderCount = 0
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let context = info.context.extendedContext(Box({ (tag: Tag, box: Box) -> Box in
                ++tagWillRenderCount
                return box
            }))
            let template = Template(string: "{{subject}}{{subject}}")!
            return template.render(context, error: error)
        }
        let box = Box(["renderer": Box(renderer), "subject": Box("-")])
        let rendering = Template(string: "{{subject}}{{renderer}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(box)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(tagWillRenderCount, 2)
    }
    
    func testRendererCanExtendTagObserverStackInSectionTag() {
        var tagWillRenderCount = 0
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context.extendedContext(Box({ (tag: Tag, box: Box) -> Box in
                ++tagWillRenderCount
                return box
            })), error: error)
        }
        let box = Box(["renderer": Box(renderer), "subject": Box("-")])
        let rendering = Template(string: "{{subject}}{{#renderer}}{{subject}}{{subject}}{{/renderer}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(box)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(tagWillRenderCount, 2)
    }
    
    func testRendererTriggersTagObserverCallbacks() {
        let preRenderer = { (tag: Tag, box: Box) -> Box in
            switch tag.type {
            case .Section:
                return box
            default:
                return Box("delegate")
            }
        }
        
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context, error: error)
        }
        
        let template = Template(string: "{{#renderer}}{{subject}}{{/renderer}}")!
        template.baseContext = template.baseContext.extendedContext(Box(preRenderer))
        let box = Box(["renderer": Box(renderer), "subject": Box("---")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRendererTriggersTagObserverCallbacksInAnotherTemplateFromVariableTag() {
        let preRenderer = { (tag: Tag, box: Box) -> Box in
            switch tag.type {
            case .Section:
                return box
            default:
                return Box("delegate")
            }
        }
        
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.render(info.context, error: error)
        }
        
        let template = Template(string: "{{renderer}}")!
        template.baseContext = template.baseContext.extendedContext(Box(preRenderer))
        let box = Box(["renderer": Box(renderer), "subject": Box("---")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRendererTriggersTagObserverCallbacksInAnotherTemplateFromSectionTag() {
        let preRenderer = { (tag: Tag, box: Box) -> Box in
            switch tag.type {
            case .Section:
                return box
            default:
                return Box("delegate")
            }
        }
        
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.render(info.context, error: error)
        }
        
        let template = Template(string: "{{#renderer}}{{/renderer}}")!
        template.baseContext = template.baseContext.extendedContext(Box(preRenderer))
        let box = Box(["renderer": Box(renderer), "subject": Box("---")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderersInSectionTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(box)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderersInEscapedVariableTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        let rendering = Template(string: "{{items}}")!.render(box)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfHTMLRenderersInEscapedVariableTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        let rendering = Template(string: "{{items}}")!.render(box)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfHTMLRenderersInUnescapedVariableTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        let rendering = Template(string: "{{{items}}}")!.render(box)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfTextRenderersInEscapedVariableTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        let rendering = Template(string: "{{items}}")!.render(box)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfTextRenderersInUnescapedVariableTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        let rendering = Template(string: "{{{items}}}")!.render(box)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderersInVariableTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        var error: NSError?
        let rendering = Template(string: "{{items}}")!.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testArrayOfInconsistentContentTypeRenderersInSectionTag() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(renderer1), Box(renderer2)])])
        var error: NSError?
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testTemplateAsRenderer() {
        let repository = TemplateRepository(templates: ["partial": "{{subject}}"])
        let template = repository.template(named: "partial")!
        let box = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(box)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testTemplateAsRendererInNotHTMLEscaped() {
        let repository = TemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = repository.template(named: "partial")!
        let box = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(box)!
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testRendererCanAccessSiblingPartialTemplatesOfCurrentlyRenderedTemplate() {
        let templates = [
            "template": "{{renderer}}",
            "partial": "{{subject}}",
        ]
        let repository = TemplateRepository(templates: templates)
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{>partial}}")!
            return altTemplate.render(info, error: error)
        }
        let box = Box(["renderer": Box(renderer), "subject": Box("-")])
        let template = repository.template(named: "template")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRendererCanAccessSiblingPartialTemplatesOfTemplateAsRenderer() {
        let repository1 = TemplateRepository(templates: [
            "template1": "{{ renderer }}|{{ template2 }}",
            "partial": "partial1"])
        let repository2 = TemplateRepository(templates: [
            "template2": "{{ renderer }}",
            "partial": "partial2"])
        let box = Box([
            "template2": Box(repository2.template(named: "template2")!),
            "renderer": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{>partial}}")!
                return altTemplate.render(info, error: error)
            })])
        let template = repository1.template(named: "template1")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "partial1|partial2")
    }
    
    func testRendererInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
        let box = Box([
            "object": Box("&"),
            "renderer": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(info, error: error)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:HTML}}{{renderer}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRendererInheritTextContentTypeOfCurrentlyRenderedTemplate() {
        let box = Box([
            "object": Box("&"),
            "renderer": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(info, error: error)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:TEXT}}{{renderer}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRendererInheritContentTypeFromPartial() {
        let repository = TemplateRepository(templates: [
            "templateHTML": "{{ renderer }}|{{> templateText }}",
            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ renderer }}"])
        let box = Box([
            "value": Box("&"),
            "renderer": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ value }}")!
                return altTemplate.render(info, error: error)
            })])
        let template = repository.template(named: "templateHTML")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&amp;|&amp;")
    }
    
    func testRendererInheritContentTypeFromTemplateAsRenderer() {
        let repository1 = TemplateRepository(templates: [
            "templateHTML": "{{ renderer }}|{{ templateText }}"])
        let repository2 = TemplateRepository(templates: [
            "templateText": "{{ renderer }}"])
        repository2.configuration.contentType = .Text
        
        let rendererValue = Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{{ value }}}")!
            return altTemplate.render(info, error: error)
        })
        let box = Box([
            "value": Box("&"),
            "templateText": Box(repository2.template(named: "templateText")!),
            "renderer": rendererValue])
        let template = repository1.template(named: "templateHTML")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&|&amp;")
    }
    
    func testArrayOfRenderersInSectionTagDoesNotNeedExplicitInvocation() {
        let renderer1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("[1:\(rendering.string)]", rendering.contentType)
        }
        let renderer2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("[2:\(rendering.string)]", rendering.contentType)
        }
        let renderers = [Box(renderer1), Box(renderer2), Box(true), Box(false)]
        let template = Template(string: "{{#items}}---{{/items}},{{#items}}{{#.}}---{{/.}}{{/items}}")!
        let rendering = template.render(Box(["items":Box(renderers)]))!
        XCTAssertEqual(rendering, "[1:---][2:---]------,[1:---][2:---]---")
    }

}
