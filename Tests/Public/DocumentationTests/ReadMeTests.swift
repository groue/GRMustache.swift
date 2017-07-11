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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ReadMeTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        DefaultConfiguration = Configuration()
    }
    
    func testReadmeExample1() {
        let testBundle = Bundle(for: type(of: self))
        let template = try! Template(named: "ReadMeExample1", bundle: testBundle)
        let data: [String: Any] = [
            "name": "Chris",
            "value": 10000,
            "taxed_value": 10000 - (10000 * 0.4),
            "in_ca": true]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "Hello Chris\nYou have just won 10000 dollars!\n\nWell, 6000.0 dollars, after taxes.\n")
    }
    
    func testReadmeExample2() {
        // Define the `pluralize` filter.
        //
        // {{# pluralize(count) }}...{{/ }} renders the plural form of the
        // section content if the `count` argument is greater than 1.
        
        let pluralizeFilter = Filter { (count: Int?, info: RenderingInfo) -> Rendering in
            
            // Pluralize the inner content of the section tag:
            var string = info.tag.innerTemplateString
            if count > 1 {
                string += "s"  // naive
            }
            
            return Rendering(string)
        }
        
        
        // Register the pluralize filter for all Mustache renderings:
        
        Mustache.DefaultConfiguration.register(pluralizeFilter, forKey: "pluralize")
        
        
        // I have 3 cats.
        
        let testBundle = Bundle(for: type(of: self))
        let template = try! Template(named: "ReadMeExample2", bundle: testBundle)
        let data = ["cats": ["Kitty", "Pussy", "Melba"]]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "I have 3 cats.")
    }
    
    func testReadmeExample3() {
        // TODO: update example from README.md
        //
        // Allow Mustache engine to consume User values.
        struct User : MustacheBoxable {
            let name: String
            var mustacheBox: MustacheBox {
                // Return a Box that wraps our user, and knows how to extract
                // the `name` key of our user:
                return MustacheBox(value: self, keyedSubscript: { (key: String) in
                    switch key {
                    case "name":
                        return self.name
                    default:
                        return nil
                    }
                })
            }
        }
        
        let user = User(name: "Arthur")
        let template = try! Template(string: "Hello {{name}}!")
        let rendering = try! template.render(user)
        XCTAssertEqual(rendering, "Hello Arthur!")
    }
    
    func testReadMeExampleNSFormatter1() {
        let percentFormatter = NumberFormatter()
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        percentFormatter.numberStyle = .percent
        
        let template = try! Template(string: "{{ percent(x) }}")
        template.register(percentFormatter, forKey: "percent")
        
        let data = ["x": 0.5]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "50%")
    }
    
    func testReadMeExampleNSFormatter2() {
        let percentFormatter = NumberFormatter()
        percentFormatter.locale = Locale(identifier: "en_US_POSIX")
        percentFormatter.numberStyle = .percent
        
        let template = try! Template(string: "{{# percent }}{{ x }}{{/ }}")
        template.register(percentFormatter, forKey: "percent")
        
        let data = ["x": 0.5]
        let rendering = try! template.render(data)
        XCTAssertEqual(rendering, "50%")
    }
    
    func testDemo() {
        let templateString = "Hello {{name}}\n" +
        "Your luggage will arrive on {{format(date)}}.\n" +
        "{{#late}}\n" +
        "Well, on {{format(real_date)}} due to Martian attack.\n" +
        "{{/late}}"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let template = try! Template(string: templateString)
        template.register(dateFormatter, forKey: "format")
        
        let data: [String: Any] = [
            "name": "Arthur",
            "date": Date(),
            "real_date": Date().addingTimeInterval(60*60*24*3),
            "late": true
        ]
        let rendering = try! template.render(data)
        XCTAssert(rendering.count > 0)
    }
}

