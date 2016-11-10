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

class LoggerTests : XCTestCase {
    
    func testFullTemplateLogging() {
        var logMessages = [String]()
        let logger = StandardLibrary.Logger { logMessages.append($0) }
        
        let template = try! Template(string: "{{#people}}- {{name}} has a Mustache.\n{{/people}}")
        template.extendBaseContext(logger)
        
        let data = ["people": [["name": "Frank Zappa"], ["name": "Charlie Chaplin"], ["name": "Albert Einstein"]]]
        _ = try! template.render(data)
        
        XCTAssertEqual(logMessages.count, 5)
        XCTAssertEqual(logMessages[0], "{{#people}} at line 1 will render [[\"name\":\"Frank Zappa\"],[\"name\":\"Charlie Chaplin\"],[\"name\":\"Albert Einstein\"]]")
        XCTAssertEqual(logMessages[1], "  {{name}} at line 1 did render \"Frank Zappa\" as \"Frank Zappa\"")
        XCTAssertEqual(logMessages[2], "  {{name}} at line 1 did render \"Charlie Chaplin\" as \"Charlie Chaplin\"")
        XCTAssertEqual(logMessages[3], "  {{name}} at line 1 did render \"Albert Einstein\" as \"Albert Einstein\"")
        XCTAssertEqual(logMessages[4], "{{#people}} at line 1 did render [[\"name\":\"Frank Zappa\"],[\"name\":\"Charlie Chaplin\"],[\"name\":\"Albert Einstein\"]] as \"- Frank Zappa has a Mustache.\\n- Charlie Chaplin has a Mustache.\\n- Albert Einstein has a Mustache.\\n\"")
    }
    
    func testPartialTemplateLogging() {
        var logMessages = [String]()
        let logger = StandardLibrary.Logger { logMessages.append($0) }
        
        let template = try! Template(string: "{{#people}}{{#log}}- {{name}} has a Mustache.\n{{/log}}{{/people}}{{#log}}{{missing}}{{/log}}")
        template.register(logger, forKey: "log")
        
        let data = ["people": [["name": "Frank Zappa"], ["name": "Charlie Chaplin"], ["name": "Albert Einstein"]]]
        _ = try! template.render(data)
        
        XCTAssertEqual(logMessages.count, 4)
        XCTAssertEqual(logMessages[0], "{{name}} at line 1 did render \"Frank Zappa\" as \"Frank Zappa\"")
        XCTAssertEqual(logMessages[1], "{{name}} at line 1 did render \"Charlie Chaplin\" as \"Charlie Chaplin\"")
        XCTAssertEqual(logMessages[2], "{{name}} at line 1 did render \"Albert Einstein\" as \"Albert Einstein\"")
        XCTAssertEqual(logMessages[3], "{{missing}} at line 2 did render Empty as \"\"")
    }
}
