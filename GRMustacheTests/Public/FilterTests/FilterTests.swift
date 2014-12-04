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
            "uppercase": FilterValue({ (string: String?, error: NSErrorPointer) -> Value? in
                return Value(string?.uppercaseString)
            }),
            "prefix": FilterValue({ (string: String?, error: NSErrorPointer) -> Value? in
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
            "f": FilterValue({ (value: Value, error: NSErrorPointer) -> Value? in
                return value
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<objectName> <objectName>")
        
        value = Value([
            "object": Value(["name": "objectName"]),
            "name": Value("rootName"),
            "f": FilterValue({ (_: Value, error: NSErrorPointer) -> Value? in
                return Value(["name": "filterName"])
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<filterName> <filterName>")
        
        value = Value([
            "object": Value(["name": "objectName"]),
            "name": Value("rootName"),
            "f": FilterValue({ (_: Value, error: NSErrorPointer) -> Value? in
                return Value(true)
            })
            ])
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<> <rootName>")
    }
    
    func testFilterArgumentsDoNotEnterSectionContextStack() {
        let value = Value([
            "test": Value("success"),
            "filtered": Value(["test": "failure"]),
            "filter": FilterValue({ (_: Value, _: NSErrorPointer) -> Value? in
                return Value(true)
            })])
        let template = Template(string:"{{#filter(filtered)}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filter(filtered)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "<success instead of failure>")
    }
    
    func testFilterNameSpace() {
        let doubleFilter = FilterValue({ (x: Int?, error: NSErrorPointer) -> Value? in
            return Value((x ?? 0) * 2)
        })
        let value = Value([
            "x": Value(1),
            "math": Value(["double": doubleFilter])
            ])
        let template = Template(string:"{{ math.double(x) }}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "2")
    }
    
    func testFilterCanReturnFilter() {
        let filterValue = FilterValue({ (string1: String?, error: NSErrorPointer) -> Value? in
            return FilterValue({ (string2: String?, error: NSErrorPointer) -> Value? in
                    return Value("\(string1!)\(string2!)")
                })
            })
        let value = Value([
            "prefix": Value("prefix"),
            "value": Value("value"),
            "f": filterValue])
        let template = Template(string:"{{f(prefix)(value)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "prefixvalue")
    }
    
    func testImplicitIteratorCanReturnFilter() {
        let value = FilterValue({ (_: Value, error: NSErrorPointer) -> Value? in
            return Value("filter")
        })
        let template = Template(string:"{{.(a)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "filter")
    }
    
    func testMissingFilterError() {
        let value = Value([
            "name": Value("Name"),
            "replace": FilterValue({ (_: Value, error: NSErrorPointer) -> Value? in
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
    
    // TODO: port this test to Objective-C GRMustache
    func testMissingFilterErrorDescriptionContainsLineNumber() {
        let template = Template(string: "\n{{f(x)}}")!
        var error: NSError?
        let rendering = template.render(error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("Missing filter") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testMissingFilterErrorDescriptionContainsTemplatePath() {
        // TODO
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testNotAFilterErrorDescriptionContainsLineNumber() {
        let template = Template(string: "\n{{f(x)}}")!
        var error: NSError?
        let rendering = template.render(Value(["f": "foo"]), error: &error)
        XCTAssertNil(rendering)
        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("Not a filter") != nil)
        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
    }
    
    // TODO: port this test to Objective-C GRMustache
    func testNotAFilterErrorDescriptionContainsTemplatePath() {
        // TODO
    }
}
