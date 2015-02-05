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
        let filter = VariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
            return boxValue(",".join(args.map { $0.stringValue ?? "" }))
        })
        let box = boxValue([
            "a": boxValue("a"),
            "b": boxValue("b"),
            "c": boxValue("c"),
            "join": boxValue(filter)] as [String: Box]) // TODO: remove this unnecessary cast
        let template = Template(string:"{{join(a)}} {{join(a,b)}} {{join(a,b,c)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "a a,b a,b,c")
    }

    func testVariadicFilterCanReturnFilter() {
        let filter = VariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
            let joined = ",".join(args.map { $0.stringValue ?? "" })
            return boxValue(Filter({ (box: Box, error: NSErrorPointer) -> Box? in
                return boxValue(joined + "+" + (box.stringValue ?? ""))
            }))
        })
        let box = boxValue([
            "a": boxValue("a"),
            "b": boxValue("b"),
            "c": boxValue("c"),
            "f": boxValue(filter)] as [String: Box])    // TODO: remove this unnecessary cast
        let template = Template(string:"{{f(a)(a)}} {{f(a,b)(a)}} {{f(a,b,c)(a)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "a+a a,b+a a,b,c+a")
    }
    
    func testVariadicFilterCanBeRootOfScopedExpression() {
        let filter = VariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
            return boxValue(["foo": "bar"])
        })
        let box = boxValue(["f": boxValue(filter)])
        let template = Template(string:"{{f(a,b).foo}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForObjectSections() {
        let filter = VariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
            return boxValue(["foo": "bar"])
        })
        let box = boxValue(["f": boxValue(filter)])
        let template = Template(string:"{{#f(a,b)}}{{foo}}{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForEnumerableSections() {
        let filter = VariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
            return boxValue(args)
        })
        let box = boxValue([
            "a": boxValue("a"),
            "b": boxValue("b"),
            "c": boxValue("c"),
            "f": boxValue(filter)] as [String: Box])    // TODO: remove this unnecessary cast
        let template = Template(string:"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "ab abc")
    }
    
    func testVariadicFilterCanBeUsedForBooleanSections() {
        let filter = VariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
            return args.first
        })
        let box = boxValue([
            "yes": boxValue(true),
            "no": boxValue(false),
            "f": boxValue(filter)])
        let template = Template(string:"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "YES NO")
    }
    
    func testVariadicFilterThatReturnNilCanBeUsedInBooleanSections() {
        let filter = VariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
            return nil
        })
        let box = boxValue(["f": boxValue(filter)])
        let template = Template(string:"{{^f(x)}}nil{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "nil")
    }
    
    func testImplicitIteratorCanBeVariadicFilterArgument() {
        let box = boxValue([
            "f": boxValue(VariadicFilter({ (arguments: [Box], error: NSErrorPointer) -> Box? in
                var result = ""
                for argument in arguments {
                    if let dictionary = argument.value as? [String: Box] {
                        result += String(countElements(dictionary))
                    }
                }
                return boxValue(result)
            })),
            "foo": boxValue(["a": "a", "b": "b", "c": "c"])
            ])
        let template = Template(string:"{{f(foo,.)}} {{f(.,foo)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "32 23")
    }
}
