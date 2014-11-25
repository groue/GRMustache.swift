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
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch renderingInfo.tag.type {
            case .Variable:
                return Rendering("I'm rendering a {{ variable }} tag.")
            case .Section:
                return Rendering("I'm rendering a {{# section }}...{{/ }} tag.")
            }
        }
        
        var rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{ variable }} tag.")
        
        rendering = Template(string: "{{#.}}{{/}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{# section }}...{{/ }} tag.")
    }
    
    func textExample2() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return Rendering("Arthur & Cie")
        }
        
        let rendering = Template(string: "{{.}}|{{{.}}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "Arthur &amp; Cie|Arthur & Cie")
    }
    
    func textExample3() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = renderingInfo.render()!
            return Rendering("<strong>\(rendering.string)</strong>", rendering.contentType)
        }
        
        let value = Value([
            "strong": Value(renderable),
            "name": Value("Arthur")])
        let rendering = Template(string: "{{#strong}}{{name}}{{/strong}}")!.render(value)!
        XCTAssertEqual(rendering, "<strong>Arthur</strong>")
    }
    
    func textExample4() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = renderingInfo.render()!
            return Rendering(rendering.string + rendering.string, rendering.contentType)
        }
        let value = Value(["twice": Value(renderable)])
        let rendering = Template(string: "{{#twice}}Success{{/twice}}")!.render(value)!
        XCTAssertEqual(rendering, "SuccessSuccess")
    }

    func textExample5() {
        let renderable = { (renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let template = Template(string: "<a href=\"{{url}}\">\(renderingInfo.tag.innerTemplateString)</a>")!
            return template.mustacheRender(renderingInfo, error: error)
        }
        // TODO: avoid this `as [String: Value]` cast
        let value = Value([
            "link": Value(renderable),
            "name": Value("Arthur"),
            "url": Value("/people/123")]
            as [String: Value])
        let rendering = Template(string: "{{# link }}{{ name }}{{/ link }}")!.render(value)!
        XCTAssertEqual(rendering, "<a href=\"/people/123\">Arthur</a>")
    }
    
    func testExample6() {
        let repository = TemplateRepository(templates: [
            "movieLink": "<a href=\"{{url}}\">{{title}}</a>",
            "personLink": "<a href=\"{{url}}\">{{name}}</a>"])
        // TODO: avoid those `as [String: Value]` casts
        let item1 = Value([
            "title": Value("Citizen Kane"),
            "url": Value("/movies/321"),
            "link": Value(repository.template(named: "movieLink")!)
            ] as [String: Value])
        let item2 = Value([
            "name": Value("Orson Welles"),
            "url": Value("/people/123"),
            "link": Value(repository.template(named: "personLink")!)
            ] as [String: Value])
        let value = Value(["items": Value([item1, item2])])
        let rendering = Template(string: "{{#items}}{{link}}{{/items}}")!.render(value)!
        XCTAssertEqual(rendering, "<a href=\"/movies/321\">Citizen Kane</a><a href=\"/people/123\">Orson Welles</a>")
    }
    
    func testExample7() {
        struct Person: MustacheRenderable, MustacheInspectable {
            let firstName: String
            let lastName: String
            func mustacheRender(renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                let template = Template(named: "Person", bundle: NSBundle(forClass: MustacheRenderableGuideTests.self))!
                let context = renderingInfo.context.contextByAddingValue(Value(self))
                return template.render(context, error: error)
            }
            func valueForMustacheKey(key: String) -> Value? {
                switch key {
                case "firstName":
                    return Value(firstName)
                case "lastName":
                    return Value(lastName)
                default:
                    return nil
                }
            }
        }
        
        struct Movie: MustacheRenderable, MustacheInspectable {
            let title: String
            let director: Person
            func mustacheRender(renderingInfo: RenderingInfo, error: NSErrorPointer) -> Rendering? {
                let template = Template(named: "Movie", bundle: NSBundle(forClass: MustacheRenderableGuideTests.self))!
                let context = renderingInfo.context.contextByAddingValue(Value(self))
                return template.render(context, error: error)
            }
            func valueForMustacheKey(key: String) -> Value? {
                switch key {
                case "title":
                    return Value(title)
                case "director":
                    return Value(director)
                default:
                    return nil
                }
            }
        }
        
        let director = Person(firstName: "Orson", lastName: "Welles")
        let movie = Movie(title:"Citizen Kane", director: director)
        
        let template = Template(string: "{{ movie }}")!
        let rendering = template.render(Value(["movie": Value(movie)]))!
        XCTAssertEqual(rendering, "Citizen Kane by Orson Welles")
    }
}
