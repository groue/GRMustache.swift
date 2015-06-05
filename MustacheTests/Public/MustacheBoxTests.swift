// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import XCTest
import Mustache

class MustacheBoxTests: XCTestCase {
    
    // This test should go elsewhere, or should have many brothers: tests for
    // each way to feed the Box(boolValue:value:etc.) function.
    func testBoolValue() {
        let template = Template(string:"{{#.}}true{{/.}}{{^.}}false{{/.}}")!
        XCTAssertEqual(template.render(Box(boolValue: true))!, "true")
        XCTAssertEqual(template.render(Box(boolValue: false))!, "false")
    }
    
    // This test should go elsewhere
    func testBoolBoxing() {
        let template = Template(string:"{{.}}:{{#.}}true{{/.}}{{^.}}false{{/.}}")!
        XCTAssertEqual(template.render(Box(true))!, "1:true")
        XCTAssertEqual(template.render(Box(false))!, "0:false")
    }
    
    func testIntValue() {
        // Int -> Int
        XCTAssertEqual(Box(0 as Int).intValue!, 0)
        XCTAssertEqual(Box(1 as Int).intValue!, 1)
        XCTAssertEqual(Box(-1 as Int).intValue!, -1)
        XCTAssertEqual(Box(Int.min).intValue!, Int.min)
        XCTAssertEqual(Box(Int.max).intValue!, Int.max)
        
        // UInt -> Int
        XCTAssertEqual(Box(0 as UInt).intValue!, 0)
        XCTAssertEqual(Box(1 as UInt).intValue!, 1)
        XCTAssertEqual(Box(UInt(Int.max)).intValue!, Int.max)
        XCTAssertEqual(Box(UInt.min).intValue!, 0)
        XCTAssertNil(Box(UInt.max).intValue)
        
        // Double -> Int
        XCTAssertEqual(Box(0 as Double).intValue!, 0)
        XCTAssertEqual(Box(1.0 as Double).intValue!, 1)
        XCTAssertEqual(Box(-1.0 as Double).intValue!, -1)
        XCTAssertEqual(Box(0.25 as Double).intValue!, Int(0.25))
        XCTAssertEqual(Box(1.75 as Double).intValue!, Int(1.75))
        XCTAssertEqual(Box(-0.25 as Double).intValue!, Int(-0.25))
        XCTAssertEqual(Box(-1.75 as Double).intValue!, Int(-1.75))
        XCTAssertEqual(Box(Double(Int.min)).intValue!, Int.min)
        XCTAssertEqual(Box(Double(Int.max)).intValue!, Int.max)
        XCTAssertEqual(Box(Double(UInt.min)).intValue!, 0)
        XCTAssertNil(Box(Double(UInt.max)).intValue)
        XCTAssertNil(Box(Double.infinity).intValue)
        XCTAssertNil(Box(Double.NaN).intValue)
        XCTAssertNil(Box(Double.quietNaN).intValue)
        
        // Bool -> Int
        XCTAssertEqual(Box(false).intValue!, 0)
        XCTAssertEqual(Box(true).intValue!, 1)
        XCTAssertEqual(Box(NSNumber(bool: false)).intValue!, 0)
        XCTAssertEqual(Box(NSNumber(bool: true)).intValue!, 1)
        
        // NSNumber -> Int
        XCTAssertEqual(Box(NSNumber(integer: 0)).intValue!, 0)
        XCTAssertEqual(Box(NSNumber(integer: 1)).intValue!, 1)
        
        // Non numeric -> Int
        XCTAssertNil(Box().intValue)
        XCTAssertNil(Box("foo").intValue)
        XCTAssertNil(Box("1").intValue)
    }
    
    func testUIntValue() {
        // Int -> UInt
        XCTAssertEqual(Box(0 as Int).uintValue!, 0)
        XCTAssertEqual(Box(1 as Int).uintValue!, 1)
        XCTAssertNil(Box(-1 as Int).uintValue)
        XCTAssertEqual(Box(Int.max).uintValue!, UInt(Int.max))
        XCTAssertNil(Box(Int.min).uintValue)
        
        // UInt -> UInt
        XCTAssertEqual(Box(0 as UInt).uintValue!, UInt(0))
        XCTAssertEqual(Box(1 as UInt).uintValue!, UInt(1))
        XCTAssertEqual(Box(UInt(Int.max)).uintValue!, UInt(Int.max))
        XCTAssertEqual(Box(UInt.min).uintValue!, UInt.min)
        XCTAssertEqual(Box(UInt.max).uintValue!, UInt.max)
        
        // Double -> UInt
        XCTAssertEqual(Box(0 as Double).uintValue!, 0)
        XCTAssertEqual(Box(1.0 as Double).uintValue!, 1)
        XCTAssertNil(Box(-1.0 as Double).uintValue)
        XCTAssertEqual(Box(0.25 as Double).uintValue!, UInt(0.25))
        XCTAssertEqual(Box(1.75 as Double).uintValue!, UInt(1.75))
        XCTAssertNil(Box(-0.25 as Double).uintValue)
        XCTAssertNil(Box(-1.75 as Double).uintValue)
        XCTAssertNil(Box(Double(Int.min)).uintValue)
        XCTAssertEqual(Box(Double(Int.max)).uintValue!, UInt(Double(Int.max)))  // precision loss here
        XCTAssertEqual(Box(Double(UInt.min)).uintValue!, UInt.min)
        XCTAssertEqual(Box(Double(UInt.max)).uintValue!, UInt.max)
        XCTAssertNil(Box(Double.infinity).uintValue)
        XCTAssertNil(Box(Double.NaN).uintValue)
        XCTAssertNil(Box(Double.quietNaN).uintValue)
        
        // Bool -> UInt
        XCTAssertEqual(Box(false).uintValue!, 0)
        XCTAssertEqual(Box(true).uintValue!, 1)
        XCTAssertEqual(Box(NSNumber(bool: false)).uintValue!, 0)
        XCTAssertEqual(Box(NSNumber(bool: true)).uintValue!, 1)
        
        // NSNumber -> UInt
        XCTAssertEqual(Box(NSNumber(integer: 0)).uintValue!, 0)
        XCTAssertEqual(Box(NSNumber(integer: 1)).uintValue!, 1)
        
        // Non numeric -> UInt
        XCTAssertNil(Box().uintValue)
        XCTAssertNil(Box("foo").uintValue)
        XCTAssertNil(Box("1").uintValue)
    }
    
    func testDoubleValue() {
        // Int -> Double
        XCTAssertEqual(Box(0 as Int).doubleValue!, 0.0)
        XCTAssertEqual(Box(1 as Int).doubleValue!, 1.0)
        XCTAssertEqual(Box(-1 as Int).doubleValue!, -1.0)
        XCTAssertEqual(Box(Int.max).doubleValue!, Double(Int.max))
        XCTAssertEqual(Box(Int.min).doubleValue!, Double(Int.min))
        
        // UInt -> Double
        XCTAssertEqual(Box(0 as UInt).doubleValue!, 0.0)
        XCTAssertEqual(Box(1 as UInt).doubleValue!, 1.0)
        XCTAssertEqual(Box(UInt(Int.max)).doubleValue!, Double(Int.max))
        XCTAssertEqual(Box(UInt.min).doubleValue!, Double(UInt.min))
        XCTAssertEqual(Box(UInt.max).doubleValue!, Double(UInt.max))
        
        // Double -> Double
        XCTAssertEqual(Box(0 as Double).doubleValue!, 0)
        XCTAssertEqual(Box(1.0 as Double).doubleValue!, 1.0)
        XCTAssertEqual(Box(-1.0 as Double).doubleValue!, -1.0)
        XCTAssertEqual(Box(0.25 as Double).doubleValue!, 0.25)
        XCTAssertEqual(Box(1.75 as Double).doubleValue!, 1.75)
        XCTAssertEqual(Box(-0.25 as Double).doubleValue!, -0.25)
        XCTAssertEqual(Box(-1.75 as Double).doubleValue!, -1.75)
        XCTAssertEqual(Box(Double(Int.min)).doubleValue!, Double(Int.min))
        XCTAssertEqual(Box(Double(Int.max)).doubleValue!, Double(Int.max))
        XCTAssertEqual(Box(Double(UInt.min)).doubleValue!, Double(UInt.min))
        XCTAssertEqual(Box(Double(UInt.max)).doubleValue!, Double(UInt.max))
        XCTAssertEqual(Box(Double.infinity).doubleValue!, Double.infinity)
        XCTAssertTrue(Box(Double.NaN).doubleValue!.isNaN)
        XCTAssertTrue(Box(Double.quietNaN).doubleValue!.isNaN)
        
        // Bool -> Double
        XCTAssertEqual(Box(false).doubleValue!, 0.0)
        XCTAssertEqual(Box(true).doubleValue!, 1.0)
        XCTAssertEqual(Box(NSNumber(bool: false)).doubleValue!, 0.0)
        XCTAssertEqual(Box(NSNumber(bool: true)).doubleValue!, 1.0)
        
        // NSNumber -> Double
        XCTAssertEqual(Box(NSNumber(double: 0.0)).doubleValue!, 0.0)
        XCTAssertEqual(Box(NSNumber(double: 1.0)).doubleValue!, 1.0)
        
        // Non numeric -> Double
        XCTAssertNil(Box().doubleValue)
        XCTAssertNil(Box("foo").doubleValue)
        XCTAssertNil(Box("1").doubleValue)
    }
}
