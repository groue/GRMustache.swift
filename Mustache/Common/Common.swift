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
// MARK: - TemplateLocation

/**
*/
public struct TemplateLocation {
    /// The line numer
    public let lineNumber: Int
    
    /// The ID of the template
    public let templateID: TemplateID?
    
    let templateString: String
    let range: Range<String.Index>

    var templateSubstring: String { return templateString[range] }
    
    init(templateString: String, templateID: TemplateID?, range: Range<String.Index>, lineNumber: Int) {
        self.templateString = templateString
        self.templateID = templateID
        self.range = range
        self.lineNumber = lineNumber
    }
}


// TODO: choose between CustomDebugStringConvertible and CustomStringConvertible
extension TemplateLocation : CustomStringConvertible {
    /// A textual representation of `self`.
    public var description: String {
        if let templateID = templateID {
            return "line \(lineNumber) of template \(templateID)"
        } else {
            return "line \(lineNumber)"
        }
    }
}


// =============================================================================
// MARK: - Errors

public enum MustacheError : ErrorType {
    case TemplateNotFound(message: String, location: TemplateLocation?)
    case ParseError(message: String, location: TemplateLocation?)
    case RenderingError(message: String, location: TemplateLocation?)
    
    static func error(error: ErrorType, withDefaultLocation defaultLocation: TemplateLocation) -> ErrorType {
        do {
            do {
                throw error
                
            } catch MustacheError.ParseError(message: let message, location: let location) {
                if location == nil {
                    throw MustacheError.ParseError(message: message, location: defaultLocation)
                } else {
                    return error
                }
                
            } catch MustacheError.RenderingError(message: let message, location: let location) {
                if location == nil {
                    throw MustacheError.RenderingError(message: message, location: defaultLocation)
                } else {
                    return error
                }
                
            } catch MustacheError.TemplateNotFound(message: let message, location: let location) {
                if location == nil {
                    throw MustacheError.TemplateNotFound(message: message, location: defaultLocation)
                } else {
                    return error
                }
                
            } catch let error as NSError {
                var userInfo = error.userInfo ?? [:]
                if let originalLocalizedDescription: AnyObject = userInfo[NSLocalizedDescriptionKey] {
                    userInfo[NSLocalizedDescriptionKey] = "Error at \(defaultLocation): \(originalLocalizedDescription)"
                } else {
                    userInfo[NSLocalizedDescriptionKey] = "Error at \(defaultLocation)"
                }
                throw NSError(domain: error.domain, code: error.code, userInfo: userInfo)
            }
        } catch {
            return error
        }
    }
}

extension MustacheError : CustomStringConvertible {
    /// A textual representation of `self`.
    public var description: String {
        switch self {
        case .TemplateNotFound(message: let message, location: let location):
            if let location = location {
                return "Template not found at \(location): \(message)"
            } else {
                return "Template not found: \(message)"
            }
            
        case .ParseError(message: let message, location: let location):
            if let location = location {
                return "Parse error at \(location): \(message)"
            } else {
                return "Parse error: \(message)"
            }
            
        case .RenderingError(message: let message, location: let location):
            if let location = location {
                return "Rendering error at \(location): \(message)"
            } else {
                return "Rendering error: \(message)"
            }
        }
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
