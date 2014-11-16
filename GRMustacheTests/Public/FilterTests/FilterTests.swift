//
//  FilterTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 16/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class FilterTests: XCTestCase {
    
    func testFilterCanChain() {
        let value = Value([
            "name": Value("Name"),
            "uppercase": Value({ (string: String?) -> (Value) in
                return Value(string?.uppercaseString)
            }),
            "prefix": Value({ (string: String?) -> (Value) in
                return Value("prefix\(string!)")
            })
            ])
        let template = Template(string:"<{{name}}> <{{prefix(name)}}> <{{uppercase(name)}}> <{{prefix(uppercase(name))}}> <{{uppercase(prefix(name))}}>")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "<Name> <prefixName> <NAME> <prefixNAME> <PREFIXNAME>")
    }
    
    func testScopedValueAreExtractedOutOfAFilterExpression() {
        let template = Template(string:"<{{f(object).name}}> {{#f(object)}}<{{name}}>{{/f(object)}}")!
        var value: Value
        var rendering: String
        
        value = Value([
            "object": Value(["name": "objectName"]),
            "name": Value("rootName"),
            "f": Value({ (value: Value) -> (Value) in
                return value
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<objectName> <objectName>")
        
        value = Value([
            "object": Value(["name": "objectName"]),
            "name": Value("rootName"),
            "f": Value({ (_: Value) -> (Value) in
                return Value(["name": "filterName"])
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<filterName> <filterName>")
        
        value = Value([
            "object": Value(["name": "objectName"]),
            "name": Value("rootName"),
            "f": Value({ (_: Value) -> (Value) in
                return Value(true)
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<> <rootName>")
    }
}
