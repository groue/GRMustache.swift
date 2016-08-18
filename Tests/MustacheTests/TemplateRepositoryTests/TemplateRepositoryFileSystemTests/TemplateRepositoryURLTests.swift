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
import Foundation

class TemplateRepositoryURLTests: XCTestCase {

// GENERATED: allTests required for Swift 3.0
    var allTests : [(String, () throws -> Void)] {
        return [
            ("testTemplateRepositoryWithURL", testTemplateRepositoryWithURL),
            ("testTemplateRepositoryWithURLTemplateExtensionEncoding", testTemplateRepositoryWithURLTemplateExtensionEncoding),
            ("testAbsolutePartialName", testAbsolutePartialName),
            ("testPartialNameCanNotEscapeTemplateRepositoryRootURL", testPartialNameCanNotEscapeTemplateRepositoryRootURL),
        ]
    }
// END OF GENERATED CODE
    
    func testTemplateRepositoryWithURL() {
        #if os(Linux) // Bundle(for:) is not yet implemented on Linux
            //TODO remove this ifdef once Bundle(for:) is implemented
            // issue https://bugs.swift.org/browse/SR-794
            let testBundle = Bundle(path: ".build/debug/Package.xctest/Contents/Resources")!
        #else
             let testBundle = Bundle(for: type(of: self))
        #endif
        let URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        let repo = TemplateRepository(baseURL: URL)
        var template: Template
        var rendering: String
        
        do {
            template = try repo.template(named: "notFound")
            XCTAssert(false)
        } catch {
        }
        
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        template = try! repo.template(string: "{{>file1}}")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        template = try! repo.template(string: "{{>dir/file1}}")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "dir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n")
        
        template = try! repo.template(string: "{{>dir/dir/file1}}")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "dir/dir/é1.mustache\ndir/dir/é2.mustache\n\n")
    }
    
    func testTemplateRepositoryWithURLTemplateExtensionEncoding() {
        #if os(Linux) // Bundle(for:) is not yet implemented on Linux
            //TODO remove this ifdef once Bundle(for:) is implemented
            // issue https://bugs.swift.org/browse/SR-794
            let testBundle = Bundle(path: ".build/debug/Package.xctest/Contents/Resources")!
        #else
             let testBundle = Bundle(for: type(of: self))
        #endif
        var URL: URL
        var repo: TemplateRepository
        var template: Template
        var rendering: String
        
        URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "mustache", encoding: String.Encoding.utf8)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "txt", encoding: String.Encoding.utf8)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n")
        
        URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "", encoding: String.Encoding.utf8)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n")
        
        URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests_ISOLatin1", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "mustache", encoding: String.Encoding.isoLatin1)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests_ISOLatin1", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "txt", encoding: String.Encoding.isoLatin1)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n")
        
        URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests_ISOLatin1", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "", encoding: String.Encoding.isoLatin1)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n")
    }
    
    func testAbsolutePartialName() {
        #if os(Linux) // Bundle(for:) is not yet implemented on Linux
            //TODO remove this ifdef once Bundle(for:) is implemented
            // issue https://bugs.swift.org/browse/SR-794
            let testBundle = Bundle(path: ".build/debug/Package.xctest/Contents/Resources")!
        #else
            let testBundle = Bundle(for: type(of: self))
        #endif

        let URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests", withExtension: nil)!
        let repo = TemplateRepository(baseURL: URL)
        let template = try! repo.template(named: "base")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testPartialNameCanNotEscapeTemplateRepositoryRootURL() {
        #if os(Linux) // Bundle(for:) is not yet implemented on Linux
            //TODO remove this ifdef once Bundle(for:) is implemented
            // issue https://bugs.swift.org/browse/SR-794
            let testBundle = Bundle(path: ".build/debug/Package.xctest/Contents/Resources")!
        #else
             let testBundle = Bundle(for: type(of: self))
        #endif
        let URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests", withExtension: nil)!
        let baseURL = URL.appendingPathComponent("partials")
        #if os(Linux) // see issue https://bugs.swift.org/browse/SR-996
            //TODO remove #if os(Linux) once the issue is resolved
            let repo = TemplateRepository(baseURL: baseURL!)
        #else
            let repo = TemplateRepository(baseURL: baseURL)
        #endif

        let template = try! repo.template(named: "partial2")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
        
        do {
            let _ = try repo.template(named: "up")
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.TemplateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
}
