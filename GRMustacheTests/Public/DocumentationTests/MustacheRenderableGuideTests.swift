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
        let renderable = { (renderingInfo: RenderingInfo) -> Rendering in
            switch renderingInfo.tag.type {
            case .Variable:
                return .Success("I'm rendering a {{ variable }} tag.", .Text)
            case .Section:
                return .Success("I'm rendering a {{# section }}...{{/ }} tag.", .Text)
            }
        }
        
        var rendering = Template(string: "{{.}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{ variable }} tag.")
        
        rendering = Template(string: "{{#.}}{{/}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "I&apos;m rendering a {{# section }}...{{/ }} tag.")
    }
    
    func textExample2() {
        let renderable = { (renderingInfo: RenderingInfo) -> Rendering in
            return .Success("Arthur & Cie", .Text)
        }
        
        let rendering = Template(string: "{{.}}|{{{.}}}")!.render(Value(renderable))!
        XCTAssertEqual(rendering, "Arthur &amp; Cie|Arthur & Cie")
    }
    
    func textExample3() {
        let renderable = { (renderingInfo: RenderingInfo) -> Rendering in
            let rendering = renderingInfo.render()
            switch rendering {
            case .Error:
                return rendering
            case .Success(let string, let contentType):
                return .Success("<strong>\(string)</strong>", contentType)
            }
        }
        
        let value = Value([
            "strong": Value(renderable),
            "name": Value("Arthur")])
        let rendering = Template(string: "{{#strong}}{{name}}{{/strong}}")!.render(value)!
        XCTAssertEqual(rendering, "<strong>Arthur</strong>")
    }
    
    func textExample4() {
        let renderable = { (renderingInfo: RenderingInfo) -> Rendering in
            let rendering = renderingInfo.render()
            switch rendering {
            case .Error:
                return rendering
            case .Success(let string, let contentType):
                return .Success(string + string, contentType)
            }
        }
        let value = Value(["twice": Value(renderable)])
        let rendering = Template(string: "{{#twice}}Success{{/twice}}")!.render(value)!
        XCTAssertEqual(rendering, "SuccessSuccess")
    }

    func textExample5() {
        let renderable = { (renderingInfo: RenderingInfo) -> Rendering in
            let template = Template(string: "<a href=\"{{url}}\">\(renderingInfo.tag.innerTemplateString)</a>")!
            return template.mustacheRender(renderingInfo)
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
        // TODO: avoid those `as [String: Value]` and `as [Value]` casts
        let value = Value([
            "items": Value([
                Value([
                    "title": Value("Citizen Kane"),
                    "url": Value("/movies/321"),
                    "link": Value(repository.template(named: "movieLink")!)
                    ] as [String: Value]),
                Value([
                    "name": Value("Orson Welles"),
                    "url": Value("/people/123"),
                    "link": Value(repository.template(named: "personLink")!)
                    ] as [String: Value]),
                ] as [Value])
            ] as [String: Value])
        let rendering = Template(string: "{{#items}}{{link}}{{/items}}")!.render(value)!
        XCTAssertEqual(rendering, "<a href=\"/movies/321\">Citizen Kane</a><a href=\"/people/123\">Orson Welles</a>")
    }
}
