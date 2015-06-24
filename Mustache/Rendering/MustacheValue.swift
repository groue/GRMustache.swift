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


import Foundation


/**
`Rendering` is a type that wraps a rendered String, and its content type (HTML
or Text).

See `RenderFunction` and `FilterFunction` for more information.
*/
public struct Rendering {

    /// The rendered string
    public let string: String

    /// The content type of the rendering
    public let contentType: ContentType

    /**
    Builds a Rendering with a String and a ContentType.

        Rendering("foo")        // Defaults to Text
        Rendering("foo", .Text)
        Rendering("foo", .HTML)

    - parameter string:      A string.
    - parameter contentType: A content type.
    - returns: A Rendering.
    */
    public init(_ string: String, _ contentType: ContentType = .Text) {
        self.string = string
        self.contentType = contentType
    }
}

extension Rendering : CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        var string = self.string
        string = string.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
        string = string.stringByReplacingOccurrencesOfString("\n", withString: "\\n")
        string = string.stringByReplacingOccurrencesOfString("\r", withString: "\\r")
        string = string.stringByReplacingOccurrencesOfString("\t", withString: "\\t")
        string = string.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")

        var contentTypeString: String
        switch contentType {
        case .HTML:
            contentTypeString = "HTML"
        case .Text:
            contentTypeString = "Text"
        }

        return "Rendering(\(contentTypeString):\"\(string)\")"
    }
}


/**
`RenderingInfo` provides information about a rendering.

See `RenderFunction` for more information.
*/
public struct RenderingInfo {

    /// The currently rendered tag.
    public let tag: Tag

    /// The current context stack.
    public var context: Context

    // If true, the rendering is part of an enumeration. Some values don't
    // render the same whenever they render as an enumeration item, or alone:
    // {{# values }}...{{/ values }} vs. {{# value }}...{{/ value }}.
    //
    // This is the case of Int, UInt, Double, Bool: they enter the context
    // stack when used in an iteration, and do not enter the context stack when
    // used as a boolean (see https://github.com/groue/GRMustache/issues/83).
    //
    // This is also the case of collections: they enter the context stack when
    // used as an item of a collection, and enumerate their items when used as
    // a collection.
    var enumerationItem: Bool
}


public protocol MustacheValue {
    var mustacheInnerValue: Any? { get }
    var mustacheBoolValue: Bool { get }
    var mustacheArrayValue: [MustacheValue]? { get }
    var mustacheDictionaryValue: [String: MustacheValue]? { get }
    func mustacheSubscript(key: String) -> MustacheValue
    func mustacheRender(info: RenderingInfo) throws -> Rendering
    func mustacheFilter(value: MustacheValue, partialApplication: Bool) throws -> MustacheValue
    func mustacheWillRender(tag: Tag, value: MustacheValue) -> MustacheValue
    func mustacheDidRender(tag: Tag, value: MustacheValue, string: String?)
}

public extension MustacheValue {
    var mustacheInnerValue: Any? {
        return nil
    }
    
    var mustacheBoolValue: Bool {
        return true
    }
    
    var mustacheArrayValue: [MustacheValue]? {
        return nil
    }
    
    var mustacheDictionaryValue: [String: MustacheValue]? {
        return nil
    }
    
    func mustacheSubscript(key: String) -> MustacheValue {
        return MissingMustacheKey
    }
    
    func mustacheRender(info: RenderingInfo) throws -> Rendering {
        // Default rendering depends on the tag type:
        
        switch info.tag.type {
        case .Variable:
            // {{ value }} and {{{ value }}}
            
            if let mustacheInnerValue = mustacheValue {
                // Use the built-in Swift String Interpolation:
                return Rendering("\(mustacheInnerValue)", .Text)
            } else {
                return Rendering("", .Text)
            }
        case .Section:
            // {{# value }}...{{/ value }}
            
            // Push the value on the top of the context stack:
            let context = info.context.extendedContext(self)
            
            // Renders the inner content of the section tag:
            return try info.tag.render(context)
        }
    }
    
    func mustacheFilter(value: MustacheValue, partialApplication: Bool) throws -> MustacheValue {
        throw NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Not a filter"])
    }
    
    func mustacheWillRender(tag: Tag, value: MustacheValue) -> MustacheValue {
        return value
    }
    
    func mustacheDidRender(tag: Tag, value: MustacheValue, string: String?) {
        
    }
}

public struct _MissingMustacheKey: MustacheValue {
    public var mustacheBoolValue: Bool {
        return false
    }
    
    public func mustacheRender(info: RenderingInfo) throws -> Rendering {
        return Rendering("")
    }
}

public let MissingMustacheKey = _MissingMustacheKey()

public struct _MissingMustacheValue: MustacheValue {
    public var mustacheBoolValue: Bool {
        return false
    }
    
    public func mustacheRender(info: RenderingInfo) throws -> Rendering {
        return Rendering("")
    }
}

public let MissingMustacheValue = _MissingMustacheValue()
