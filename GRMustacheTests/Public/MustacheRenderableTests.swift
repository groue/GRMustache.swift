//
//  MustacheRenderableTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 02/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest

class MustacheRenderableTests: XCTestCase {

    func testRenderablePerformsVariableRendering() {
        let renderable = MustacheRenderableWithBlock { (tag, context, options, error) -> (MustacheRendering?) in
            return MustacheRendering(string: "---", contentType: .Text)
        }
        let value = MustacheValue(["object": MustacheValue(renderable)])
        let rendering = MustacheTemplate.render(value, fromString: "{{object}}", error: nil)!.string
        XCTAssertEqual(rendering, "---")
    }
    
    func testRenderablePerformsSectionRendering() {
        let renderable = MustacheRenderableWithBlock { (tag, context, options, error) -> (MustacheRendering?) in
            return MustacheRendering(string: "---", contentType: .Text)
        }
        let value = MustacheValue(["object": MustacheValue(renderable)])
        let rendering = MustacheTemplate.render(value, fromString: "{{#object}}{{/object}}", error: nil)!.string
        XCTAssertEqual(rendering, "---")
    }
}
