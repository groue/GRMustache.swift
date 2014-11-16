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
        let filter = Value({ (args: [Value]) -> (Value) in
            return Value(",".join(args.map { $0.toString() ?? "" }))
        })
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
        let filter = Value({ (args: [Value]) -> (Value) in
            let joined = ",".join(args.map { $0.toString() ?? "" })
            return Value({ (value: Value) -> (Value) in
                return Value(joined + "+" + (value.toString() ?? ""))
            })
        })
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
        let filter = Value({ (args: [Value]) -> (Value) in
            return Value(["foo": "bar"])
        })
        let value = Value(["f": filter])
        let template = Template(string:"{{f(a,b).foo}}")!
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "bar")
    }
    
//    - (void)testVariadicFiltersCanBeRootOfScopedExpression
//    {
//    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
//    return @{@"foo": @"bar"};
//    }];
//    
//    id data = @{ @"f": filter };
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{f(a,b).foo}}" error:NULL] renderObject:data error:NULL];
//    XCTAssertEqualObjects(rendering, @"bar", @"");
//    }
//    
//    - (void)testVariadicFiltersCanBeUsedForObjectSections
//    {
//    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
//    return @{@"foo": @"bar"};
//    }];
//    
//    id data = @{ @"f": filter };
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(a,b)}}{{foo}}{{/}}" error:NULL] renderObject:data error:NULL];
//    XCTAssertEqualObjects(rendering, @"bar", @"");
//    }
//    
//    - (void)testVariadicFiltersCanBeUsedForEnumerableSections
//    {
//    GRMustacheFilter *filter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
//    return arguments;
//    }];
//    
//    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c", @"f": filter };
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}" error:NULL] renderObject:data error:NULL];
//    XCTAssertEqualObjects(rendering, @"ab abc", @"");
//    }
//    
//    - (void)testVariadicFiltersCanBeUsedForBooleanSections
//    {
//    GRMustacheFilter *identityFilter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
//    return [arguments objectAtIndex:0];
//    }];
//    
//    id data = @{ @"yes": @YES, @"no": @NO, @"f": identityFilter };
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}" error:NULL] renderObject:data error:NULL];
//    XCTAssertEqualObjects(rendering, @"YES NO", @"");
//    }
//    
//    - (void)testVariadicFiltersThatReturnNilCanBeUsedInBooleanSections
//    {
//    GRMustacheFilter *nilFilter = [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
//    return nil;
//    }];
//    
//    id data = @{ @"f": nilFilter };
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{^f(x)}}nil{{/}}" error:NULL] renderObject:data error:NULL];
//    XCTAssertEqualObjects(rendering, @"nil", @"");
//    }

}
