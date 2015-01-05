//
//  RenderFunctionTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class RenderFunctionTests: XCTestCase {

    func testRenderFunctionInVariableTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderFunctionInSectionTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderFunctionInInvertedSectionTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("---")
        }
        let rendering = Template(string: "{{^.}}{{/.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "")
    }
    
    func testRenderFunctionHTMLRenderingOfEscapedVariableTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionHTMLRenderingOfUnescapedVariableTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{{.}}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionTextRenderingOfEscapedVariableTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderFunctionTextRenderingOfUnescapedVariableTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{{.}}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionHTMLRenderingOfSectionTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&", .HTML)
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionTextRenderingOfSectionTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("&")
        }
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderFunctionCanSetErrorFromVariableTag() {
        let errorDomain = "ClusterTests"
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{.}}")!.render(Box(render), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderFunctionCanSetErrorFromSectionTag() {
        let errorDomain = "ClusterTests"
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            error.memory = NSError(domain: errorDomain, code: 0, userInfo: nil)
            return nil
        }
        var error: NSError?
        let rendering = Template(string: "{{#.}}{{/.}}")!.render(Box(render), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, errorDomain)
    }
    
    func testRenderFunctionCanAccessVariableTagType() {
        var variableTagDetections = 0
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                ++variableTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(Box(render))
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderFunctionCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Section:
                ++sectionTagDetections
            default:
                break
            }
            return Rendering("")
        }
        Template(string: "{{#.}}{{/.}}")!.render(Box(render))
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRenderFunctionCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{#.}}{{subject}}{{/.}}")!.render(Box(render))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderFunctionCanAccessInnerTemplateStringFromExtensionSectionTag() {
        var innerTemplateString: String? = nil
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{^.}}{{#.}}{{subject}}{{/.}}")!.render(Box(render))
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }

    func testRenderFunctionCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        Template(string: "{{.}}")!.render(Box(render))
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderFunctionCanAccessRenderedContentFromSectionTag() {
        var tagRendering: Rendering? = nil
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        let box = Box(["render": Box(render), "subject": Box("-")])
        Template(string: "{{#render}}{{subject}}={{subject}}{{/render}}")!.render(box)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderFunctionCanAccessRenderedContentFromExtensionSectionTag() {
        var tagRendering: Rendering? = nil
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        let box = Box(["render": Box(render), "subject": Box("-")])
        Template(string: "{{^render}}{{#render}}{{subject}}={{subject}}{{/render}}")!.render(box)
        
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderFunctionCanAccessRenderedContentFromEscapedVariableTag() {
        var tagRendering: Rendering? = nil
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        Template(string: "{{.}}")!.render(Box(render))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderFunctionCanAccessRenderedContentFromUnescapedVariableTag() {
        var tagRendering: Rendering? = nil
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            tagRendering = info.tag.render(info.context, error: error)
            return tagRendering
        }
        
        Template(string: "{{{.}}}")!.render(Box(render))
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.HTML)
    }
    
    func testRenderFunctionCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.render(info, error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("-")])
        let rendering = Template(string: "{{render}}")!.render(box)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderFunctionCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.render(info, error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("-")])
        let rendering = Template(string: "{{#render}}{{/render}}")!.render(box)!
        XCTAssertEqual(rendering, "-")
    }

    func testRenderFunctionDoesNotAutomaticallyEntersVariableContextStack() {
        let inspect = { (key: String) -> Box? in
            return Box("value")
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Template(string:"key:{{key}}")!.render(info, error: error)
        }
        let box = Box(["render": Box(inspect: inspect, render: render)])
        let rendering = Template(string: "{{render}}")!.render(box)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderFunctionDoesNotAutomaticallyEntersSectionContextStack() {
        let inspect = { (key: String) -> Box? in
            return Box("value")
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context, error: error)
        }
        let box = Box(["render": Box(inspect: inspect, render: render)])
        let rendering = Template(string: "{{#render}}key:{{key}}{{/render}}")!.render(box)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderFunctionCanExtendValueContextStackInVariableTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let context = info.context.extendedContext(Box(["subject2": Box("+++")]))
            let template = Template(string: "{{subject}}{{subject2}}")!
            return template.render(context, error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("---")])
        let rendering = Template(string: "{{render}}")!.render(box)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderFunctionCanExtendValueContextStackInSectionTag() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context.extendedContext(Box(["subject2": Box("+++")])), error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("---")])
        let rendering = Template(string: "{{#render}}{{subject}}{{subject2}}{{/render}}")!.render(box)!
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderFunctionCanExtendWillRenderStackInVariableTag() {
        var tagWillRenderCount = 0
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let context = info.context.extendedContext(Box({ (tag: Tag, box: Box) -> Box in
                ++tagWillRenderCount
                return box
            }))
            let template = Template(string: "{{subject}}{{subject}}")!
            return template.render(context, error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("-")])
        let rendering = Template(string: "{{subject}}{{render}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(box)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(tagWillRenderCount, 2)
    }
    
    func testRenderFunctionCanExtendWillRenderStackInSectionTag() {
        var tagWillRenderCount = 0
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context.extendedContext(Box({ (tag: Tag, box: Box) -> Box in
                ++tagWillRenderCount
                return box
            })), error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("-")])
        let rendering = Template(string: "{{subject}}{{#render}}{{subject}}{{subject}}{{/render}}{{subject}}{{subject}}{{subject}}{{subject}}")!.render(box)!
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(tagWillRenderCount, 2)
    }
    
    func testRenderFunctionTriggersWillRenderFunctions() {
        let willRender = { (tag: Tag, box: Box) -> Box in
            switch tag.type {
            case .Section:
                return box
            default:
                return Box("delegate")
            }
        }
        
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context, error: error)
        }
        
        let template = Template(string: "{{#render}}{{subject}}{{/render}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        let box = Box(["render": Box(render), "subject": Box("---")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderFunctionTriggersWillRenderFunctionsInAnotherTemplateFromVariableTag() {
        let willRender = { (tag: Tag, box: Box) -> Box in
            switch tag.type {
            case .Section:
                return box
            default:
                return Box("delegate")
            }
        }
        
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.render(info.context, error: error)
        }
        
        let template = Template(string: "{{render}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        let box = Box(["render": Box(render), "subject": Box("---")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderFunctionTriggersWillRenderFunctionsInAnotherTemplateFromSectionTag() {
        let willRender = { (tag: Tag, box: Box) -> Box in
            switch tag.type {
            case .Section:
                return box
            default:
                return Box("delegate")
            }
        }
        
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "{{subject}}")!
            return template.render(info.context, error: error)
        }
        
        let template = Template(string: "{{#render}}{{/render}}")!
        template.baseContext = template.baseContext.extendedContext(Box(willRender))
        let box = Box(["render": Box(render), "subject": Box("---")])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderFunctionsInSectionTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(box)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderFunctionsInEscapedVariableTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("1")
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("2")
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        let rendering = Template(string: "{{items}}")!.render(box)!
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfHTMLRenderFunctionsInEscapedVariableTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        let rendering = Template(string: "{{items}}")!.render(box)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfHTMLRenderFunctionsInUnescapedVariableTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>", .HTML)
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        let rendering = Template(string: "{{{items}}}")!.render(box)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfTextRenderFunctionsInEscapedVariableTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        let rendering = Template(string: "{{items}}")!.render(box)!
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfTextRenderFunctionsInUnescapedVariableTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>")
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        let rendering = Template(string: "{{{items}}}")!.render(box)!
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderFunctionsInVariableTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        var error: NSError?
        let rendering = Template(string: "{{items}}")!.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testArrayOfInconsistentContentTypeRenderFunctionsInSectionTag() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("<2>", .HTML)
        }
        let box = Box(["items": Box([Box(render1), Box(render2)])])
        var error: NSError?
        let rendering = Template(string: "{{#items}}{{/items}}")!.render(box, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testTemplateAsRenderFunction() {
        let repository = TemplateRepository(templates: ["partial": "{{subject}}"])
        let template = repository.template(named: "partial")!
        let box = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(box)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testTemplateAsRenderFunctionInNotHTMLEscaped() {
        let repository = TemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = repository.template(named: "partial")!
        let box = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(box)!
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testRenderFunctionCanAccessSiblingPartialTemplatesOfCurrentlyRenderedTemplate() {
        let templates = [
            "template": "{{render}}",
            "partial": "{{subject}}",
        ]
        let repository = TemplateRepository(templates: templates)
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{>partial}}")!
            return altTemplate.render(info, error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("-")])
        let template = repository.template(named: "template")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderFunctionCanAccessSiblingPartialTemplatesOfTemplateAsRenderFunction() {
        let repository1 = TemplateRepository(templates: [
            "template1": "{{ render }}|{{ template2 }}",
            "partial": "partial1"])
        let repository2 = TemplateRepository(templates: [
            "template2": "{{ render }}",
            "partial": "partial2"])
        let box = Box([
            "template2": Box(repository2.template(named: "template2")!),
            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{>partial}}")!
                return altTemplate.render(info, error: error)
            })])
        let template = repository1.template(named: "template1")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "partial1|partial2")
    }
    
    func testRenderFunctionInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
        let box = Box([
            "object": Box("&"),
            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(info, error: error)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:HTML}}{{render}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderFunctionInheritTextContentTypeOfCurrentlyRenderedTemplate() {
        let box = Box([
            "object": Box("&"),
            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ object }}")!
                return altTemplate.render(info, error: error)
            })])
        
        let template = Template(string: "{{%CONTENT_TYPE:TEXT}}{{render}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionInheritContentTypeFromPartial() {
        let repository = TemplateRepository(templates: [
            "templateHTML": "{{ render }}|{{> templateText }}",
            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ render }}"])
        let box = Box([
            "value": Box("&"),
            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                let altTemplate = Template(string: "{{ value }}")!
                return altTemplate.render(info, error: error)
            })])
        let template = repository.template(named: "templateHTML")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&amp;|&amp;")
    }
    
    func testRenderFunctionInheritContentTypeFromTemplateAsRenderFunction() {
        let repository1 = TemplateRepository(templates: [
            "templateHTML": "{{ render }}|{{ templateText }}"])
        let repository2 = TemplateRepository(templates: [
            "templateText": "{{ render }}"])
        repository2.configuration.contentType = .Text
        
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let altTemplate = Template(string: "{{{ value }}}")!
            return altTemplate.render(info, error: error)
        }
        let box = Box([
            "value": Box("&"),
            "templateText": Box(repository2.template(named: "templateText")!),
            "render": Box(render)])
        let template = repository1.template(named: "templateHTML")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "&|&amp;")
    }
    
    func testArrayOfRenderFunctionsInSectionTagDoesNotNeedExplicitInvocation() {
        let render1 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("[1:\(rendering.string)]", rendering.contentType)
        }
        let render2 = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("[2:\(rendering.string)]", rendering.contentType)
        }
        let renders = [Box(render1), Box(render2), Box(true), Box(false)]
        let template = Template(string: "{{#items}}---{{/items}},{{#items}}{{#.}}---{{/.}}{{/items}}")!
        let rendering = template.render(Box(["items":Box(renders)]))!
        XCTAssertEqual(rendering, "[1:---][2:---]------,[1:---][2:---]---")
    }

}
