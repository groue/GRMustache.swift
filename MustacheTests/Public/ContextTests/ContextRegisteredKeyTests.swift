//
//  ContextRegisteredKeyTests.swift
//
//  Created by Gwendal Roué on 17/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class ContextRegisteredKeyTests: XCTestCase {
    
    func testRegisteredKeyCanBeAccessed() {
        let template = Template(string: "{{safe}}")!
        template.registerInBaseContext("safe", Box("important"))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "important")
    }
    
    func testMultipleRegisteredKeysCanBeAccessed() {
        let template = Template(string: "{{safe1}}, {{safe2}}")!
        template.registerInBaseContext("safe1", Box("important1"))
        template.registerInBaseContext("safe2", Box("important2"))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "important1, important2")
    }
    
    func testRegisteredKeysCanNotBeShadowed() {
        let template = Template(string: "{{safe}}, {{fragile}}")!
        template.registerInBaseContext("safe", Box("important"))
        let rendering = template.render(Box(["safe": "error", "fragile": "not important"]))!
        XCTAssertEqual(rendering, "important, not important")
    }
    
    func testDeepRegisteredKeyCanBeAccessedViaFullKeyPath() {
        let template = Template(string: "{{safe.name}}")!
        template.registerInBaseContext("safe", Box(["name": "important"]))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "important")
    }
    
    func testDeepRegisteredKeyCanBeAccessedViaScopedExpression() {
        let template = Template(string: "{{#safe}}{{.name}}{{/safe}}")!
        template.registerInBaseContext("safe", Box(["name": "important"]))
        let rendering = template.render()!
        XCTAssertEqual(rendering, "important")
    }
    
    func testDeepRegisteredKeyCanBeShadowed() {
        // This is more a caveat than a feature, isn't it?
        let template = Template(string: "{{#safe}}{{#evil}}{{name}}{{/evil}}{{/safe}}")!
        template.registerInBaseContext("safe", Box(["name": "important"]))
        let rendering = template.render(Box(["evil": ["name": "hacked"]]))!
        XCTAssertEqual(rendering, "hacked")
    }
}
