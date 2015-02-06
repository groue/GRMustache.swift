//
//  TemplateRepositoryURLTests.swift
//
//  Created by Gwendal Roué on 27/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import XCTest
import Mustache

class TemplateRepositoryURLTests: XCTestCase {
    
    func testTemplateRepositoryWithURL() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        let repo = TemplateRepository(baseURL: URL)
        var template: Template?
        var error: NSError?
        var rendering: String?
        
        template = repo.template(named: "notFound", error: &error)
        XCTAssertNil(template)
        XCTAssertNotNil(error)
        
        template = repo.template(named: "file1")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        template = repo.template(string: "{{>file1}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        template = repo.template(string: "{{>dir/file1}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "dir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n")
        
        template = repo.template(string: "{{>dir/dir/file1}}")
        rendering = template?.render()
        XCTAssertEqual(rendering!, "dir/dir/é1.mustache\ndir/dir/é2.mustache\n\n")
    }
    
    func testTemplateRepositoryWithURLTemplateExtensionEncoding() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        var URL: NSURL
        var repo: TemplateRepository
        var template: Template
        var rendering: String
        
        URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "mustache", encoding: NSUTF8StringEncoding)
        template = repo.template(named: "file1")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "txt", encoding: NSUTF8StringEncoding)
        template = repo.template(named: "file1")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n")
        
        URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests_UTF8", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "", encoding: NSUTF8StringEncoding)
        template = repo.template(named: "file1")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n")
        
        URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests_ISOLatin1", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "mustache", encoding: NSISOLatin1StringEncoding)
        template = repo.template(named: "file1")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n")
        
        URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests_ISOLatin1", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "txt", encoding: NSISOLatin1StringEncoding)
        template = repo.template(named: "file1")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n")
        
        URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests_ISOLatin1", withExtension: nil)!
        repo = TemplateRepository(baseURL: URL, templateExtension: "", encoding: NSISOLatin1StringEncoding)
        template = repo.template(named: "file1")!
        rendering = template.render()!
        XCTAssertEqual(rendering, "é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n")
    }
    
    func testAbsolutePartialName() {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let URL = testBundle.URLForResource("TemplateRepositoryFileSystemTests", withExtension: nil)!
        let repo = TemplateRepository(baseURL: URL)
        let template = repo.template(named: "base")!
        let rendering = template.render()!
        XCTAssertEqual(rendering, "success")
    }
    
}
