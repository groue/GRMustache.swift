// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import XCTest
import Mustache

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
            return altTemplate.render(info.context, error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("-")])
        let rendering = Template(string: "{{render}}")!.render(box)!
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderFunctionCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = Template(string:"{{subject}}")!
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return altTemplate.render(info.context, error: error)
        }
        let box = Box(["render": Box(render), "subject": Box("-")])
        let rendering = Template(string: "{{#render}}{{/render}}")!.render(box)!
        XCTAssertEqual(rendering, "-")
    }

    func testRenderFunctionDoesNotAutomaticallyEntersVariableContextStack() {
        let keyedSubscript = { (key: String) -> MustacheBox in
            return Box("value")
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Template(string:"key:{{key}}")!.render(info.context, error: error)
        }
        let box = Box(["render": Box(keyedSubscript: keyedSubscript, render: render)])
        let rendering = Template(string: "{{render}}")!.render(box)!
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderFunctionDoesNotAutomaticallyEntersSectionContextStack() {
        let keyedSubscript = { (key: String) -> MustacheBox in
            return Box("value")
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return info.tag.render(info.context, error: error)
        }
        let box = Box(["render": Box(keyedSubscript: keyedSubscript, render: render)])
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
            let context = info.context.extendedContext(Box({ (tag: Tag, box: MustacheBox) -> MustacheBox in
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
            return info.tag.render(info.context.extendedContext(Box({ (tag: Tag, box: MustacheBox) -> MustacheBox in
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
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
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
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
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
        let willRender = { (tag: Tag, box: MustacheBox) -> MustacheBox in
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
    
    func testDynamicPartial() {
        let repository = TemplateRepository(templates: ["partial": "{{subject}}"])
        let template = repository.template(named: "partial")!
        let box = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(box)!
        XCTAssertEqual(rendering, "---")
    }
    
    func testDynamicPartialIsNotHTMLEscaped() {
        let repository = TemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = repository.template(named: "partial")!
        let box = Box(["partial": Box(template), "subject": Box("---")])
        let rendering = Template(string: "{{partial}}")!.render(box)!
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testDynamicInheritedPartial() {
        let repository = TemplateRepository(templates: [
            "layout": "<{{$a}}Default{{subject}}{{/a}},{{$b}}Ignored{{/b}}>",
            "partial": "[{{#layout}}---{{$b}}Overriden{{subject}}{{/b}}---{{/layout}}]"])
        let template = repository.template(named: "partial")!
        let data = [
            "layout": Box(repository.template(named: "layout")!),
            "subject": Box("---")]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "[<Default---,Overriden--->]")
    }
    
    // Those tests are commented out.
    //
    // They tests a feature present in Objective-C GRMustache, that is that
    // Template(string:error:) would load partials from the "current template
    // repository", a hidden global, and process templates with the "current
    // content type", another hidden global.
    //
    // The goal is to help RenderFunctions use the Template(string:error:)
    // initializers without thinking much about the context.
    //
    // 1. They could process tag.innerTemplateString that would contain
    //    {{>partial}} tags: partials would be loaded from the correct template
    //    repository.
    // 2. They would render text or HTML depending on the rendered template.
    //
    // Actually this feature has a bug in Objective-C GRMustache: it does not
    // work in a hierarchy of directories and template files, because the
    // "current template repository" is not enough information: we also need to
    // know the ID of the "current template" to load the correct partial.
    //
    // Anyway. For the sake of simplicity, we drop this feature in
    // GRMustache.swift.
    //
    // Let's wait for a user request :-)
//    func testRenderFunctionCanAccessSiblingPartialTemplatesOfCurrentlyRenderedTemplate() {
//        let templates = [
//            "template": "{{render}}",
//            "partial": "{{subject}}",
//        ]
//        let repository = TemplateRepository(templates: templates)
//        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            let altTemplate = Template(string: "{{>partial}}")!
//            return altTemplate.render(info.context, error: error)
//        }
//        let box = Box(["render": Box(render), "subject": Box("-")])
//        let template = repository.template(named: "template")!
//        let rendering = template.render(box)!
//        XCTAssertEqual(rendering, "-")
//    }
//    
//    func testRenderFunctionCanAccessSiblingPartialTemplatesOfTemplateAsRenderFunction() {
//        let repository1 = TemplateRepository(templates: [
//            "template1": "{{ render }}|{{ template2 }}",
//            "partial": "partial1"])
//        let repository2 = TemplateRepository(templates: [
//            "template2": "{{ render }}",
//            "partial": "partial2"])
//        let box = Box([
//            "template2": Box(repository2.template(named: "template2")!),
//            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//                let altTemplate = Template(string: "{{>partial}}")!
//                return altTemplate.render(info.context, error: error)
//            })])
//        let template = repository1.template(named: "template1")!
//        let rendering = template.render(box)!
//        XCTAssertEqual(rendering, "partial1|partial2")
//    }
//    
//    func testRenderFunctionInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
//        let box = Box([
//            "object": Box("&"),
//            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//                let altTemplate = Template(string: "{{ object }}")!
//                return altTemplate.render(info.context, error: error)
//            })])
//        
//        let template = Template(string: "{{%CONTENT_TYPE:HTML}}{{render}}")!
//        let rendering = template.render(box)!
//        XCTAssertEqual(rendering, "&amp;")
//    }
//    
//    func testRenderFunctionInheritTextContentTypeOfCurrentlyRenderedTemplate() {
//        let box = Box([
//            "object": Box("&"),
//            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//                let altTemplate = Template(string: "{{ object }}")!
//                return altTemplate.render(info.context, error: error)
//            })])
//        
//        let template = Template(string: "{{%CONTENT_TYPE:TEXT}}{{render}}")!
//        let rendering = template.render(box)!
//        XCTAssertEqual(rendering, "&")
//    }
//    
//    func testRenderFunctionInheritContentTypeFromPartial() {
//        let repository = TemplateRepository(templates: [
//            "templateHTML": "{{ render }}|{{> templateText }}",
//            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ render }}"])
//        let box = Box([
//            "value": Box("&"),
//            "render": Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//                let altTemplate = Template(string: "{{ value }}")!
//                return altTemplate.render(info.context, error: error)
//            })])
//        let template = repository.template(named: "templateHTML")!
//        let rendering = template.render(box)!
//        XCTAssertEqual(rendering, "&amp;|&amp;")
//    }
//    
//    func testRenderFunctionInheritContentTypeFromTemplateAsRenderFunction() {
//        let repository1 = TemplateRepository(templates: [
//            "templateHTML": "{{ render }}|{{ templateText }}"])
//        let repository2 = TemplateRepository(templates: [
//            "templateText": "{{ render }}"])
//        repository2.configuration.contentType = .Text
//        
//        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            let altTemplate = Template(string: "{{{ value }}}")!
//            return altTemplate.render(info.context, error: error)
//        }
//        let box = Box([
//            "value": Box("&"),
//            "templateText": Box(repository2.template(named: "templateText")!),
//            "render": Box(render)])
//        let template = repository1.template(named: "templateHTML")!
//        let rendering = template.render(box)!
//        XCTAssertEqual(rendering, "&|&amp;")
//    }
    
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
    
    func testMustacheSpecInterpolation() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L15
        let lambda = Lambda { "world" }
        let template = Template(string: "Hello, {{lambda}}!")!
        let data = [
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "Hello, world!")
    }
    
    func testMustacheSpecInterpolationExpansion() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L29
        let lambda = Lambda { "{{planet}}" }
        let template = Template(string: "Hello, {{lambda}}!")!
        let data = [
            "planet": Box("world"),
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "Hello, world!")
    }
    
    func testMustacheSpecInterpolationAlternateDelimiters() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L44
        // With a difference: remove the "\n" character because GRMustache does
        // not honor mustache spec white space rules.
        let lambda = Lambda { "|planet| => {{planet}}" }
        let template = Template(string: "{{= | | =}}Hello, (|&lambda|)!")!
        let data = [
            "planet": Box("world"),
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "Hello, (|planet| => world)!")
    }
    
    func testMustacheSpecMultipleCalls() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L59
        var calls = 0
        let lambda = Lambda { calls += 1; return "\(calls)" }
        let template = Template(string: "{{lambda}} == {{{lambda}}} == {{lambda}}")!
        let data = [
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "1 == 2 == 3")
    }
    
    func testMustacheSpecEscaping() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L73
        var calls = 0
        let lambda = Lambda { ">" }
        let template = Template(string: "<{{lambda}}{{{lambda}}}")!
        let data = [
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "<&gt;>")
    }
    
    func testMustacheSpecSection() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L87
        var calls = 0
        let lambda = Lambda { (string: String) in
            if string == "{{x}}" {
                return "yes"
            } else {
                return "no"
            }
        }
        let template = Template(string: "<{{#lambda}}{{x}}{{/lambda}}>")!
        let data = [
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "<yes>")
    }
    
    func testMustacheSpecSectionExpansion() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L102
        var calls = 0
        let lambda = Lambda { (string: String) in
            return "\(string){{planet}}\(string)"
        }
        let template = Template(string: "<{{#lambda}}-{{/lambda}}>")!
        let data = [
            "planet": Box("Earth"),
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "<-Earth->")
    }
    
    func testMustacheSpecSectionAlternateDelimiters() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L117
        var calls = 0
        let lambda = Lambda { (string: String) in
            return "\(string){{planet}} => |planet|\(string)"
        }
        let template = Template(string: "{{= | | =}}<|#lambda|-|/lambda|>")!
        let data = [
            "planet": Box("Earth"),
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "<-{{planet}} => Earth->")
    }
    
    func testMustacheSpecSectionMultipleCalls() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L132
        var calls = 0
        let lambda = Lambda { (string: String) in
            return  "__\(string)__"
        }
        let template = Template(string: "{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}")!
        let data = [
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "__FILE__ != __LINE__")
    }
    
    func testMustacheSpecInvertedSection() {
        // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L146
        var calls = 0
        let lambda = Lambda { (string: String) in
            return  ""
        }
        let template = Template(string: "<{{^lambda}}{{static}}{{/lambda}}>")!
        let data = [
            "lambda": Box(lambda),
        ]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "<>")
    }
    
    func testArity0LambdaInSectionTag() {
        let lambda = Lambda { "success" }
        let template = Template(string: "{{#lambda}}<{{.}}>{{/lambda}}")!
        let rendering = template.render(Box(["lambda": Box(lambda)]))!
        XCTAssertEqual(rendering, "<success>")
    }
    
    func testArity1LambdaInVariableTag() {
        let lambda = Lambda { (string) in string }
        let template = Template(string: "<{{lambda}}>")!
        let rendering = template.render(Box(["lambda": Box(lambda)]))!
        XCTAssertEqual(rendering, "<(Lambda)>")
    }
}
