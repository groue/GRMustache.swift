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

class MustacheRenderableGuideTests: XCTestCase {
    
    func testExample1() {
        let render = { (info: RenderingInfo) -> Rendering in
            switch info.tag.type {
            case .variable:
                return Rendering("I'm rendering a {{ variable }} tag.")
            case .section:
                return Rendering("I'm rendering a {{# section }}...{{/ }} tag.")
            }
        }
        
        var rendering = try! Template(string: "{{.}}").render(render)
        XCTAssertEqual(rendering, "I&apos;m rendering a {{ variable }} tag.")
        
        rendering = try! Template(string: "{{#.}}{{/}}").render(render)
        XCTAssertEqual(rendering, "I&apos;m rendering a {{# section }}...{{/ }} tag.")
    }
    
    func textExample2() {
        let render = { (info: RenderingInfo) -> Rendering in
            return Rendering("Arthur & Cie")
        }
        
        let rendering = try! Template(string: "{{.}}|{{{.}}}").render(render)
        XCTAssertEqual(rendering, "Arthur &amp; Cie|Arthur & Cie")
    }
    
    func textExample3() {
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try! info.tag.render(info.context)
            return Rendering("<strong>\(rendering.string)</strong>", rendering.contentType)
        }
        
        let value: [String: Any] = [
            "strong": render,
            "name": "Arthur"]
        let rendering = try! Template(string: "{{#strong}}{{name}}{{/strong}}").render(value)
        XCTAssertEqual(rendering, "<strong>Arthur</strong>")
    }
    
    func textExample4() {
        let render = { (info: RenderingInfo) -> Rendering in
            let rendering = try! info.tag.render(info.context)
            return Rendering(rendering.string + rendering.string, rendering.contentType)
        }
        let value = ["twice": render]
        let rendering = try! Template(string: "{{#twice}}Success{{/twice}}").render(value)
        XCTAssertEqual(rendering, "SuccessSuccess")
    }

    func textExample5() {
        let render = { (info: RenderingInfo) -> Rendering in
            let template = try! Template(string: "<a href=\"{{url}}\">\(info.tag.innerTemplateString)</a>")
            return try template.render(info.context)
        }
        let value: [String: Any] = [
            "link": render,
            "name": "Arthur",
            "url": "/people/123"]
        let rendering = try! Template(string: "{{# link }}{{ name }}{{/ link }}").render(value)
        XCTAssertEqual(rendering, "<a href=\"/people/123\">Arthur</a>")
    }
    
    func testExample6() {
        let repository = TemplateRepository(templates: [
            "movieLink": "<a href=\"{{url}}\">{{title}}</a>",
            "personLink": "<a href=\"{{url}}\">{{name}}</a>"])
        let link1 = try! repository.template(named: "movieLink")
        let item1: [String: Any] = [
            "title": "Citizen Kane",
            "url": "/movies/321",
            "link": link1]
        let link2 = try! repository.template(named: "personLink")
        let item2: [String: Any] = [
            "name": "Orson Welles",
            "url": "/people/123",
            "link": link2]
        let value = ["items": [item1, item2]]
        let rendering = try! Template(string: "{{#items}}{{link}}{{/items}}").render(value)
        XCTAssertEqual(rendering, "<a href=\"/movies/321\">Citizen Kane</a><a href=\"/people/123\">Orson Welles</a>")
    }
    
    func testExample7() {
        struct Person : MustacheBoxable {
            let firstName: String
            let lastName: String
            var mustacheBox: MustacheBox {
                let keyedSubscript = { (key: String) -> Any? in
                    switch key {
                    case "firstName":
                        return self.firstName
                    case "lastName":
                        return self.lastName
                    default:
                        return nil
                    }
                }
                let render = { (info: RenderingInfo) -> Rendering in
                    let template = try! Template(named: "Person", bundle: Bundle(for: MustacheRenderableGuideTests.self))
                    let context = info.context.extendedContext(self)
                    return try template.render(context)
                }
                return MustacheBox(
                    value: self,
                    keyedSubscript: keyedSubscript,
                    render: render)
            }
        }
        
        struct Movie : MustacheBoxable {
            let title: String
            let director: Person
            var mustacheBox: MustacheBox {
                let keyedSubscript = { (key: String) -> Any? in
                    switch key {
                    case "title":
                        return self.title
                    case "director":
                        return self.director
                    default:
                        return nil
                    }
                }
                let render = { (info: RenderingInfo) -> Rendering in
                    let template = try! Template(named: "Movie", bundle: Bundle(for: MustacheRenderableGuideTests.self))
                    let context = info.context.extendedContext(self)
                    return try template.render(context)
                }
                return MustacheBox(
                    value: self,
                    keyedSubscript: keyedSubscript,
                    render: render)
            }
        }
        
        let director = Person(firstName: "Orson", lastName: "Welles")
        let movie = Movie(title:"Citizen Kane", director: director)
        
        let template = try! Template(string: "{{ movie }}")
        let rendering = try! template.render(["movie": movie])
        XCTAssertEqual(rendering, "Citizen Kane by Orson Welles")
    }
    
    func testExample8() {
        let listFilter = { (box: MustacheBox, info: RenderingInfo) -> Rendering in
            guard let items = box.arrayValue else {
                return Rendering("")
            }
            
            var buffer = "<ul>"
            for item in items {
                let itemContext = info.context.extendedContext(item)
                let itemRendering = try! info.tag.render(itemContext)
                buffer += "<li>\(itemRendering.string)</li>"
            }
            buffer += "</ul>"
            return Rendering(buffer, .html)
        }
        
        let template = try! Template(string: "{{#list(nav)}}<a href=\"{{url}}\">{{title}}</a>{{/}}")
        template.baseContext = template.baseContext.extendedContext(["list": Filter(listFilter)])
        
        let item1 = [
            "url": "http://mustache.github.io",
            "title": "Mustache"]
        let item2 = [
            "url": "http://github.com/groue/GRMustache.swift",
            "title": "GRMustache.swift"]
        let value = ["nav": [item1, item2]]
        
        let rendering = try! template.render(value)
        XCTAssertEqual(rendering, "<ul><li><a href=\"http://mustache.github.io\">Mustache</a></li><li><a href=\"http://github.com/groue/GRMustache.swift\">GRMustache.swift</a></li></ul>")
    }
}
