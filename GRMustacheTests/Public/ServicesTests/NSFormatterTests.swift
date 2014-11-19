//
//  NSFormatterTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 19/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class NSFormatterTests: XCTestCase {
    
    func testFormatterIsAFilterForProcessableValues() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        // test that number is processable
        XCTAssertEqual(percentFormatter.stringFromNumber(0.5)!, "50%")

        // test filtering a number
        let template = Template(string: "{{ percent(number) }}")!
        let value = Value(["number": Value(0.5), "percent": Value(percentFormatter)])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "50%")
    }
    
    func testFormatterIsAFilterForUnprocessableValues() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        // test that number is processable
        XCTAssertNil(percentFormatter.stringForObjectValue("foo"))
        
        // test filtering a string
        let template = Template(string: "{{ percent(string) }}")!
        let value = Value(["string": Value("foo"), "percent": Value(percentFormatter)])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "")
    }
    
    func testFormatterSectionFormatsInnerVariableTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "{{# percent }}{{ number }} {{ number }}{{/ percent }}")!
        let value = Value(["number": Value(0.5), "percent": Value(percentFormatter)])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "50% 50%")
    }
    
    func testFormatterSectionDoesNotFormatUnprocessableInnerVariableTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "{{# percent }}{{ value }}{{/ percent }}")!
        let value = Value(["value": Value("foo"), "percent": Value(percentFormatter)])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "foo")
    }
    
    func testFormatterAsSectionFormatsDeepInnerVariableTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "{{# percent }}{{# number }}Number is {{ number }}.{{/ number }}{{/ percent }}")!
        let value = Value(["number": Value(0.5), "percent": Value(percentFormatter)])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "Number is 50%.")
    }
    
    func testFormatterAsSectionDoesNotFormatInnerSectionTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "NO is {{ NO }}. {{^ NO }}NO is false.{{/ NO }} percent(NO) is {{ percent(NO) }}. {{# percent(NO) }}percent(NO) is true.{{/ percent(NO) }} {{# percent }}{{^ NO }}NO is now {{ NO }} and is still false.{{/ NO }}{{/ percent }}")!
        let value = Value(["number": Value(0.5), "NO": Value(0), "percent": Value(percentFormatter)] as [String: Value])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "NO is 0. NO is false. percent(NO) is 0%. percent(NO) is true. NO is now 0% and is still false.")
    }
    
    func testFormatterIsTruthy() {
        let formatter = NSFormatter()
        let template = Template(string: "{{# formatter }}Formatter is true.{{/ formatter }}{{^ formatter }}Formatter is false.{{/ formatter }}")!
        let value = Value(["formatter": Value(formatter)])
        let rendering = template.render(value)!
        XCTAssertEqual(rendering, "Formatter is true.")
    }
    
    func testFormatterRendersSelfAsSomething() {
        let formatter = NSFormatter()
        let template = Template(string: "{{ formatter }}")!
        let value = Value(["formatter": Value(formatter)])
        let rendering = template.render(value)!
        XCTAssertTrue(countElements(rendering) > 0)
    }
    
    func testNumberFormatterRendersNothingForMissingValue() {
        // Check that NSNumberFormatter does not have surprising behavior, and
        // does not format nil.
        
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let value = Value(["format": Value(percentFormatter)])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(value)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSNull() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let value = Value(["format": Value(percentFormatter), "value": Value(NSNull())])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(value)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSString() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var value = Value(["format": Value(percentFormatter), "value": Value("1")])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(value)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "NO")
        
        value = Value(["format": Value(percentFormatter), "value": Value("YES")])
        
        template = Template(string: "<{{format(value)}}>")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "NO")
        
        value = Value(["format": Value(percentFormatter), "value": Value("foo")])
        
        template = Template(string: "<{{format(value)}}>")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(value)!
        XCTAssertEqual(rendering, "NO")
    }
}
