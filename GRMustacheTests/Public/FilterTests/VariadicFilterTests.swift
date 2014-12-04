//
//  VariadicFilterTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 16/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class VariadicFilterTests: XCTestCase {

    func testVariadicFilterCanAccessArguments() {
        let filter = VariadicFilterValue({ (args: [Value], error: NSErrorPointer) -> Value? in
            return Value(",".join(args.map { $0.toString() ?? "" }))
        })
        let value = Value([
            "a": "a",
            "b": "b",
            "c": "c",
            "join": filter])
        let template = Template(string:"{{join(a)}} {{join(a,b)}} {{join(a,b,c)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "a a,b a,b,c")
    }

    func testVariadicFilterCanReturnFilter() {
        let filter = VariadicFilterValue({ (args: [Value], error: NSErrorPointer) -> Value? in
            let joined = ",".join(args.map { $0.toString() ?? "" })
            return FilterValue({ (value: Value, error: NSErrorPointer) -> Value? in
                return Value(joined + "+" + (value.toString() ?? ""))
            })
        })
        let value = Value([
            "a": "a",
            "b": "b",
            "c": "c",
            "f": filter])
        let template = Template(string:"{{f(a)(a)}} {{f(a,b)(a)}} {{f(a,b,c)(a)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "a+a a,b+a a,b,c+a")
    }
    
    func testVariadicFilterCanBeRootOfScopedExpression() {
        let filter = VariadicFilterValue({ (args: [Value], error: NSErrorPointer) -> Value? in
            return Value(["foo": "bar"])
        })
        let value = Value(["f": filter])
        let template = Template(string:"{{f(a,b).foo}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForObjectSections() {
        let filter = VariadicFilterValue({ (args: [Value], error: NSErrorPointer) -> Value? in
            return Value(["foo": "bar"])
        })
        let value = Value(["f": filter])
        let template = Template(string:"{{#f(a,b)}}{{foo}}{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForEnumerableSections() {
        let filter = VariadicFilterValue({ (args: [Value], error: NSErrorPointer) -> Value? in
            return Value(args)
        })
        let value = Value([
            "a": "a",
            "b": "b",
            "c": "c",
            "f": filter])
        let template = Template(string:"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "ab abc")
    }
    
    func testVariadicFilterCanBeUsedForBooleanSections() {
        let filter = VariadicFilterValue({ (args: [Value], error: NSErrorPointer) -> Value? in
            return args.first
        })
        let value = Value([
            "yes": true,
            "no": false,
            "f": filter])
        let template = Template(string:"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "YES NO")
    }
    
    func testVariadicFilterThatReturnNilCanBeUsedInBooleanSections() {
        let filter = VariadicFilterValue({ (args: [Value], error: NSErrorPointer) -> Value? in
            return nil
        })
        let value = Value(["f": filter])
        let template = Template(string:"{{^f(x)}}nil{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "nil")
    }
    
    func testImplicitIteratorCanBeVariadicFilterArgument() {
        let value = Value([
            "f": VariadicFilterValue({ (arguments: [Value], error: NSErrorPointer) -> Value? in
                var result = ""
                for argument in arguments {
                    if let dictionary: [String: Value] = argument.object() {
                        result += String(countElements(dictionary))
                    }
                }
                return Value(result)
            }),
            "foo": Value(["a": "a", "b": "b", "c": "c"])
            ])
        let template = Template(string:"{{f(foo,.)}} {{f(.,foo)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "32 23")
    }
}
