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


// =============================================================================
// MARK: - ContentType

/**
GRMustache distinguishes Text from HTML.

Content type applies to both *templates*, and *renderings*:

- In a HTML template, `{{name}}` tags escape Text renderings, but do not escape
HTML renderings.

- In a Text template, `{{name}}` tags do not escape anything.

The content type of a template comes from `Configuration.contentType` or
`{{% CONTENT_TYPE:... }}` pragma tags. See the documentation of
`Configuration.contentType` for a full discussion.

The content type of rendering is discussed with the `Rendering` type.

See also:

- Configuration.contentType
- Rendering
*/
public enum ContentType {
    case Text
    case HTML
}


// =============================================================================
// MARK: - Errors

public struct Error: ErrorType {
    public let _domain = "Mustache.Error"
    public var _code: Int { return type.rawValue }
    
    public enum Type : Int {
        case TemplateNotFound
        case ParseError
        case RenderingError
    }
    
    public let type: Type
    public let message: String?
    public let templateID: String?
    public let lineNumber: Int?
    public let underlyingError: ErrorType?
    
    public init(type: Type, message: String? = nil, templateID: TemplateID? = nil, lineNumber: Int? = nil, underlyingError: ErrorType? = nil) {
        self.type = type
        self.message = message
        self.templateID = templateID
        self.lineNumber = lineNumber
        self.underlyingError = underlyingError
    }
    
    func errorWith(message message: String? = nil, templateID: TemplateID? = nil, lineNumber: Int? = nil, underlyingError: ErrorType? = nil) -> Error {
        return Error(
            type: self.type,
            message: message ?? self.message,
            templateID: templateID ?? self.templateID,
            lineNumber: lineNumber ?? self.lineNumber,
            underlyingError: underlyingError ?? self.underlyingError)
    }
}

extension Error : CustomStringConvertible {
    
    var locationDescription: String? {
        if let templateID = templateID {
            if let lineNumber = lineNumber {
                return "line \(lineNumber) of template \(templateID)"
            } else {
                return "template \(templateID)"
            }
        } else {
            if let lineNumber = lineNumber {
                return "line \(lineNumber)"
            } else {
                return nil
            }
        }
    }
    
    /// A textual representation of `self`.
    public var description: String {
        var description: String
        switch type {
        case .TemplateNotFound:
            description = "No such template: \(templateID)"
        case .ParseError:
            if let locationDescription = locationDescription {
                description = "Parse error at \(locationDescription)"
            } else {
                description = "Parse error"
            }
        case .RenderingError:
            if let locationDescription = locationDescription {
                description = "Rendering error at \(locationDescription)"
            } else {
                description = "Rendering error"
            }
        }
        
        if let message = message {
            description += ": \(message)"
        }
        
        if let underlyingError = underlyingError {
            description += " (\(underlyingError))"
        }
        
        return description
    }
}


// =============================================================================
// MARK: - Tag delimiters

/**
A pair of tag delimiters, such as `("{{", "}}")`.

:see Configuration.tagDelimiterPair
:see Tag.tagDelimiterPair
*/
public typealias TagDelimiterPair = (String, String)


// =============================================================================
// MARK: - HTML escaping

/**
HTML-escapes a string by replacing `<`, `> `, `&`, `'` and `"` with HTML entities.

- parameter string: A string.
- returns: The HTML-escaped string.
*/
public func escapeHTML(string: String) -> String {
    let escapeTable: [Character: String] = [
        "<": "&lt;",
        ">": "&gt;",
        "&": "&amp;",
        "'": "&apos;",
        "\"": "&quot;",
    ]
    var escaped = ""
    for c in string.characters {
        if let escapedString = escapeTable[c] {
            escaped += escapedString
        } else {
            escaped.append(c)
        }
    }
    return escaped
}
