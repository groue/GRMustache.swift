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
Mustache templates don't eat raw values: they eat values boxed in `MustacheBox`.

To box something in a `MustacheBox`, you use one variant of the `Box()`
function. It comes in several variants so that nearly anything can be boxed and
feed templates:

- Basic Swift values:

        template.render(Box("foo"))

- Dictionaries & collections:

        template.render(Box(["numbers": [1,2,3]]))

- Custom types via the `MustacheBoxable` protocol:
    
        extension User: MustacheBoxable { ... }
        template.render(Box(user))

- Functions such as `FilterFunction`, `RenderFunction`, `WillRenderFunction` and
  `DidRenderFunction`:

        let square = Filter { (x: Int?) in Box(x! * x!) }
        template.registerInBaseContext("square", Box(square))

Warning: the fact that `MustacheBox` is a subclass of NSObject is an
implementation detail that is enforced by the Swift 2 language itself. This may
change in the future: do not rely on it.
*/
public class MustacheBox : NSObject {
    
    // IMPLEMENTATION NOTE
    //
    // Why is MustacheBox a subclass of NSObject, and not, say, a Swift struct?
    //
    // Swift does not allow a class extension to override a method that is
    // inherited from an extension to its superclass and incompatible with
    // Objective-C.
    //
    // If MustacheBox were a pure Swift type, this Swift limit would prevent
    // NSObject subclasses such as NSNull, NSNumber, etc. to override
    // MustacheBoxable.mustacheBox, and provide custom rendering behavior.
    //
    // For an example of this limitation, see example below:
    //
    //     import Foundation
    //     
    //     // A type that is not compatible with Objective-C
    //     struct MustacheBox { }
    //     
    //     // So far so good
    //     extension NSObject {
    //         var mustacheBox: MustacheBox { return MustacheBox() }
    //     }
    //     
    //     // Error: declarations in extensions cannot override yet
    //     extension NSNull {
    //         override var mustacheBox: MustacheBox { return MustacheBox() }
    //     }
    //
    // This problem does not apply to Objc-C compatible protocols:
    //
    //     import Foundation
    //     
    //     // So far so good
    //     extension NSObject {
    //         var prop: String { return "NSObject" }
    //     }
    //     
    //     // No error
    //     extension NSNull {
    //         override var prop: String { return "NSNull" }
    //     }
    //     
    //     NSObject().prop // "NSObject"
    //     NSNull().prop   // "NSNull"
    //
    // In order to let the user easily override NSObject.mustacheBox, we had to
    // keep its return type compatible with Objective-C, that is to say make
    // MustacheBox a subclass of NSObject.
    

    // -------------------------------------------------------------------------
    // MARK: - The boxed value
    
    /// The boxed value.
    public let value: Any?
    
    /// The only empty box is `Box()`.
    public let isEmpty: Bool
    
    /**
    The boolean value of the box.
    
    It tells whether the Box should trigger or prevent the rendering of regular
    `{{#section}}...{{/}}` and inverted `{{^section}}...{{/}}`.
    */
    public let boolValue: Bool
    
    /**
    If the boxed value can be iterated (Swift collection, NSArray, NSSet, etc.),
    returns an array of `MustacheBox`.
    */
    public var arrayValue: [MustacheBox]? {
        return converter?.arrayValue()
    }
    
    /**
    If the boxed value is a dictionary (Swift dictionary, NSDictionary, etc.),
    returns a dictionary `[String: MustacheBox]`.
    */
    public var dictionaryValue: [String: MustacheBox]? {
        return converter?.dictionaryValue()
    }
    
    /**
    Extracts a key out of a box.
    
        let box = Box(["firstName": "Arthur"])
        box["firstName"].value  // "Arthur"
    
    - parameter key:  A key
    - returns: the MustacheBox for this key.
    */
    public subscript (key: String) -> MustacheBox {
        return keyedSubscript?(key: key) ?? Box()
    }
    
    
    // -------------------------------------------------------------------------
    // MARK: - Other facets
    
    /// See the documentation of `RenderFunction`.
    public private(set) var render: RenderFunction
    
    /// See the documentation of `FilterFunction`.
    public let filter: FilterFunction?
    
    /// See the documentation of `WillRenderFunction`.
    public let willRender: WillRenderFunction?
    
    /// See the documentation of `DidRenderFunction`.
    public let didRender: DidRenderFunction?
    
    
    // -------------------------------------------------------------------------
    // MARK: - Internal
    
    let keyedSubscript: KeyedSubscriptFunction?
    let converter: Converter?
    
    init(
        value: Any? = nil,
        boolValue: Bool? = nil,
        converter: Converter? = nil,
        keyedSubscript: KeyedSubscriptFunction? = nil,
        filter: FilterFunction? = nil,
        render: RenderFunction? = nil,
        willRender: WillRenderFunction? = nil,
        didRender: DidRenderFunction? = nil)
    {
        let empty = (value == nil) && (keyedSubscript == nil) && (render == nil) && (filter == nil) && (willRender == nil) && (didRender == nil)
        self.isEmpty = empty
        self.value = value
        self.converter = converter
        self.boolValue = boolValue ?? !empty
        self.keyedSubscript = keyedSubscript
        self.filter = filter
        self.willRender = willRender
        self.didRender = didRender
        if let render = render {
            self.render = render
            super.init()
        } else {
            // The default render function: it renders {{variable}} tags as the
            // boxed value, and {{#section}}...{{/}} tags by adding the box to
            // the context stack.
            //
            // IMPLEMENTATIN NOTE
            //
            // We have to set self.render twice in order to avoid the compiler
            // error: "variable 'self.render' captured by a closure before being
            // initialized"
            self.render = { (_) in return Rendering("") }
            super.init()
            self.render = { (info: RenderingInfo) in
                
                // Default rendering depends on the tag type:
                switch info.tag.type {
                case .Variable:
                    // {{ box }} and {{{ box }}}
                    
                    if let value = value {
                        // Use the built-in Swift String Interpolation:
                        return Rendering("\(value)", .Text)
                    } else {
                        return Rendering("", .Text)
                    }
                case .Section:
                    // {{# box }}...{{/ box }}
                    
                    // Push the value on the top of the context stack:
                    let context = info.context.extendedContext(self)
                    
                    // Renders the inner content of the section tag:
                    return try info.tag.render(context)
                }
            }
        }
    }
    
    // Converter wraps all the conversion closures that help MustacheBox expose
    // its raw value (typed Any) as useful types.
    struct Converter {
        let arrayValue: (() -> [MustacheBox]?)
        let dictionaryValue: (() -> [String: MustacheBox]?)
        
        init(
            @autoclosure(escaping) arrayValue: () -> [MustacheBox]? = nil,
            @autoclosure(escaping) dictionaryValue: () -> [String: MustacheBox]? = nil)
        {
            self.arrayValue = arrayValue
            self.dictionaryValue = dictionaryValue
        }
    }
}

extension MustacheBox : CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public override var debugDescription: String {
        if let value = value {
            return "MustacheBox(\(value))"  // remove "Optional" from the output
        } else {
            return "MustacheBox(nil)"
        }
    }
}
