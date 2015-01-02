//
//  VariadicFilterTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 16/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

//class VariadicFilterTests: XCTestCase {
//
//    func testVariadicFilterCanAccessArguments() {
//        let filter = BoxedVariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
//            return Box(",".join(args.map { $0.toString() ?? "" }))
//        })
//        let box = Box([
//            "a": "a",
//            "b": "b",
//            "c": "c",
//            "join": filter])
//        let template = Template(string:"{{join(a)}} {{join(a,b)}} {{join(a,b,c)}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "a a,b a,b,c")
//    }
//
//    func testVariadicFilterCanReturnFilter() {
//        let filter = BoxedVariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
//            let joined = ",".join(args.map { $0.toString() ?? "" })
//            return BoxedFilter({ (box: Box, error: NSErrorPointer) -> Box? in
//                return Box(joined + "+" + (box.toString() ?? ""))
//            })
//        })
//        let box = Box([
//            "a": "a",
//            "b": "b",
//            "c": "c",
//            "f": filter])
//        let template = Template(string:"{{f(a)(a)}} {{f(a,b)(a)}} {{f(a,b,c)(a)}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "a+a a,b+a a,b,c+a")
//    }
//    
//    func testVariadicFilterCanBeRootOfScopedExpression() {
//        let filter = BoxedVariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
//            return Box(["foo": "bar"])
//        })
//        let box = Box(["f": filter])
//        let template = Template(string:"{{f(a,b).foo}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "bar")
//    }
//    
//    func testVariadicFilterCanBeUsedForObjectSections() {
//        let filter = BoxedVariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
//            return Box(["foo": "bar"])
//        })
//        let box = Box(["f": filter])
//        let template = Template(string:"{{#f(a,b)}}{{foo}}{{/}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "bar")
//    }
//    
//    func testVariadicFilterCanBeUsedForEnumerableSections() {
//        let filter = BoxedVariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
//            return Box(args)
//        })
//        let box = Box([
//            "a": "a",
//            "b": "b",
//            "c": "c",
//            "f": filter])
//        let template = Template(string:"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "ab abc")
//    }
//    
//    func testVariadicFilterCanBeUsedForBooleanSections() {
//        let filter = BoxedVariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
//            return args.first
//        })
//        let box = Box([
//            "yes": true,
//            "no": false,
//            "f": filter])
//        let template = Template(string:"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "YES NO")
//    }
//    
//    func testVariadicFilterThatReturnNilCanBeUsedInBooleanSections() {
//        let filter = BoxedVariadicFilter({ (args: [Box], error: NSErrorPointer) -> Box? in
//            return nil
//        })
//        let box = Box(["f": filter])
//        let template = Template(string:"{{^f(x)}}nil{{/}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "nil")
//    }
//    
//    func testImplicitIteratorCanBeVariadicFilterArgument() {
//        let box = Box([
//            "f": BoxedVariadicFilter({ (arguments: [Box], error: NSErrorPointer) -> Box? in
//                var result = ""
//                for argument in arguments {
//                    if let dictionary: [String: Box] = argument.value() {
//                        result += String(countElements(dictionary))
//                    }
//                }
//                return Box(result)
//            }),
//            "foo": Box(["a": "a", "b": "b", "c": "c"])
//            ])
//        let template = Template(string:"{{f(foo,.)}} {{f(.,foo)}}")!
//        let rendering = template.render(value)!
//        XCTAssertEqual(rendering, "32 23")
//    }
//}
