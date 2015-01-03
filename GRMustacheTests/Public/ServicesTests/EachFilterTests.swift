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

    func testEachFilterTriggersRenderersInArray() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("<\(rendering.string)>", rendering.contentType)
        }
        let box = Box(["array": Box([Box(renderer)])])
        let template = Template(string: "{{#each(array)}}{{@index}}{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "<0>")
    }

    func testEachFilterTriggersRenderersInDictionary() {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            let rendering = info.tag.render(info.context)!
            return Rendering("<\(rendering.string)>", rendering.contentType)
        }
        let box = Box(["dictionary": Box(["a": Box(renderer)])])
        let template = Template(string: "{{#each(dictionary)}}{{@key}}{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "<a>")
    }
    
}
