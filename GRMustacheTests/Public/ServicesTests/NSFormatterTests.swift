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
}
