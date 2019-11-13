import XCTest
import Mustache

class BoxTestsWithMissingIndentifiers: XCTestCase {
    override func setUp() {
        super.setUp()

        DefaultConfiguration.throwWhenMissing = true
    }

    override func tearDown() {
        super.tearDown()

        DefaultConfiguration.throwWhenMissing = false
    }

    func testIdentifier() {
        do {
            // Key exists, but value is nil
            let value: [String: Any?] = ["string": "foo", "missing": nil]
            let template = try! Template(string: "{{string}}, {{missing}}")
            assert(try template.render(value), throws: missingErrorDescription("missing", 1))
        }

        do {
            // Key does not exist
            let value: [String: Any?] = ["string": "foo"]
            let template = try! Template(string: "{{string}}, {{missing}}")
            assert(try template.render(value), throws: missingErrorDescription("missing", 1))
        }
    }

    func testIdentifierWithSubscript() {
        do {
            // Key exists, but value is nil
            let value: [String: Any?] = ["string": "foo", "subscript": ["int": 1, "missing": nil]]
            let template = try! Template(string: "{{string}}, {{subscript.int}}, {{subscript.missing}}")
            assert(try template.render(value), throws: missingErrorDescription("subscript.missing", 1))
        }

        do {
            // Key does not exist
            let value: [String: Any?] = ["string": "foo", "subscript": ["int": 1]]
            let template = try! Template(string: "{{string}}, {{subscript.int}}, {{subscript.missing}}")
            assert(try template.render(value), throws: missingErrorDescription("subscript.missing", 1))
        }
    }

    func testSection() {
        do {
            // Key exists, but value is nil
            let value: [String: Any?] = ["section": ["int": 1, "missing": nil]]
            let template = try! Template(string: "{{#section}}{{int}}, {{missing}}{{/section}}")
            assert(try template.render(value), throws: missingErrorDescription("missing", 1))
        }

        do {
            // Key does not exist
            let value: [String: Any?] = ["section": ["int": 1]]
            let template = try! Template(string: "{{#section}}{{int}}, {{missing}}{{/section}}")
            assert(try template.render(value), throws: missingErrorDescription("missing", 1))
        }

        do {
            // Section does not exist
            let value: [String: Any?] = [:]
            let template = try! Template(string: "{{#section}}{{int}}, {{missing}}{{/section}}")
            assert(try template.render(value), throws: missingErrorDescription("#section", 1))
        }
    }
}

private func missingErrorDescription(_ label: String, _ lineNumber: Int) -> String {
    return "Rendering error at line \(lineNumber): Could not evaluate {{\(label)}} at line \(lineNumber): Missing identifier"
}

// Inspired by https://www.swiftbysundell.com/articles/testing-error-code-paths-in-swift/
private extension XCTestCase {
    func assert<T>(
        _ expression: @autoclosure () throws -> T,
        throws errorDescription: String,
        in file: StaticString = #file,
        line: UInt = #line
    ) {
        var thrownError: Error?

        XCTAssertThrowsError(try expression(), file: file, line: line) {
            thrownError = $0
        }

        if let thrownError = thrownError {
            XCTAssertEqual(thrownError.localizedDescription, errorDescription, file: file, line: line)
        }
    }
}
