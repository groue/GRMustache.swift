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

class SuiteTestCase: XCTestCase {
    
    func runTestsFromResource(_ name: String, directory: String) {
        let testBundle = Bundle(for: type(of: self))
        let path: String! = testBundle.path(forResource: name, ofType: nil, inDirectory: directory)
        if path == nil {
            XCTFail("No such test suite \(directory)/\(name)")
            return
        }
        
        let data: Data! = try? Data(contentsOf: URL(fileURLWithPath: path))
        if data == nil {
            XCTFail("No test suite in \(path)")
            return
        }
        
        let testSuite = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
        
        let tests = testSuite["tests"] as! NSArray!
        if tests == nil {
            XCTFail("Missing tests in \(path)")
            return
        }
        
        for testDictionary in tests! {
            let test = Test(path: path, dictionary: testDictionary as! NSDictionary)
            test.run()
        }
    }
    
    class Test {
        let path: String
        let dictionary: NSDictionary
        
        init(path: String, dictionary: NSDictionary) {
            self.path = path
            self.dictionary = dictionary
        }
        
        func run() {
            let name = dictionary["name"] as! String
            NSLog("Run test \(name)")
            for template in templates {
                
                // Standard Library
                template.register(StandardLibrary.each, forKey: "each")
                template.register(StandardLibrary.zip, forKey: "zip")
                template.register(StandardLibrary.Localizer(bundle: nil, table: nil), forKey: "localize")
                template.register(StandardLibrary.HTMLEscape, forKey: "HTMLEscape")
                template.register(StandardLibrary.URLEscape, forKey: "URLEscape")
                template.register(StandardLibrary.javascriptEscape, forKey: "javascriptEscape")
                
                // Support for filters.json
                let capitalized = Filter { (string: String?) -> Any? in
                    return string?.capitalized
                }
                template.register(capitalized, forKey: "capitalized")
                
                testRendering(template)
            }
        }
        
        //
        
        var description: String { return "test `\(name)` at \(path)" }
        var name: String { return dictionary["name"] as! String }
        var partialsDictionary: [String: String]? { return dictionary["partials"] as! [String: String]? }
        var templateString: String? { return dictionary["template"] as! String? }
        var templateName: String? { return dictionary["template_name"] as! String? }
        var renderedValue: Any? { return dictionary["data"] }
        var expectedRendering: String? { return dictionary["expected"] as! String? }
        var expectedError: String? { return dictionary["expected_error"] as! String? }
        
        var templates: [Template] {
            if let partialsDictionary = partialsDictionary {
                if let templateName = templateName {
                    var templates: [Template] = []
                    let templateExtension = (templateName as NSString).pathExtension
                    for (directoryPath, encoding) in pathsAndEncodingsToPartials(partialsDictionary) {
                        do {
                            let template = try TemplateRepository(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding).template(named: (templateName as NSString).deletingPathExtension)
                            templates.append(template)
                        } catch {
                            testError(error, replayOnFailure: {
                                do {
                                    _ = try TemplateRepository(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding).template(named: (templateName as NSString).deletingPathExtension)
                                } catch {
                                    // ignore error on replay
                                }
                            })
                        }
                        
                        do {
                            let template = try TemplateRepository(baseURL: URL(fileURLWithPath: directoryPath), templateExtension: templateExtension, encoding: encoding).template(named: (templateName as NSString).deletingPathExtension)
                            templates.append(template)
                        } catch {
                            testError(error, replayOnFailure: {
                                do {
                                    _ = try TemplateRepository(baseURL: URL(fileURLWithPath: directoryPath), templateExtension: templateExtension, encoding: encoding).template(named: (templateName as NSString).deletingPathExtension)
                                } catch {
                                    // ignore error on replay
                                }
                            })
                        }
                    }
                    return templates
                } else if let templateString = templateString {
                    var templates: [Template] = []
                    for (directoryPath, encoding) in pathsAndEncodingsToPartials(partialsDictionary) {
                        do {
                            let template = try TemplateRepository(directoryPath: directoryPath, templateExtension: "", encoding: encoding).template(string: templateString)
                            templates.append(template)
                        } catch {
                            testError(error, replayOnFailure: {
                                do {
                                    _ = try TemplateRepository(directoryPath: directoryPath, templateExtension: "", encoding: encoding).template(string: templateString)
                                } catch {
                                    // ignore error on replay
                                }
                            })
                        }
                        
                        do {
                            let template = try TemplateRepository(baseURL: URL(fileURLWithPath: directoryPath), templateExtension: "", encoding: encoding).template(string: templateString)
                            templates.append(template)
                        } catch {
                            testError(error, replayOnFailure: {
                                do {
                                    _ = try TemplateRepository(baseURL: URL(fileURLWithPath: directoryPath), templateExtension: "", encoding: encoding).template(string: templateString)
                                } catch {
                                    // ignore error on replay
                                }
                            })
                        }
                    }
                    return templates
                } else {
                    XCTFail("Missing `template` and `template_name` in \(description)")
                    return []
                }
            } else {
                if let _ = templateName {
                    XCTFail("Missing `partials` in \(description)")
                    return []
                } else if let templateString = templateString {
                    var templates: [Template] = []
                    do {
                        let template = try TemplateRepository().template(string: templateString)
                        templates.append(template)
                    } catch {
                        testError(error, replayOnFailure: {
                            do {
                                _ = try TemplateRepository().template(string: templateString)
                            } catch {
                                // ignore error on replay
                            }
                        })
                    }
                    return templates
                } else {
                    XCTFail("Missing `template` and `template_name` in \(description)")
                    return []
                }
            }
        }
        
        func testRendering(_ template: Template) {
            do {
                let rendering = try template.render(renderedValue)
                if let expectedRendering = expectedRendering as String! {
                    if expectedRendering != rendering {
                        XCTAssertEqual(rendering, expectedRendering, "Unexpected rendering of \(description)")
                    }
                }
                testSuccess(replayOnFailure: {
                    do {
                        _ = try template.render(self.renderedValue)
                    } catch {
                        // ignore error on replay
                    }
                })
            } catch {
                testError(error, replayOnFailure: {
                    do {
                        _ = try template.render(self.renderedValue)
                    } catch {
                        // ignore error on replay
                    }
                })
            }
        }
        
        func testError(_ error: Error, replayOnFailure replayBlock: ()->()) {
            if let expectedError = expectedError {
                do {
                    let reg = try NSRegularExpression(pattern: expectedError, options: NSRegularExpression.Options(rawValue: 0))
                    let errorMessage = "\(error)"
                    let matches = reg.matches(in: errorMessage, options: NSRegularExpression.MatchingOptions(rawValue: 0), range:NSMakeRange(0, (errorMessage as NSString).length))
                    if matches.count == 0 {
                        XCTFail("`\(errorMessage)` does not match /\(expectedError)/ in \(description)")
                        replayBlock()
                    }
                } catch {
                    XCTFail("Invalid expected_error in \(description): \(error)")
                    replayBlock()
                }
            } else {
                XCTFail("Unexpected error in \(description): \(error)")
                replayBlock()
            }
        }
        
        func testSuccess(replayOnFailure replayBlock: ()->()) {
            if expectedError != nil {
                XCTFail("Unexpected success in \(description)")
                replayBlock()
            }
        }
        
        func pathsAndEncodingsToPartials(_ partialsDictionary: [String: String]) -> [(String, String.Encoding)] {
            var templatesPaths: [(String, String.Encoding)] = []
            
            let fm = FileManager.default
            let encodings: [String.Encoding] = [String.Encoding.utf8, String.Encoding.utf16]
            for encoding in encodings {
                let templatesPath = ((NSTemporaryDirectory() as NSString).appendingPathComponent("GRMustacheTest") as NSString).appendingPathComponent("encoding_\(encoding)")
                if fm.fileExists(atPath: templatesPath) {
                    try! fm.removeItem(atPath: templatesPath)
                }
                for (partialName, partialString) in partialsDictionary {
                    let partialPath = (templatesPath as NSString).appendingPathComponent(partialName)
                    do {
                        try fm.createDirectory(atPath: (partialPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
                        if !fm.createFile(atPath: partialPath, contents: partialString.data(using: encoding, allowLossyConversion: false), attributes: nil) {
                            XCTFail("Could not save template in \(description)")
                            return []
                        }
                    } catch {
                        XCTFail("Could not save template in \(description): \(error)")
                        return []
                    }
                }
                
                templatesPaths.append((templatesPath, encoding))
            }
            
            return templatesPaths
        }
    }
}
