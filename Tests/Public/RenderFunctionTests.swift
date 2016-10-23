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

    enum CustomError : Error {
        case error
    }
    
    func testRenderFunctionInVariableTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("---")
        }
        let rendering = try! Template(string: "{{.}}").render(render)
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderFunctionInSectionTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("---")
        }
        let rendering = try! Template(string: "{{#.}}{{/.}}").render(render)
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderFunctionInInvertedSectionTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("---")
        }
        let rendering = try! Template(string: "{{^.}}{{/.}}").render(render)
        XCTAssertEqual(rendering, "")
    }
    
    func testRenderFunctionHTMLRenderingOfEscapedVariableTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("&", .html)
        }
        let rendering = try! Template(string: "{{.}}").render(render)
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionHTMLRenderingOfUnescapedVariableTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("&", .html)
        }
        let rendering = try! Template(string: "{{{.}}}").render(render)
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionTextRenderingOfEscapedVariableTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("&")
        }
        let rendering = try! Template(string: "{{.}}").render(render)
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderFunctionTextRenderingOfUnescapedVariableTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("&")
        }
        let rendering = try! Template(string: "{{{.}}}").render(render)
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionHTMLRenderingOfSectionTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("&", .html)
        }
        let rendering = try! Template(string: "{{#.}}{{/.}}").render(render)
        XCTAssertEqual(rendering, "&")
    }
    
    func testRenderFunctionTextRenderingOfSectionTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("&")
        }
        let rendering = try! Template(string: "{{#.}}{{/.}}").render(render)
        XCTAssertEqual(rendering, "&amp;")
    }
    
    func testRenderFunctionCanThrowNSErrorFromVariableTag() {
        let errorDomain = "ClusterTests"
        let render = { (info: RenderingInfo) -> Rendering in
            throw NSError(domain: errorDomain, code: 0, userInfo: nil)
        }
        do {
            _ = try Template(string: "{{.}}").render(render)
            XCTAssert(false)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, errorDomain)
        }
    }
    
    func testRenderFunctionCanThrowCustomErrorFromVariableTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            throw CustomError.error
        }
        do {
            _ = try Template(string: "\n\n{{.}}").render(render)
            XCTAssert(false)
        } catch CustomError.error {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testRenderFunctionCanThrowNSErrorFromSectionTag() {
        let errorDomain = "ClusterTests"
        let render = { (info: RenderingInfo) -> Rendering in
            throw NSError(domain: errorDomain, code: 0, userInfo: nil)
        }
        do {
            _ = try Template(string: "{{#.}}{{/.}}").render(render)
            XCTAssert(false)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, errorDomain)
        }
    }
    
    func testRenderFunctionCanThrowCustomErrorFromSectionTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            throw CustomError.error
        }
        do {
            _ = try Template(string: "\n\n{{#.}}\n\n{{/.}}").render(render)
            XCTAssert(false)
        } catch CustomError.error {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testRenderFunctionCanAccessVariableTagType() {
        var variableTagDetections = 0
        let render = { (info: RenderingInfo) -> Rendering in
            switch info.tag.type {
            case .variable:
                variableTagDetections += 1
            default:
                break
            }
            return Rendering("")
        }
        _ = try! Template(string: "{{.}}").render(render)
        XCTAssertEqual(variableTagDetections, 1)
    }
    
    func testRenderFunctionCanAccessSectionTagType() {
        var sectionTagDetections = 0
        let render = { (info: RenderingInfo) -> Rendering in
            switch info.tag.type {
            case .section:
                sectionTagDetections += 1
            default:
                break
            }
            return Rendering("")
        }
        _ = try! Template(string: "{{#.}}{{/.}}").render(render)
        XCTAssertEqual(sectionTagDetections, 1)
    }
    
    func testRenderFunctionCanAccessInnerTemplateStringFromSectionTag() {
        var innerTemplateString: String? = nil
        let render = { (info: RenderingInfo) -> Rendering in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        _ = try! Template(string: "{{#.}}{{subject}}{{/.}}").render(render)
        XCTAssertEqual(innerTemplateString!, "{{subject}}")
    }
    
    func testRenderFunctionCanAccessInnerTemplateStringFromVariableTag() {
        var innerTemplateString: String? = nil
        let render = { (info: RenderingInfo) -> Rendering in
            innerTemplateString = info.tag.innerTemplateString
            return Rendering("")
        }
        _ = try! Template(string: "{{.}}").render(render)
        XCTAssertEqual(innerTemplateString!, "")
    }
    
    func testRenderFunctionCanAccessRenderedContentFromSectionTag() {
        var tagRendering: Rendering? = nil
        let render = { (info: RenderingInfo) -> Rendering in
            tagRendering = try info.tag.render(info.context)
            return tagRendering!
        }
        
        let value: [String: Any] = ["render": render, "subject": "-"]
        _ = try! Template(string: "{{#render}}{{subject}}={{subject}}{{/render}}").render(value)
        XCTAssertEqual(tagRendering!.string, "-=-")
        XCTAssertEqual(tagRendering!.contentType, ContentType.html)
    }
    
    func testRenderFunctionCanAccessRenderedContentFromEscapedVariableTag() {
        var tagRendering: Rendering? = nil
        let render = { (info: RenderingInfo) -> Rendering in
            tagRendering = try info.tag.render(info.context)
            return tagRendering!
        }
        
        _ = try! Template(string: "{{.}}").render(render)
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.html)
    }
    
    func testRenderFunctionCanAccessRenderedContentFromUnescapedVariableTag() {
        var tagRendering: Rendering? = nil
        let render = { (info: RenderingInfo) -> Rendering in
            tagRendering = try info.tag.render(info.context)
            return tagRendering!
        }
        
        _ = try! Template(string: "{{{.}}}").render(render)
        
        XCTAssertEqual(tagRendering!.string, "")
        XCTAssertEqual(tagRendering!.contentType, ContentType.html)
    }
    
    func testRenderFunctionCanRenderCurrentContextInAnotherTemplateFromVariableTag() {
        let altTemplate = try! Template(string:"{{subject}}")
        let render = { (info: RenderingInfo) -> Rendering in
            return try altTemplate.render(info.context)
        }
        let value: [String: Any] = ["render": render, "subject": "-"]
        let rendering = try! Template(string: "{{render}}").render(value)
        XCTAssertEqual(rendering, "-")
    }
    
    func testRenderFunctionCanRenderCurrentContextInAnotherTemplateFromSectionTag() {
        let altTemplate = try! Template(string:"{{subject}}")
        let render = { (info: RenderingInfo) -> Rendering in
            return try altTemplate.render(info.context)
        }
        let value: [String: Any] = ["render": render, "subject": "-"]
        let rendering = try! Template(string: "{{#render}}{{/render}}").render(value)
        XCTAssertEqual(rendering, "-")
    }

    func testRenderFunctionDoesNotAutomaticallyEntersVariableContextStack() {
        let keyedSubscript = { (key: String) -> Any? in
            return "value"
        }
        let render = { (info: RenderingInfo) -> Rendering in
            return try Template(string:"key:{{key}}").render(info.context)
        }
        let value: [String: Any] = ["render": MustacheBox(keyedSubscript: keyedSubscript, render: render)]
        let rendering = try! Template(string: "{{render}}").render(value)
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderFunctionDoesNotAutomaticallyEntersSectionContextStack() {
        let keyedSubscript = { (key: String) -> Any? in
            return "value"
        }
        let render = { (info: RenderingInfo) -> Rendering in
            return try info.tag.render(info.context)
        }
        let value: [String: Any] = ["render": MustacheBox(keyedSubscript: keyedSubscript, render: render)]
        let rendering = try! Template(string: "{{#render}}key:{{key}}{{/render}}").render(value)
        XCTAssertEqual(rendering, "key:")
    }
    
    func testRenderFunctionCanExtendValueContextStackInVariableTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            let context = info.context.extendedContext(["subject2": "+++"])
            let template = try! Template(string: "{{subject}}{{subject2}}")
            return try template.render(context)
        }
        let value: [String: Any] = ["render": render, "subject": "---"]
        let rendering = try! Template(string: "{{render}}").render(value)
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderFunctionCanExtendValueContextStackInSectionTag() {
        let render = { (info: RenderingInfo) -> Rendering in
            return try info.tag.render(info.context.extendedContext(["subject2": "+++"]))
        }
        let value: [String: Any] = ["render": render, "subject": "---"]
        let rendering = try! Template(string: "{{#render}}{{subject}}{{subject2}}{{/render}}").render(value)
        XCTAssertEqual(rendering, "---+++")
    }
    
    func testRenderFunctionCanExtendWillRenderStackInVariableTag() {
        var tagWillRenderCount = 0
        let render = { (info: RenderingInfo) -> Rendering in
            let context = info.context.extendedContext({ (tag: Tag, box: MustacheBox) -> Any? in
                tagWillRenderCount += 1
                return box
            })
            let template = try! Template(string: "{{subject}}{{subject}}")
            return try template.render(context)
        }
        let value: [String: Any] = ["render": render, "subject": "-"]
        let rendering = try! Template(string: "{{subject}}{{render}}{{subject}}{{subject}}{{subject}}{{subject}}").render(value)
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(tagWillRenderCount, 2)
    }
    
    func testRenderFunctionCanExtendWillRenderStackInSectionTag() {
        var tagWillRenderCount = 0
        let render = { (info: RenderingInfo) -> Rendering in
            return try info.tag.render(info.context.extendedContext({ (tag: Tag, box: MustacheBox) -> Any? in
                tagWillRenderCount += 1
                return box
            }))
        }
        let value: [String: Any] = ["render": render, "subject": "-"]
        let rendering = try! Template(string: "{{subject}}{{#render}}{{subject}}{{subject}}{{/render}}{{subject}}{{subject}}{{subject}}{{subject}}").render(value)
        XCTAssertEqual(rendering, "-------")
        XCTAssertEqual(tagWillRenderCount, 2)
    }
    
    func testRenderFunctionTriggersWillRenderFunctions() {
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            switch tag.type {
            case .section:
                return box
            default:
                return "delegate"
            }
        }
        
        let render = { (info: RenderingInfo) -> Rendering in
            return try info.tag.render(info.context)
        }
        
        let template = try! Template(string: "{{#render}}{{subject}}{{/render}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        let value: [String: Any] = ["render": render, "subject": "---"]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderFunctionTriggersWillRenderFunctionsInAnotherTemplateFromVariableTag() {
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            switch tag.type {
            case .section:
                return box
            default:
                return "delegate"
            }
        }
        
        let render = { (info: RenderingInfo) -> Rendering in
            let template = try Template(string: "{{subject}}")
            return try template.render(info.context)
        }
        
        let template = try! Template(string: "{{render}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        let value: [String: Any] = ["render": render, "subject": "---"]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testRenderFunctionTriggersWillRenderFunctionsInAnotherTemplateFromSectionTag() {
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            switch tag.type {
            case .section:
                return box
            default:
                return "delegate"
            }
        }
        
        let render = { (info: RenderingInfo) -> Rendering in
            let template = try Template(string: "{{subject}}")
            return try template.render(info.context)
        }
        
        let template = try! Template(string: "{{#render}}{{/render}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        let value: [String: Any] = ["render": render, "subject": "---"]
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "delegate")
    }
    
    func testArrayOfRenderFunctionsInSectionTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("1")
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("2")
        }
        let value: [String: Any] = ["items": [render1, render2]]
        let rendering = try! Template(string: "{{#items}}{{/items}}").render(value)
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfRenderFunctionsInEscapedVariableTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("1")
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("2")
        }
        let value: [String: Any] = ["items": [render1, render2]]
        let rendering = try! Template(string: "{{items}}").render(value)
        XCTAssertEqual(rendering, "12")
    }
    
    func testArrayOfHTMLRenderFunctionsInEscapedVariableTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<1>", .html)
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<2>", .html)
        }
        let value: [String: Any] = ["items": [render1, render2]]
        let rendering = try! Template(string: "{{items}}").render(value)
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfHTMLRenderFunctionsInUnescapedVariableTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<1>", .html)
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<2>", .html)
        }
        let value: [String: Any] = ["items": [render1, render2]]
        let rendering = try! Template(string: "{{{items}}}").render(value)
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfTextRenderFunctionsInEscapedVariableTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<2>")
        }
        let value: [String: Any] = ["items": [render1, render2]]
        let rendering = try! Template(string: "{{items}}").render(value)
        XCTAssertEqual(rendering, "&lt;1&gt;&lt;2&gt;")
    }
    
    func testArrayOfTextRenderFunctionsInUnescapedVariableTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<2>")
        }
        let value: [String: Any] = ["items": [render1, render2]]
        let rendering = try! Template(string: "{{{items}}}").render(value)
        XCTAssertEqual(rendering, "<1><2>")
    }
    
    func testArrayOfInconsistentContentTypeRenderFunctionsInVariableTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<2>", .html)
        }
        let value: [String: Any] = ["items": [render1, render2]]
        do {
            _ = try Template(string: "{{items}}").render(value)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testArrayOfInconsistentContentTypeRenderFunctionsInSectionTag() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<1>")
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            return Rendering("<2>", .html)
        }
        let value: [String: Any] = ["items": [render1, render2]]
        do {
            _ = try Template(string: "{{#items}}{{/items}}").render(value)
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.renderError)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
    
    func testDynamicPartial() {
        let repository = TemplateRepository(templates: ["partial": "{{subject}}"])
        let template = try! repository.template(named: "partial")
        let value: [String: Any] = ["partial": template, "subject": "---"]
        let rendering = try! Template(string: "{{partial}}").render(value)
        XCTAssertEqual(rendering, "---")
    }
    
    func testDynamicPartialIsNotHTMLEscaped() {
        let repository = TemplateRepository(templates: ["partial": "<{{subject}}>"])
        let template = try! repository.template(named: "partial")
        let value: [String: Any] = ["partial": template, "subject": "---"]
        let rendering = try! Template(string: "{{partial}}").render(value)
        XCTAssertEqual(rendering, "<--->")
    }
    
    func testDynamicPartialOverride() {
        let repository = TemplateRepository(templates: [
            "layout": "<{{$a}}Default{{subject}}{{/a}},{{$b}}Ignored{{/b}}>",
            "partial": "[{{#layout}}---{{$b}}Overriden{{subject}}{{/b}}---{{/layout}}]"])
        let template = try! repository.template(named: "partial")
        let data: [String: Any] = [
            "layout": try! repository.template(named: "layout"),
            "subject": "---"]
        let rendering = try! template.render(data)
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
//        let render = { (info: RenderingInfo) -> Rendering in
//            let altTemplate = Template(string: "{{>partial}}")!
//            return altTemplate.render(info.context, error: error)
//        }
//        let value: [String: Any] = ["render": render, "subject": "-"]
//        let template = repository.template(named: "template")!
//        let rendering = template.render(value)!
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
//        let value: [String: Any] = [
//            "template2": repository2.template(named: "template2")!,
//            "render": { (info: RenderingInfo) -> Rendering in
//                let altTemplate = Template(string: "{{>partial}}")!
//                return altTemplate.render(info.context, error: error)
//            }]
//        let template = repository1.template(named: "template1")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "partial1|partial2")
//    }
//    
//    func testRenderFunctionInheritHTMLContentTypeOfCurrentlyRenderedTemplate() {
//        let value: [String: Any] = [
//            "object": "&",
//            "render": { (info: RenderingInfo) -> Rendering in
//                let altTemplate = Template(string: "{{ object }}")!
//                return altTemplate.render(info.context, error: error)
//            }]
//        
//        let template = Template(string: "{{%CONTENT_TYPE:HTML}}{{render}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "&amp;")
//    }
//    
//    func testRenderFunctionInheritTextContentTypeOfCurrentlyRenderedTemplate() {
//        let value: [String: Any] = [
//            "object": "&",
//            "render": { (info: RenderingInfo) -> Rendering in
//                let altTemplate = Template(string: "{{ object }}")!
//                return altTemplate.render(info.context, error: error)
//            }]
//        
//        let template = Template(string: "{{%CONTENT_TYPE:TEXT}}{{render}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "&")
//    }
//    
//    func testRenderFunctionInheritContentTypeFromPartial() {
//        let repository = TemplateRepository(templates: [
//            "templateHTML": "{{ render }}|{{> templateText }}",
//            "templateText": "{{% CONTENT_TYPE:TEXT }}{{ render }}"])
//        let value: [String: Any] = [
//            "value": "&",
//            "render": { (info: RenderingInfo) -> Rendering in
//                let altTemplate = Template(string: "{{ value }}")!
//                return altTemplate.render(info.context, error: error)
//            }]
//        let template = repository.template(named: "templateHTML")!
//        let rendering = template.render(value)!
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
//        let render = { (info: RenderingInfo) -> Rendering in
//            let altTemplate = Template(string: "{{{ value }}}")!
//            return altTemplate.render(info.context, error: error)
//        }
//        let value: [String: Any] = [
//            "value": "&",
//            "templateText": repository2.template(named: "templateText")!,
//            "render": render]
//        let template = repository1.template(named: "templateHTML")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "&|&amp;")
//    }
    
    func testArrayOfRenderFunctionsInSectionTagDoesNotNeedExplicitInvocation() {
        let render1 = { (info: RenderingInfo) -> Rendering in
            let rendering = try! info.tag.render(info.context)
            return Rendering("[1:\(rendering.string)]", rendering.contentType)
        }
        let render2 = { (info: RenderingInfo) -> Rendering in
            let rendering = try! info.tag.render(info.context)
            return Rendering("[2:\(rendering.string)]", rendering.contentType)
        }
        let renders: [Any] = [render1, render2, true, false]
        let template = try! Template(string: "{{#items}}---{{/items}},{{#items}}{{#.}}---{{/.}}{{/items}}")
        let rendering = try! template.render(["items": renders])
        XCTAssertEqual(rendering, "[1:---][2:---]------,[1:---][2:---]---")
    }
}
