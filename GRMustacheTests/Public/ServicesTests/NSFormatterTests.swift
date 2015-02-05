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
        let box = boxValue(["number": boxValue(0.5), "percent": boxValue(percentFormatter)])
        let rendering = template.render(box)!
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
        let box = boxValue(["string": boxValue("foo"), "percent": boxValue(percentFormatter)])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "")
    }
    
    func testFormatterSectionFormatsInnerVariableTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "{{# percent }}{{ number }} {{ number }}{{/ percent }}")!
        let box = boxValue(["number": boxValue(0.5), "percent": boxValue(percentFormatter)])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "50% 50%")
    }
    
    func testFormatterSectionDoesNotFormatUnprocessableInnerVariableTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "{{# percent }}{{ value }}{{/ percent }}")!
        let box = boxValue(["value": boxValue("foo"), "percent": boxValue(percentFormatter)])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "foo")
    }
    
    func testFormatterAsSectionFormatsDeepInnerVariableTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "{{# percent }}{{# number }}Number is {{ number }}.{{/ number }}{{/ percent }}")!
        let box = boxValue(["number": boxValue(0.5), "percent": boxValue(percentFormatter)])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "Number is 50%.")
    }
    
    func testFormatterAsSectionDoesNotFormatInnerSectionTags() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let template = Template(string: "NO is {{ NO }}. {{^ NO }}NO is false.{{/ NO }} percent(NO) is {{ percent(NO) }}. {{# percent(NO) }}percent(NO) is true.{{/ percent(NO) }} {{# percent }}{{^ NO }}NO is now {{ NO }} and is still false.{{/ NO }}{{/ percent }}")!
        let box = boxValue(["number": boxValue(0.5), "NO": boxValue(0), "percent": boxValue(percentFormatter)])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO is 0. NO is false. percent(NO) is 0%. percent(NO) is true. NO is now 0% and is still false.")
    }
    
    func testFormatterIsTruthy() {
        let formatter = NSFormatter()
        let template = Template(string: "{{# formatter }}Formatter is true.{{/ formatter }}{{^ formatter }}Formatter is false.{{/ formatter }}")!
        let box = boxValue(["formatter": boxValue(formatter)])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "Formatter is true.")
    }
    
    func testFormatterRendersSelfAsSomething() {
        let formatter = NSFormatter()
        let template = Template(string: "{{ formatter }}")!
        let box = boxValue(["formatter": boxValue(formatter)])
        let rendering = template.render(box)!
        XCTAssertTrue(countElements(rendering) > 0)
    }
    
    func testNumberFormatterRendersNothingForMissingValue() {
        // Check that NSNumberFormatter does not have surprising behavior, and
        // does not format nil.
        
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let box = boxValue(["format": boxValue(percentFormatter)])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSNull() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let box = boxValue(["format": boxValue(percentFormatter), "value": boxValue(NSNull())])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSString() {
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var box = boxValue(["format": boxValue(percentFormatter), "value": boxValue("1")])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
        
        box = boxValue(["format": boxValue(percentFormatter), "value": boxValue("YES")])
        
        template = Template(string: "<{{format(value)}}>")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
        
        box = boxValue(["format": boxValue(percentFormatter), "value": boxValue("foo")])
        
        template = Template(string: "<{{format(value)}}>")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testNumberFormatterRendersNothingForNSDate() {
        // Check that NSNumberFormatter does not have surprising behavior, and
        // does not format NSDate.
        
        let percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let box = boxValue(["format": boxValue(percentFormatter), "value": boxValue(NSDate())])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForMissingValue() {
        // Check that NSDateFormatter does not have surprising behavior, and
        // does not format nil.
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        
        let box = boxValue(["format": boxValue(dateFormatter)])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForNSNull() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        
        let box = boxValue(["format": boxValue(dateFormatter), "value": boxValue(NSNull())])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForNSString() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        
        var box = boxValue(["format": boxValue(dateFormatter), "value": boxValue("1")])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
        
        box = boxValue(["format": boxValue(dateFormatter), "value": boxValue("YES")])
        
        template = Template(string: "<{{format(value)}}>")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
        
        box = boxValue(["format": boxValue(dateFormatter), "value": boxValue("foo")])
        
        template = Template(string: "<{{format(value)}}>")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
    
    func testDateFormatterRendersNothingForNSNumber() {
        // Check that NSDateFormatter does not have surprising behavior, and
        // does not format NSNumber.
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        
        let box = boxValue(["format": boxValue(dateFormatter), "value": boxValue(0)])
        
        var template = Template(string: "<{{format(value)}}>")!
        var rendering = template.render(box)!
        XCTAssertEqual(rendering, "<>")
        
        template = Template(string: "{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}")!
        rendering = template.render(box)!
        XCTAssertEqual(rendering, "NO")
    }
}
