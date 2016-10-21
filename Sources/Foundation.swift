// The MIT License
//
// Copyright (c) 2016 Gwendal Roué
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


/// GRMustache provides built-in support for rendering `NSObject`.
extension NSObject : MustacheBoxable {
    
    /// `NSObject` adopts the `MustacheBoxable` protocol so that it can feed
    /// Mustache templates.
    ///
    /// You should not directly call the `mustacheBox` property. Always use the
    /// `Box()` function instead:
    ///
    ///     object.mustacheBox   // Valid, but discouraged
    ///     Box(object)          // Preferred
    ///
    ///
    /// NSObject's default implementation handles two general cases:
    ///
    /// - Enumerable objects that conform to the `NSFastEnumeration` protocol, such
    ///   as `NSArray` and `NSOrderedSet`.
    /// - All other objects
    ///
    /// GRMustache ships with a few specific classes that escape the general
    /// cases and provide their own rendering behavior: `NSDictionary`,
    /// `NSFormatter`, `NSNull`, `NSNumber`, `NSString`, and `NSSet` (see the
    /// documentation for those classes).
    ///
    /// Your own subclasses of NSObject can also override the `mustacheBox`
    /// method and provide their own custom behavior.
    ///
    ///
    /// ## Arrays
    ///
    /// An object is treated as an array if it conforms to `NSFastEnumeration`.
    /// This is the case of `NSArray` and `NSOrderedSet`, for example.
    /// `NSDictionary` and `NSSet` have their own custom Mustache rendering: see
    /// their documentation for more information.
    ///
    ///
    /// ### Rendering
    ///
    /// - `{{array}}` renders the concatenation of the renderings of the
    ///   array items.
    ///
    /// - `{{#array}}...{{/array}}` renders as many times as there are items in
    ///   `array`, pushing each item on its turn on the top of the
    ///   context stack.
    ///
    /// - `{{^array}}...{{/array}}` renders if and only if `array` is empty.
    ///
    ///
    /// ### Keys exposed to templates
    ///
    /// An array can be queried for the following keys:
    ///
    /// - `count`: number of elements in the array
    /// - `first`: the first object in the array
    /// - `last`: the last object in the array
    ///
    /// Because 0 (zero) is falsey, `{{#array.count}}...{{/array.count}}`
    /// renders once, if and only if `array` is not empty.
    ///
    ///
    /// ## Other objects
    ///
    /// Other objects fall in the general case.
    ///
    /// Their keys are extracted with the `valueForKey:` method, as long as the
    /// key is a property name, a custom property getter, or the name of a
    /// `NSManagedObject` attribute.
    ///
    ///
    /// ### Rendering
    ///
    /// - `{{object}}` renders the result of the `description` method, HTML-escaped.
    ///
    /// - `{{{object}}}` renders the result of the `description` method, *not*
    ///   HTML-escaped.
    ///
    /// - `{{#object}}...{{/object}}` renders once, pushing `object` on the top
    ///   of the context stack.
    ///
    /// - `{{^object}}...{{/object}}` does not render.
    ///
    open var mustacheBox: MustacheBox {
        if let enumerable = self as? NSFastEnumeration {
            // Enumerable
            
            // Turn enumerable into a Swift array of MustacheBoxes that we know how to box
            let array = IteratorSequence(NSFastEnumerationIterator(enumerable)).map(BoxAny)
            return array.mustacheBoxWithArrayValue(self, box: { $0 })
            
        } else {
            // Generic NSObject
            
            #if OBJC
            return MustacheBox(
                value: self,
                keyedSubscript: { (key: String) in
                    if GRMustacheKeyAccess.isSafeMustacheKey(key, for: self) {
                        // Use valueForKey: for safe keys
                        return BoxAny(self.value(forKey: key))
                    } else {
                        // Missing key
                        return Box()
                    }
                })
            #else
                return MustacheBox(value: self)
            #endif
        }
    }
}


/// GRMustache provides built-in support for rendering `NSNull`.
extension NSNull {
    
    /// `NSNull` adopts the `MustacheBoxable` protocol so that it can feed
    /// Mustache templates.
    ///
    /// You should not directly call the `mustacheBox` property. Always use the
    /// `Box()` function instead:
    ///
    ///     NSNull().mustacheBox   // Valid, but discouraged
    ///     Box(NSNull())          // Preferred
    ///
    ///
    /// ### Rendering
    ///
    /// - `{{null}}` does not render.
    ///
    /// - `{{#null}}...{{/null}}` does not render (NSNull is falsey).
    ///
    /// - `{{^null}}...{{/null}}` does render (NSNull is falsey).
    open override var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            boolValue: false,
            render: { (info: RenderingInfo) in return Rendering("") })
    }
}


/// GRMustache provides built-in support for rendering `NSNumber`.
extension NSNumber {
    
    /// `NSNumber` adopts the `MustacheBoxable` protocol so that it can feed
    /// Mustache templates.
    ///
    /// You should not directly call the `mustacheBox` property. Always use the
    /// `Box()` function instead:
    ///
    ///     NSNumber(integer: 1).mustacheBox   // Valid, but discouraged
    ///     Box(NSNumber(integer: 1))          // Preferred
    ///
    ///
    /// ### Rendering
    ///
    /// NSNumber renders exactly like Swift numbers: depending on its internal
    /// objCType, an NSNumber is rendered as a Swift Bool, Int, UInt, Int64,
    /// UInt64, or Double.
    ///
    /// - `{{number}}` is rendered with built-in Swift String Interpolation.
    ///   Custom formatting can be explicitly required with NSNumberFormatter,
    ///   as in `{{format(a)}}` (see `NSFormatter`).
    ///
    /// - `{{#number}}...{{/number}}` renders if and only if `number` is
    ///   not 0 (zero).
    ///
    /// - `{{^number}}...{{/number}}` renders if and only if `number` is 0 (zero).
    ///
    open override var mustacheBox: MustacheBox {
        
        let objCType = String(cString: self.objCType)
        switch objCType {
        case "c":
            return Box(Int(int8Value))
        case "C":
            return Box(UInt(uint8Value))
        case "s":
            return Box(Int(int16Value))
        case "S":
            return Box(UInt(uint16Value))
        case "i":
            return Box(Int(int32Value))
        case "I":
            return Box(UInt(uint32Value))
        case "l":
            return Box(intValue)
        case "L":
            return Box(uintValue)
        case "q":
            return Box(int64Value)
        case "Q":
            return Box(uint64Value)
        case "f":
            return Box(Double(floatValue))
        case "d":
            return Box(doubleValue)
        case "B":
            return Box(boolValue)
        default:
            NSLog("GRMustache support for NSNumber of type \(objCType) is not implemented: value is discarded.")
            return Box()
        }
    }
}


/// GRMustache provides built-in support for rendering `NSString`.
extension NSString {
    
    /// `NSString` adopts the `MustacheBoxable` protocol so that it can feed
    /// Mustache templates.
    ///
    /// You should not directly call the `mustacheBox` property. Always use the
    /// `Box()` function instead:
    ///
    ///     "foo".mustacheBox   // Valid, but discouraged
    ///     Box("foo")          // Preferred
    ///
    ///
    /// ### Rendering
    ///
    /// - `{{string}}` renders the string, HTML-escaped.
    ///
    /// - `{{{string}}}` renders the string, *not* HTML-escaped.
    ///
    /// - `{{#string}}...{{/string}}` renders if and only if `string` is
    ///   not empty.
    ///
    /// - `{{^string}}...{{/string}}` renders if and only if `string` is empty.
    ///
    /// HTML-escaping of `{{string}}` tags is disabled for Text templates: see
    /// `Configuration.contentType` for a full discussion of the content type of
    /// templates.
    ///
    ///
    /// ### Keys exposed to templates
    ///
    /// A string can be queried for the following keys:
    ///
    /// - `length`: the number of characters in the string (using Swift method).
    open override var mustacheBox: MustacheBox {
        return Box(self as String)
    }
}


/// GRMustache provides built-in support for rendering `NSSet`.
extension NSSet {
    
    /// `NSSet` adopts the `MustacheBoxable` protocol so that it can feed
    /// Mustache templates.
    ///
    ///     let set: NSSet = [1,2,3]
    ///
    ///     // Renders "213"
    ///     let template = try! Template(string: "{{#set}}{{.}}{{/set}}")
    ///     try! template.render(Box(["set": Box(set)]))
    ///
    ///
    /// You should not directly call the `mustacheBox` property. Always use the
    /// `Box()` function instead:
    ///
    ///     set.mustacheBox   // Valid, but discouraged
    ///     Box(set)          // Preferred
    ///
    ///
    /// ### Rendering
    ///
    /// - `{{set}}` renders the concatenation of the renderings of the set
    ///   items, in any order.
    ///
    /// - `{{#set}}...{{/set}}` renders as many times as there are items in
    ///   `set`, pushing each item on its turn on the top of the context stack.
    ///
    /// - `{{^set}}...{{/set}}` renders if and only if `set` is empty.
    ///
    ///
    /// ### Keys exposed to templates
    ///
    /// A set can be queried for the following keys:
    ///
    /// - `count`: number of elements in the set
    /// - `first`: the first object in the set
    ///
    /// Because 0 (zero) is falsey, `{{#set.count}}...{{/set.count}}` renders
    /// once, if and only if `set` is not empty.
    open override var mustacheBox: MustacheBox {
        let array = IteratorSequence(NSFastEnumerationIterator(self)).map(BoxAny)
        return array.mustacheBoxWithSetValue(self, box: { $0 })
    }
}


/// GRMustache provides built-in support for rendering `NSDictionary`.
extension NSDictionary {
    
    /// `NSDictionary` adopts the `MustacheBoxable` protocol so that it can feed
    /// Mustache templates.
    ///
    ///     // Renders "Freddy Mercury"
    ///     let dictionary: NSDictionary = [
    ///         "firstName": "Freddy",
    ///         "lastName": "Mercury"]
    ///     let template = try! Template(string: "{{firstName}} {{lastName}}")
    ///     let rendering = try! template.render(Box(dictionary))
    ///
    ///
    /// You should not directly call the `mustacheBox` property. Always use the
    /// `Box()` function instead:
    ///
    ///     dictionary.mustacheBox   // Valid, but discouraged
    ///     Box(dictionary)          // Preferred
    ///
    ///
    /// ### Rendering
    ///
    /// - `{{dictionary}}` renders the result of the `description` method,
    ///   HTML-escaped.
    ///
    /// - `{{{dictionary}}}` renders the result of the `description` method,
    ///   *not* HTML-escaped.
    ///
    /// - `{{#dictionary}}...{{/dictionary}}` renders once, pushing `dictionary`
    ///   on the top of the context stack.
    ///
    /// - `{{^dictionary}}...{{/dictionary}}` does not render.
    ///
    ///
    /// In order to iterate over the key/value pairs of a dictionary, use the `each`
    /// filter from the Standard Library:
    ///
    ///     // Attach StandardLibrary.each to the key "each":
    ///     let template = try! Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")
    ///     template.registerInBaseContext("each", Box(StandardLibrary.each))
    ///
    ///     // Renders "<name:Arthur, age:36, >"
    ///     let dictionary = ["name": "Arthur", "age": 36] as NSDictionary
    ///     let rendering = try! template.render(Box(["dictionary": dictionary]))
    open override var mustacheBox: MustacheBox {
        return MustacheBox(
            converter: MustacheBox.Converter(dictionaryValue: { IteratorSequence(NSFastEnumerationIterator(self)).reduce([String: MustacheBox](), { (boxDictionary, key) in
                var boxDictionary = boxDictionary
                if let key = key as? String {
                    boxDictionary[key] = BoxAny(self[key])
                } else {
                    NSLog("GRMustache found a non-string key in NSDictionary (\(key)): value is discarded.")
                }
                return boxDictionary
            })}),
            value: self,
            keyedSubscript: { BoxAny(self[$0])
        })
    }
}

/// Support for Mustache rendering of ReferenceConvertible types.
extension ReferenceConvertible where Self: MustacheBoxable {
    /// Returns a MustacheBox that behaves like the equivalent NSObject.
    ///
    /// See NSObject.mustacheBox
    public var mustacheBox: MustacheBox {
        if let object = self as? ReferenceType {
            return object.mustacheBox
        } else {
            NSLog("Value `\(self)` can not feed Mustache templates: it is discarded.")
            return Box()
        }
    }
}

/// Data can feed Mustache templates.
extension Data : MustacheBoxable { }

/// Date can feed Mustache templates.
extension Date : MustacheBoxable { }

/// URL can feed Mustache templates.
extension URL : MustacheBoxable { }

/// UUID can feed Mustache templates.
extension UUID : MustacheBoxable { }
