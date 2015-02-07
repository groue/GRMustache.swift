//
//  VariadicFilterTests.swift
//
//  Created by Gwendal Roué on 16/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class VariadicFilterTests: XCTestCase {

    func testVariadicFilterCanAccessArguments() {
        let filter = VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
            return Box(",".join(boxes.map { $0.stringValue ?? "" }))
        })
        let box = Box([
            "a": Box("a"),
            "b": Box("b"),
            "c": Box("c"),
            "join": Box(filter)] as [String: MustacheBox]) // TODO: remove this unnecessary cast
        let template = Template(string:"{{join(a)}} {{join(a,b)}} {{join(a,b,c)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "a a,b a,b,c")
    }

    func testVariadicFilterCanReturnFilter() {
        let filter = VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
            let joined = ",".join(boxes.map { $0.stringValue ?? "" })
            return Box(Filter({ (box: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
                return Box(joined + "+" + (box.stringValue ?? ""))
            }))
        })
        let box = Box([
            "a": Box("a"),
            "b": Box("b"),
            "c": Box("c"),
            "f": Box(filter)] as [String: MustacheBox])    // TODO: remove this unnecessary cast
        let template = Template(string:"{{f(a)(a)}} {{f(a,b)(a)}} {{f(a,b,c)(a)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "a+a a,b+a a,b,c+a")
    }
    
    func testVariadicFilterCanBeRootOfScopedExpression() {
        let filter = VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
            return Box(["foo": "bar"])
        })
        let box = Box(["f": Box(filter)])
        let template = Template(string:"{{f(a,b).foo}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForObjectSections() {
        let filter = VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
            return Box(["foo": "bar"])
        })
        let box = Box(["f": Box(filter)])
        let template = Template(string:"{{#f(a,b)}}{{foo}}{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "bar")
    }
    
    func testVariadicFilterCanBeUsedForEnumerableSections() {
        let filter = VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
            return Box(boxes)
        })
        let box = Box([
            "a": Box("a"),
            "b": Box("b"),
            "c": Box("c"),
            "f": Box(filter)] as [String: MustacheBox])    // TODO: remove this unnecessary cast
        let template = Template(string:"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "ab abc")
    }
    
    func testVariadicFilterCanBeUsedForBooleanSections() {
        let filter = VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
            return boxes.first
        })
        let box = Box([
            "yes": Box(true),
            "no": Box(false),
            "f": Box(filter)])
        let template = Template(string:"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "YES NO")
    }
    
    func testVariadicFilterThatReturnNilCanBeUsedInBooleanSections() {
        let filter = VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
            return nil
        })
        let box = Box(["f": Box(filter)])
        let template = Template(string:"{{^f(x)}}nil{{/}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "nil")
    }
    
    func testImplicitIteratorCanBeVariadicFilterArgument() {
        let box = Box([
            "f": Box(VariadicFilter({ (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox? in
                var result = ""
                for box in boxes {
                    if let dictionary = box.dictionaryValue {
                        result += String(countElements(dictionary))
                    }
                }
                return Box(result)
            })),
            "foo": Box(["a": "a", "b": "b", "c": "c"])
            ])
        let template = Template(string:"{{f(foo,.)}} {{f(.,foo)}}")!
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "32 23")
    }
}
