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

class TemplateRepositoryPathTests: XCTestCase {
    
    func testTemplateRepositoryWithURL() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests_UTF8", ofType: nil)!
        let repo = TemplateRepository(directoryPath: directoryPath)
        var template: Template
        var rendering: String
        
        do {
            try repo.template(named: "notFound")
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
        let testBundle = NSBundle(forClass: self.dynamicType)
        var directoryPath: String
        var repo: TemplateRepository
        var template: Template
        var rendering: String
        
        directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests_UTF8", ofType: nil)!
        repo = TemplateRepository(directoryPath: directoryPath, templateExtension: "mustache", encoding: NSUTF8StringEncoding)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests_UTF8", ofType: nil)!
        repo = TemplateRepository(directoryPath: directoryPath, templateExtension: "txt", encoding: NSUTF8StringEncoding)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n")
        
        directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests_UTF8", ofType: nil)!
        repo = TemplateRepository(directoryPath: directoryPath, templateExtension: "", encoding: NSUTF8StringEncoding)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n")
        
        directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests_ISOLatin1", ofType: nil)!
        repo = TemplateRepository(directoryPath: directoryPath, templateExtension: "mustache", encoding: NSISOLatin1StringEncoding)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests_ISOLatin1", ofType: nil)!
        repo = TemplateRepository(directoryPath: directoryPath, templateExtension: "txt", encoding: NSISOLatin1StringEncoding)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n")
        
        directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests_ISOLatin1", ofType: nil)!
        repo = TemplateRepository(directoryPath: directoryPath, templateExtension: "", encoding: NSISOLatin1StringEncoding)
        template = try! repo.template(named: "file1")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n")
    }
    
    func testAbsolutePartialName() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests", ofType: nil)!
        let repo = TemplateRepository(directoryPath: directoryPath)
        let template = try! repo.template(named: "base")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
    }
    
    func testPartialNameCanNotEscapeTemplateRepositoryRootDirectory() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let directoryPath = testBundle.pathForResource("TemplateRepositoryFileSystemTests", ofType: nil)!
        let repo = TemplateRepository(directoryPath: (directoryPath as NSString).stringByAppendingPathComponent("partials"))
        
        let template = try! repo.template(named: "partial2")
        let rendering = try! template.render()
        XCTAssertEqual(rendering, "success")
        
        do {
            try repo.template(named: "up")
            XCTFail("Expected MustacheError")
        } catch let error as MustacheError {
            XCTAssertEqual(error.kind, MustacheError.Kind.TemplateNotFound)
        } catch {
            XCTFail("Expected MustacheError")
        }
    }
}
