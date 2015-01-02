//
//  FilterTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 16/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

//class FilterTests: XCTestCase {
//    
//    func testFilterCanChain() {
//        let box = Box([
//            "name": Box("Name"),
//            "uppercase": BoxedFilter({ (string: String?, error: NSErrorPointer) -> Box? in
//                return Box(string?.uppercaseString)
//            }),
//            "prefix": BoxedFilter({ (string: String?, error: NSErrorPointer) -> Box? in
//                return Box("prefix\(string!)")
//            })
//            ])
//        let template = Template(string:"<{{name}}> <{{prefix(name)}}> <{{uppercase(name)}}> <{{prefix(uppercase(name))}}> <{{uppercase(prefix(name))}}>")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "<Name> <prefixName> <NAME> <prefixNAME> <PREFIXNAME>")
//    }
//    
//    func testScopedValueAreExtractedOutOfAFilterExpression() {
//        let template = Template(string:"<{{f(object).name}}> {{#f(object)}}<{{name}}>{{/f(object)}}")!
//        var box: Box
//        var rendering: String
//        
//        box = Box([
//            "object": Box(["name": "objectName"]),
//            "name": Box("rootName"),
//            "f": BoxedFilter({ (box: Box, error: NSErrorPointer) -> Box? in
//                return box
//            })
//            ])
//        rendering = template.render(box)!
//        XCTAssertEqual(rendering, "<objectName> <objectName>")
//        
//        box = Box([
//            "object": Box(["name": "objectName"]),
//            "name": Box("rootName"),
//            "f": BoxedFilter({ (_: Box, error: NSErrorPointer) -> Box? in
//                return Box(["name": "filterName"])
//            })
//            ])
//        rendering = template.render(box)!
//        XCTAssertEqual(rendering, "<filterName> <filterName>")
//        
//        box = Box([
//            "object": Box(["name": "objectName"]),
//            "name": Box("rootName"),
//            "f": BoxedFilter({ (_: Box, error: NSErrorPointer) -> Box? in
//                return Box(true)
//            })
//            ])
//        rendering = template.render(box)!
//        XCTAssertEqual(rendering, "<> <rootName>")
//    }
//    
//    func testFilterArgumentsDoNotEnterSectionContextStack() {
//        let box = Box([
//            "test": Box("success"),
//            "filtered": Box(["test": "failure"]),
//            "filter": BoxedFilter({ (_: Box, _: NSErrorPointer) -> Box? in
//                return Box(true)
//            })])
//        let template = Template(string:"{{#filter(filtered)}}<{{test}} instead of {{#filtered}}{{test}}{{/filtered}}>{{/filter(filtered)}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "<success instead of failure>")
//    }
//    
//    func testFilterNameSpace() {
//        let doubleFilter = BoxedFilter({ (x: Int?, error: NSErrorPointer) -> Box? in
//            return Box((x ?? 0) * 2)
//        })
//        let box = Box([
//            "x": Box(1),
//            "math": Box(["double": doubleFilter])
//            ])
//        let template = Template(string:"{{ math.double(x) }}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "2")
//    }
//    
//    func testFilterCanReturnFilter() {
//        let filterValue = BoxedFilter({ (string1: String?, error: NSErrorPointer) -> Box? in
//            return BoxedFilter({ (string2: String?, error: NSErrorPointer) -> Box? in
//                    return Box("\(string1!)\(string2!)")
//                })
//            })
//        let box = Box([
//            "prefix": Box("prefix"),
//            "value": Box("value"),
//            "f": filterValue])
//        let template = Template(string:"{{f(prefix)(value)}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "prefixvalue")
//    }
//    
//    func testImplicitIteratorCanReturnFilter() {
//        let box = BoxedFilter({ (_: Box, error: NSErrorPointer) -> Box? in
//            return Box("filter")
//        })
//        let template = Template(string:"{{.(a)}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "filter")
//    }
//    
//    func testMissingFilterError() {
//        let box = Box([
//            "name": Box("Name"),
//            "replace": BoxedFilter({ (_: Box, error: NSErrorPointer) -> Box? in
//                return Box("replace")
//            })
//        ])
//        
//        var template = Template(string:"<{{missing(missing)}}>")!
//        var error: NSError?
//        var rendering = template.render(value, error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
//        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
//        
//        template = Template(string:"<{{missing(name)}}>")!
//        rendering = template.render(value, error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
//        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
//        
//        template = Template(string:"<{{replace(missing(name))}}>")!
//        rendering = template.render(value, error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
//        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
//        
//        template = Template(string:"<{{missing(replace(name))}}>")!
//        rendering = template.render(value, error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
//        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
//    }
//    
//    func testNotAFilterError() {
//        let box = Box([
//            "name": "Name",
//            "filter": "filter"
//            ])
//        
//        var template = Template(string:"<{{filter(name)}}>")!
//        var error: NSError?
//        var rendering = template.render(value, error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
//        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
//    }
//    
//    // TODO: port this test to Objective-C GRMustache
//    func testMissingFilterErrorDescriptionContainsLineNumber() {
//        let template = Template(string: "\n{{f(x)}}")!
//        var error: NSError?
//        let rendering = template.render(error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
//        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
//        XCTAssertTrue(error!.localizedDescription.rangeOfString("Missing filter") != nil)
//        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
//    }
//    
//    // TODO: port this test to Objective-C GRMustache
//    func testMissingFilterErrorDescriptionContainsTemplatePath() {
//        // TODO
//    }
//    
//    // TODO: port this test to Objective-C GRMustache
//    func testNotAFilterErrorDescriptionContainsLineNumber() {
//        let template = Template(string: "\n{{f(x)}}")!
//        var error: NSError?
//        let rendering = template.render(Box(["f": "foo"]), error: &error)
//        XCTAssertNil(rendering)
//        XCTAssertEqual(error!.domain, GRMustacheErrorDomain)
//        XCTAssertEqual(error!.code, GRMustacheErrorCodeRenderingError)
//        XCTAssertTrue(error!.localizedDescription.rangeOfString("Not a filter") != nil)
//        XCTAssertTrue(error!.localizedDescription.rangeOfString("line 2") != nil)
//    }
//    
//    // TODO: port this test to Objective-C GRMustache
//    func testNotAFilterErrorDescriptionContainsTemplatePath() {
//        // TODO
//    }
//}
