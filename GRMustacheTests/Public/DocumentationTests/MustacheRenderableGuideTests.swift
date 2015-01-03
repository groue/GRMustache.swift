//
//  MustacheRenderableGuideTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 23/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class MustacheRenderableGuideTests: XCTestCase {
    
    func testExample1() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("I'm rendering a {{ variable }} tag.")
            case .Section:
                return Rendering("I'm rendering a {{# section }}...{{/ }} tag.")
            }
        }
        
        var rendering = Template(string: "{{.}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{ variable }} tag.")
        
        rendering = Template(string: "{{#.}}{{/}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{# section }}...{{/ }} tag.")
    }
    
    func textExample2() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("Arthur & Cie")
        }
        
        let rendering = Template(string: "{{.}}|{{{.}}}")!.render(Box(render))!
        XCTAssertEqual(rendering, "Arthur &amp; Cie|Arthur & Cie")
    }
    
    func textExample3() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("<strong>\(rendering.string)</strong>", rendering.contentType)
        }
        
        let box = Box([
            "strong": Box(render),
            "name": Box("Arthur")])
        let rendering = Template(string: "{{#strong}}{{name}}{{/strong}}")!.render(box)!
        XCTAssertEqual(rendering, "<strong>Arthur</strong>")
    }
    
    func textExample4() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering(rendering.string + rendering.string, rendering.contentType)
        }
        let box = Box(["twice": Box(render)])
        let rendering = Template(string: "{{#twice}}Success{{/twice}}")!.render(box)!
        XCTAssertEqual(rendering, "SuccessSuccess")
    }

    func textExample5() {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "<a href=\"{{url}}\">\(info.tag.innerTemplateString)</a>")!
            return template.render(info.context, error: error)
        }
        let box = Box([
            "link": Box(render),
            "name": Box("Arthur"),
            "url": Box("/people/123")])
        let rendering = Template(string: "{{# link }}{{ name }}{{/ link }}")!.render(box)!
        XCTAssertEqual(rendering, "<a href=\"/people/123\">Arthur</a>")
    }
    
    func testExample6() {
        let repository = TemplateRepository(templates: [
            "movieLink": "<a href=\"{{url}}\">{{title}}</a>",
            "personLink": "<a href=\"{{url}}\">{{name}}</a>"])
        let link1 = Box(repository.template(named: "movieLink")!)
        let item1 = Box([
            "title": Box("Citizen Kane"),
            "url": Box("/movies/321"),
            "link": link1])
        let link2 = Box(repository.template(named: "personLink")!)
        let item2 = Box([
            "name": Box("Orson Welles"),
            "url": Box("/people/123"),
            "link": link2])
        let box = Box(["items": Box([item1, item2])])
        let rendering = Template(string: "{{#items}}{{link}}{{/items}}")!.render(box)!
        XCTAssertEqual(rendering, "<a href=\"/movies/321\">Citizen Kane</a><a href=\"/people/123\">Orson Welles</a>")
    }
    
    func testExample7() {
        struct Person: MustacheBoxable {
            let firstName: String
            let lastName: String
            func mustacheBox() -> Box {
                let inspector = { (key: String) -> Box? in
                    switch key {
                    case "firstName":
                        return Box(self.firstName)
                    case "lastName":
                        return Box(self.lastName)
                    default:
                        return nil
                    }
                }
                let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                    let template = Template(named: "Person", bundle: NSBundle(forClass: MustacheRenderableGuideTests.self))!
                    let context = info.context.extendedContext(Box(self))
                    return template.render(context, error: error)
                }
                return Box(
                    value: self,
                    inspector: inspector,
                    render: render)
            }
        }
        
        struct Movie: MustacheBoxable {
            let title: String
            let director: Person
            func mustacheBox() -> Box {
                let inspector = { (key: String) -> Box? in
                    switch key {
                    case "title":
                        return Box(self.title)
                    case "director":
                        return Box(self.director)
                    default:
                        return nil
                    }
                }
                let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                    let template = Template(named: "Movie", bundle: NSBundle(forClass: MustacheRenderableGuideTests.self))!
                    let context = info.context.extendedContext(Box(self))
                    return template.render(context, error: error)
                }
                return Box(
                    value: self,
                    inspector: inspector,
                    render: render)
            }
        }
        
        let director = Person(firstName: "Orson", lastName: "Welles")
        let movie = Movie(title:"Citizen Kane", director: director)
        
        let template = Template(string: "{{ movie }}")!
        let rendering = template.render(Box(["movie": Box(movie)]))!
        XCTAssertEqual(rendering, "Citizen Kane by Orson Welles")
    }
    
    func testExample8() {
        let listFilter = { (box: Box, info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let items = box.value as [Box]
            var buffer = "<ul>"
            for item in items {
                let itemContext = info.context.extendedContext(item)
                let itemRendering = info.tag.render(itemContext)!
                buffer += "<li>\(itemRendering.string)</li>"
            }
            buffer += "</ul>"
            return Rendering(buffer, .HTML)
        }
        
        let template = Template(string: "{{#list(nav)}}<a href=\"{{url}}\">{{title}}</a>{{/}}")!
        template.baseContext = template.baseContext.extendedContext(Box(["list": Box(MakeFilter(listFilter))]))
        
        let item1 = Box([
            "url": "http://mustache.github.io",
            "title": "Mustache"])
        let item2 = Box([
            "url": "http://github.com/groue/GRMustache.swift",
            "title": "GRMustache.swift"])
        let box = Box(["nav": Box([item1, item2])])
        
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "<ul><li><a href=\"http://mustache.github.io\">Mustache</a></li><li><a href=\"http://github.com/groue/GRMustache.swift\">GRMustache.swift</a></li></ul>")
    }
}
