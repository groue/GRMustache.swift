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
        let filter = Value({ (args: [Value]) -> Value in
            return Value(",".join(args.map { $0.toString() ?? "" }))
        })
        // TODO: avoid this `as [String: Value]` cast
        let value = Value([
            "a": Value("a"),
            "b": Value("b"),
            "c": Value("c"),
            "join": filter
            ] as [String:Value])
        let template = Template(string:"{{join(a)}} {{join(a,b)}} {{join(a,b,c)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "a a,b a,b,c")
    }

    func testVariadicFilterCanReturnFilter() {
        let filter = Value({ (args: [Value]) -> Value in
            let joined = ",".join(args.map { $0.toString() ?? "" })
            return Value({ (value: Value) -> Value in
                return Value(joined + "+" + (value.toString() ?? ""))
            })
        })
        // TODO: avoid this `as [String: Value]` cast
        let value = Value([
            "a": Value("a"),
            "b": Value("b"),
            "c": Value("c"),
            "f": filter
            ] as [String:Value])
        let template = Template(string:"{{f(a)(a)}} {{f(a,b)(a)}} {{f(a,b,c)(a)}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "a+a a,b+a a,b,c+a")
    }
    
    func testVariadicFilterCanBeRootOfScopedExpression() {
        let filter = Value({ (args: [Value]) -> Value in
            return Value(["foo": "bar"])
        })
        let value = Value(["f": filter])
        let template = Template(string:"{{f(a,b).foo}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForObjectSections() {
        let filter = Value({ (args: [Value]) -> Value in
            return Value(["foo": "bar"])
        })
        let value = Value(["f": filter])
        let template = Template(string:"{{#f(a,b)}}{{foo}}{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForEnumerableSections() {
        let filter = Value({ (args: [Value]) -> Value in
            return Value(args)
        })
        // TODO: avoid this `as [String: Value]` cast
        let value = Value([
            "a": Value("a"),
            "b": Value("b"),
            "c": Value("c"),
            "f": filter
            ] as [String:Value])
        let template = Template(string:"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "ab abc")
    }
    
    func testVariadicFilterCanBeUsedForBooleanSections() {
        let filter = Value({ (args: [Value]) -> Value? in
            return args.first
        })
        // TODO: avoid this `as [String: Value]` cast
        let value = Value([
            "yes": Value(true),
            "no": Value(false),
            "f": filter
            ] as [String:Value])
        let template = Template(string:"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "YES NO")
    }
    
    func testVariadicFilterThatReturnNilCanBeUsedInBooleanSections() {
        let filter = Value({ (args: [Value]) -> Value? in
            return nil
        })
        let value = Value(["f": filter])
        let template = Template(string:"{{^f(x)}}nil{{/}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "nil")
    }
    
    func testImplicitIteratorCanBeVariadicFilterArgument() {
        let value = Value([
            "f": Value({ (arguments: [Value]) -> Value in
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
