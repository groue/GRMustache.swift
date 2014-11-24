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
            "uppercase": Value({ (string: String?) -> Value in
                return Value(string?.uppercaseString)
            }),
            "prefix": Value({ (string: String?) -> Value in
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
            "f": Value({ (value: Value) -> Value in
                return value
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<objectName> <objectName>")
        
        value = Value([
            "object": Value(["name": "objectName"]),
            "name": Value("rootName"),
            "f": Value({ (_: Value) -> Value in
                return Value(["name": "filterName"])
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<filterName> <filterName>")
        
        value = Value([
            "object": Value(["name": "objectName"]),
            "name": Value("rootName"),
            "f": Value({ (_: Value) -> Value in
                return Value(true)
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<> <rootName>")
    }
    
    func testFilterArgumentsDoNotEnterSectionContextStack() {
        // TODO: avoid this `as [String: Value]` cast
        let value = Value([
            "test": Value("success"),
            "filtered": Value(["test": "failure"]),
            "filter": Value({ (_: Value) -> Value in
                return Value(true)
            })
            ] as [String: Value])
        let template = Template(string:"{{#filter(filtered)}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filter(filtered)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "<success instead of failure>")
    }
    
    func testFilterNameSpace() {
        let value = Value([
            "x": Value(1),
            "math": Value(["double": Value({ (x: Int?) -> Value in
                return Value((x ?? 0) * 2)
            })])
            ])
        let template = Template(string:"{{ math.double(x) }}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "2")
    }
    
    func testFilterCanReturnFilter() {
        // TODO: avoid this `as [String: Value]` cast
        let value = Value([
            "prefix": Value("prefix"),
            "value": Value("value"),
            "f": Value({ (string1: String?) -> Value in
                return Value({ (string2: String?) -> Value in
                    return Value("\(string1!)\(string2!)")
                })
            })
            ] as [String: Value])
        let template = Template(string:"{{f(prefix)(value)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "prefixvalue")
    }
    
    func testImplicitIteratorCanReturnFilter() {
        let value = Value({ (_: Value) -> Value in
            return Value("filter")
        })
        let template = Template(string:"{{.(a)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "filter")
    }
    
    func testMissingFilterError() {
        let value = Value([
            "name": Value("Name"),
            "replace": Value({ (_: Value) -> Value in
                return Value("replace")
            })
        ])
        
        var template = Template(string:"<{{missing(missing)}}>")!
        var error: NSError?
        var rendering = template.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        
        template = Template(string:"<{{missing(name)}}>")!
        rendering = template.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        
        template = Template(string:"<{{replace(missing(name))}}>")!
        rendering = template.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        
        template = Template(string:"<{{missing(replace(name))}}>")!
        rendering = template.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
    
    func testNotAFilterError() {
        let value = Value([
            "name": "Name",
            "filter": "filter"
            ])
        
        var template = Template(string:"<{{filter(name)}}>")!
        var error: NSError?
        var rendering = template.render(value, error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
    }
}
