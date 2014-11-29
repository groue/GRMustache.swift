//
//  EachFilterTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 29/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class EachFilterTests: XCTestCase {

    func testEachFilterTriggersRenderableItemsInArray() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering in
            let rendering = info.tag.render(info.context)!
            return Rendering("<\(rendering.string)>", rendering.contentType)
        }
        let value = Value(["array": Value([Value(renderable)])])
        let template = Template(string: "{{#each(array)}}{{@index}}{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "<0>")
    }

    func testEachFilterTriggersRenderableItemsInDictionary() {
        let renderable = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering in
            let rendering = info.tag.render(info.context)!
            return Rendering("<\(rendering.string)>", rendering.contentType)
        }
        let value = Value(["dictionary": Value(["a": Value(renderable)])])
        let template = Template(string: "{{#each(dictionary)}}{{@key}}{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "<a>")
    }
    
}
