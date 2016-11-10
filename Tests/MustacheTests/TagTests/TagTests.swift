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

class TagTests: XCTestCase {

    func testTagDescriptionContainsTagToken() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        var template = try! Template(string: "{{name}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: "{{name}}")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(string: "{{#name}}{{/name}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: "{{#name}}")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(string: "{{  name\t}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: "{{  name\t}}")
        XCTAssertTrue(range != nil)
    }

    func testTagDescriptionContainsLineNumber() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        var template = try! Template(string: "{{name}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: "line 1")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(string: "\n {{\nname}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: "line 2")
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(string: "\n\n  {{#\nname}}\n\n{{/name}}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: "line 3")
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsResourceBasedTemplatePath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = Bundle(for: type(of: self))
        let templateRepository = TemplateRepository(bundle: bundle)
        var template = try! templateRepository.template(named: "TagTests")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        tagDescription = nil
        template = try! Template(named: "TagTests", bundle: bundle)
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsURLBasedTemplatePath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = Bundle(for: type(of: self))
        let templateRepository = TemplateRepository(baseURL: bundle.resourceURL!)
        var template = try! templateRepository.template(named: "TagTests")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(URL: bundle.url(forResource: "TagTests", withExtension: "mustache")!)
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsPathBasedTemplatePath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = Bundle(for: type(of: self))
        let templateRepository = TemplateRepository(directoryPath: bundle.resourcePath!)
        var template = try! templateRepository.template(named: "TagTests")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(path: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsResourceBasedPartialPath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = Bundle(for: type(of: self))
        let templateRepository = TemplateRepository(bundle: bundle)
        var template = try! templateRepository.template(named: "TagTests_wrapper")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        tagDescription = nil
        template = try! templateRepository.template(string: "{{> TagTests }}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)

        tagDescription = nil
        template = try! Template(named: "TagTests_wrapper", bundle: bundle)
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsURLBasedPartialPath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = Bundle(for: type(of: self))
        let templateRepository = TemplateRepository(baseURL: bundle.resourceURL!)
        var template = try! templateRepository.template(named: "TagTests_wrapper")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! templateRepository.template(string: "{{> TagTests }}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(URL: bundle.url(forResource: "TagTests_wrapper", withExtension: "mustache")!)
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
    
    func testTagDescriptionContainsPathBasedPartialPath() {
        var tagDescription: String? = nil
        let willRender = { (tag: Tag, box: MustacheBox) -> Any? in
            tagDescription = tag.description
            return box
        }
        
        tagDescription = nil
        let bundle = Bundle(for: type(of: self))
        let templateRepository = TemplateRepository(directoryPath: bundle.resourcePath!)
        var template = try! templateRepository.template(named: "TagTests_wrapper")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        var range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! templateRepository.template(string: "{{> TagTests }}")
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
        
        tagDescription = nil
        template = try! Template(path: bundle.path(forResource: "TagTests_wrapper", ofType: "mustache")!)
        template.baseContext = template.baseContext.extendedContext(willRender)
        _ = try! template.render()
        range = tagDescription?.range(of: bundle.path(forResource: "TagTests", ofType: "mustache")!)
        XCTAssertTrue(range != nil)
    }
}
