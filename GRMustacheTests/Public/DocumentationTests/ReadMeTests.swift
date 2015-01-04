//
//  ReadMeTests.swift
//  GRMustache
//
//  Created by Gwendal Roué on 21/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import GRMustache

class ReadMeTests: XCTestCase {
    
    func testReadmeExample1() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let template = Template(named: "ReadMeExample1", bundle: testBundle)!
        let data = [
            "name": "Chris",
            "value": 10000.0,
            "taxed_value": 10000 - (10000 * 0.4),
            "in_ca": true]
        let rendering = template.render(Box(data))!
        XCTAssertEqual(rendering, "Hello Chris\nYou have just won 10000.0 dollars!\n\nWell, 6000.0 dollars, after taxes.\n")
    }
    
    func testReadmeExample2() {
        // Define the `pluralize` filter.
        //
        // {{# pluralize(count) }}...{{/ }} renders the plural form of the
        // section content if the `count` argument is greater than 1.
        
        let pluralizeFilter = Filter({ (count: Int?, info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            
            // Pluralize the inner content of the section tag:
            var string = info.tag.innerTemplateString
            if count > 1 {
                string += "s"  // naive
            }
            
            return Rendering(string)
        })
        
        
        // Register the pluralize filter for all Mustache renderings:
        
        Configuration.defaultConfiguration.extendBaseContext(Box(["pluralize": Box(pluralizeFilter)]))
        
        
        // I have 3 cats.
        
        let testBundle = NSBundle(forClass: self.dynamicType)
        let template = Template(named: "ReadMeExample2", bundle: testBundle)!
        let box = Box(["cats": ["Kitty", "Pussy", "Melba"]])
        let rendering = template.render(box)!
        XCTAssertEqual(rendering, "I have 3 cats.")
        
        Configuration.defaultConfiguration = Configuration()
    }
    
    func testReadmeExample3() {
        
        struct ReadmeExample3User: MustacheBoxable {
            let name: String
            
            func mustacheBox() -> Box {
                return Box({ (key: String) -> Box? in
                    switch key {
                    case "name":
                        return Box(self.name)
                    default:
                        return nil
                    }
                })
            }
        }
        
        let user = ReadmeExample3User(name: "Arthur")
        let rendering = Template(string:"Hello {{name}}!")!.render(Box(user))!
        XCTAssertEqual(rendering, "Hello Arthur!")
    }
    
}
