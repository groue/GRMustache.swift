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
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("I'm rendering a {{ variable }} tag.")
            case .Section:
                return Rendering("I'm rendering a {{# section }}...{{/ }} tag.")
            }
        }
        
        var rendering = Template(string: "{{.}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{ variable }} tag.")
        
        rendering = Template(string: "{{#.}}{{/}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{# section }}...{{/ }} tag.")
    }
    
    func textExample2() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("Arthur & Cie")
        }
        
        let rendering = Template(string: "{{.}}|{{{.}}}")!.render(BoxedRenderable(renderable))!
        XCTAssertEqual(rendering, "Arthur &amp; Cie|Arthur & Cie")
    }
    
    func textExample3() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("<strong>\(rendering.string)</strong>", rendering.contentType)
        }
        
        let value = Box([
            "strong": BoxedRenderable(renderable),
            "name": Box("Arthur")])
        let rendering = Template(string: "{{#strong}}{{name}}{{/strong}}")!.render(value)!
        XCTAssertEqual(rendering, "<strong>Arthur</strong>")
    }
    
    func textExample4() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering(rendering.string + rendering.string, rendering.contentType)
        }
        let value = Box(["twice": BoxedRenderable(renderable)])
        let rendering = Template(string: "{{#twice}}Success{{/twice}}")!.render(value)!
        XCTAssertEqual(rendering, "SuccessSuccess")
    }

    func textExample5() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "<a href=\"{{url}}\">\(info.tag.innerTemplateString)</a>")!
            return template.render(info.context, error: error)
        }
        let value = Box([
            "link": BoxedRenderable(renderable),
            "name": Box("Arthur"),
            "url": Box("/people/123")])
        let rendering = Template(string: "{{# link }}{{ name }}{{/ link }}")!.render(value)!
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
        let value = Box(["items": Box([item1, item2])])
        let rendering = Template(string: "{{#items}}{{link}}{{/items}}")!.render(value)!
        XCTAssertEqual(rendering, "<a href=\"/movies/321\">Citizen Kane</a><a href=\"/people/123\">Orson Welles</a>")
    }
    
    func testExample7() {
        struct Person: MustacheRenderable, MustacheInspectable {
            let firstName: String
            let lastName: String
            func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                let template = Template(named: "Person", bundle: NSBundle(forClass: MustacheRenderableGuideTests.self))!
                let context = info.context.extendedContext(box: Box(self))
                return template.render(context, error: error)
            }
            func valueForMustacheKey(key: String) -> Box? {
                switch key {
                case "firstName":
                    return Box(firstName)
                case "lastName":
                    return Box(lastName)
                default:
                    return nil
                }
            }
        }
        
        struct Movie: MustacheRenderable, MustacheInspectable {
            let title: String
            let director: Person
            func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                let template = Template(named: "Movie", bundle: NSBundle(forClass: MustacheRenderableGuideTests.self))!
                let context = info.context.extendedContext(box: Box(self))
                return template.render(context, error: error)
            }
            func valueForMustacheKey(key: String) -> Box? {
                switch key {
                case "title":
                    return Box(title)
                case "director":
                    return Box(director)
                default:
                    return nil
                }
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
            let items: [Box] = box.value()!
            var buffer = "<ul>"
            for item in items {
                let itemContext = info.context.extendedContext(box: item)
                let itemRendering = info.tag.render(itemContext)!
                buffer += "<li>\(itemRendering.string)</li>"
            }
            buffer += "</ul>"
            return Rendering(buffer, .HTML)
        }
        
        let template = Template(string: "{{#list(nav)}}<a href=\"{{url}}\">{{title}}</a>{{/}}")!
        template.baseContext = template.baseContext.extendedContext(box: Box(["list": BoxedFilter(listFilter)]))
        
        let item1 = Box([
            "url": "http://mustache.github.io",
            "title": "Mustache"])
        let item2 = Box([
            "url": "http://github.com/groue/GRMustache.swift",
            "title": "GRMustache.swift"])
        let value = Box(["nav": Box([item1, item2])])
        
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "<ul><li><a href=\"http://mustache.github.io\">Mustache</a></li><li><a href=\"http://github.com/groue/GRMustache.swift\">GRMustache.swift</a></li></ul>")
    }
}
