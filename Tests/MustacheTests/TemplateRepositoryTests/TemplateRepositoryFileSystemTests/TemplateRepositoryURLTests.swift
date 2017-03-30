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

class TemplateRepositoryURLTests: XCTestCase {
    
    func testTemplateRepositoryWithURL() {
        let testBundle = Bundle(for: type(of: self))
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
        let testBundle = Bundle(for: type(of: self))
        var URL: Foundation.URL
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
        let testBundle = Bundle(for: type(of: self))
        let URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests", withExtension: nil)!
        let repo = TemplateRepository(baseURL: URL)
        let template = try! repo.template(named: "base")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testPartialNameCanNotEscapeTemplateRepositoryRootURL() {
        let testBundle = Bundle(for: type(of: self))
        let URL = testBundle.url(forResource: "TemplateRepositoryFileSystemTests", withExtension: nil)!
        let repo = TemplateRepository(baseURL: URL.appendingPathComponent("partials"))
        
        let template = try! repo.template(named: "partial2")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
        
        do {
            _ = try repo.template(named: "up")
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.templateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
}
