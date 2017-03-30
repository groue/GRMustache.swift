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
        let template = try! Template(string:"{{#.}}true{{/.}}{{^.}}false{{/.}}")
        XCTAssertEqual(try! template.render(MustacheBox(boolValue: true)), "true")
        XCTAssertEqual(try! template.render(MustacheBox(boolValue: false)), "false")
    }
    
    // This test should go elsewhere
    func testBoolBoxing() {
        let template = try! Template(string:"{{.}}:{{#.}}true{{/.}}{{^.}}false{{/.}}")
        XCTAssertEqual(try! template.render(true), "1:true")
        XCTAssertEqual(try! template.render(false), "0:false")
    }
}
