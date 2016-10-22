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


/// The MustacheBoxable protocol gives any type the ability to feed Mustache
/// templates.
///
/// It is adopted by the standard types Bool, Int, UInt, Double, String, and
/// NSObject.
///
/// Your own types can conform to it as well, so that they can feed templates:
///
///     extension Profile: MustacheBoxable { ... }
///
///     let profile = ...
///     let template = try! Template(named: "Profile")
///     let rendering = try! template.render(Box(profile))
public protocol MustacheBoxable {
    
    /// You should not directly call the `mustacheBox` property. Always use the
    /// `Box()` function instead:
    ///
    ///     value.mustacheBox   // Valid, but discouraged
    ///     Box(value)          // Preferred
    ///
    /// Returns a `MustacheBox` that describes how your type interacts with the
    /// rendering engine.
    ///
    /// You can for example box another value that is already boxable, such as
    /// dictionaries:
    ///
    ///     struct Person {
    ///         let firstName: String
    ///         let lastName: String
    ///     }
    ///
    ///     extension Person : MustacheBoxable {
    ///         // Expose the `firstName`, `lastName` and `fullName` keys to
    ///         // Mustache templates:
    ///         var mustacheBox: MustacheBox {
    ///             return Box([
    ///                 "firstName": firstName,
    ///                 "lastName": lastName,
    ///                 "fullName": "\(self.firstName) \(self.lastName)",
    ///             ])
    ///         }
    ///     }
    ///
    ///     let person = Person(firstName: "Tom", lastName: "Selleck")
    ///
    ///     // Renders "Tom Selleck"
    ///     let template = try! Template(string: "{{person.fullName}}")
    ///     try! template.render(Box(["person": Box(person)]))
    ///
    /// However, there are multiple ways to build a box, several `Box()`
    /// functions. See their documentations.
    var mustacheBox: MustacheBox { get }
}

extension MustacheBox {
    
    /// `MustacheBox` adopts the `MustacheBoxable` protocol so that it can feed
    /// Mustache templates. Its mustacheBox property returns itself.
    public override var mustacheBox: MustacheBox {
        return self
    }
}


/// Values that conform to the `MustacheBoxable` protocol can feed Mustache
/// templates.
///
/// - parameter boxable: An optional value that conform to the `MustacheBoxable`
///   protocol.
///
/// - returns: A MustacheBox that wraps *boxable*.
public func Box(_ boxable: MustacheBoxable?) -> MustacheBox {
    return boxable?.mustacheBox ?? Box()
}


/// Attempt to turn value into a box.
///
/// - parameter object: An object.
/// - returns: A MustacheBox that wraps *object*.
func BoxAny(_ value: Any?) -> MustacheBox {
    guard let value = value else {
        return Box()
    }
    switch value {
    case let boxable as MustacheBoxable:
        return boxable.mustacheBox
    case let array as [Any?]:
        return Box(array)
    case let set as Set<AnyHashable>:
        return Box(set)
    case let dictionary as [AnyHashable: Any?]:
        return Box(dictionary)
    case let f as FilterFunction:
        return Box(f)
    case let f as RenderFunction:
        return Box(f)
    case let f as WillRenderFunction:
        return Box(f)
    case let f as DidRenderFunction:
        return Box(f)
    case let f as KeyedSubscriptFunction:
        return MustacheBox(keyedSubscript: f)
    default:
        NSLog("Mustache: value `\(value)` is discarded (not an array, not a set, not a dictionary, not a MustacheBoxable value.")
        return Box()
    }
}


extension Collection {
    
    /// Concatenates the rendering of the collection items.
    ///
    /// There are two tricks when rendering collections:
    ///
    /// 1. Items can render as Text or HTML, and our collection should render with
    ///    the same type. It is an error to mix content types.
    ///
    /// 2. We have to tell items that they are rendered as an enumeration item.
    ///    This allows collections to avoid enumerating their items when they are
    ///    part of another collections:
    ///
    ///         {{# arrays }}  // Each array renders as an enumeration item, and has itself enter the context stack.
    ///           {{#.}}       // Each array renders "normally", and enumerates its items
    ///             ...
    ///           {{/.}}
    ///         {{/ arrays }}
    ///
    /// - parameter info: A RenderingInfo
    /// - parameter box: A closure that turns collection items into a
    ///   MustacheBox.
    /// - returns: A Rendering
    fileprivate func renderItems(_ info: RenderingInfo, box: (Iterator.Element) -> MustacheBox) throws -> Rendering {
        // Prepare the rendering. We don't known the contentType yet: it depends on items
        var buffer = ""
        var contentType: ContentType? = nil
        
        // Tell items they are rendered as an enumeration item.
        //
        // Some values don't render the same whenever they render as an
        // enumeration item, or alone: {{# values }}...{{/ values }} vs.
        // {{# value }}...{{/ value }}.
        //
        // This is the case of Int, UInt, Double, Bool: they enter the context
        // stack when used in an iteration, and do not enter the context stack
        // when used as a boolean.
        //
        // This is also the case of collections: they enter the context stack
        // when used as an item of a collection, and enumerate their items when
        // used as a collection.
        var info = info
        info.enumerationItem = true
        
        for item in self {
            let boxRendering = try box(item).render(info)
            if contentType == nil
            {
                // First item: now we know our contentType
                contentType = boxRendering.contentType
                buffer += boxRendering.string
            }
            else if contentType == boxRendering.contentType
            {
                // Consistent content type: keep on buffering.
                buffer += boxRendering.string
            }
            else
            {
                // Inconsistent content type: this is an error. How are we
                // supposed to mix Text and HTML?
                throw MustacheError(kind: .renderError, message: "Content type mismatch")
            }
        }
        
        if let contentType = contentType {
            // {{ collection }}
            // {{# collection }}...{{/ collection }}
            //
            // We know our contentType, hence the collection is not empty and
            // we render our buffer.
            return Rendering(buffer, contentType)
        } else {
            // {{ collection }}
            //
            // We don't know our contentType, hence the collection is empty.
            //
            // Now this code is executed. This means that the collection is
            // rendered, despite its emptiness.
            //
            // We are not rendering a regular {{# section }} tag, because empty
            // collections have a false boolValue, and RenderingEngine would prevent
            // us to render.
            //
            // We are not rendering an inverted {{^ section }} tag, because
            // RenderingEngine takes care of the rendering of inverted sections.
            //
            // So we are rendering a {{ variable }} tag. As en empty collection, we
            // must return an empty rendering.
            //
            // Renderings have a content type. In order to render an empty
            // rendering that has the contentType of the tag, let's use the
            // `render` method of the tag.
            return try info.tag.render(info.context)
        }
    }
}

extension Collection where IndexDistance == Int {
    /// This function returns a MustacheBox that wraps a set-like collection.
    ///
    /// The returned box can be queried for the following keys:
    ///
    /// - `first`: the first object in the collection
    /// - `count`: number of elements in the collection
    ///
    /// - parameter value: the value of the returned box.
    /// - parameter box: A closure that turns collection items into a
    ///   MustacheBox.
    /// - returns: A MustacheBox that wraps the collection.
    func mustacheBoxWithSetValue(_ value: Any?, box: @escaping (Iterator.Element) -> MustacheBox) -> MustacheBox {
        return MustacheBox(
            converter: MustacheBox.Converter(arrayValue: { self.map({ box($0) }) }),
            value: value,
            boolValue: !isEmpty,
            keyedSubscript: { (key) in
                switch key {
                case "first":   // C: CollectionType
                    if let first = self.first {
                        return box(first)
                    } else {
                        return Box()
                    }
                case "count":   // C.IndexDistance == Int
                    return Box(self.count)
                default:
                    return Box()
                }
            },
            render: { (info: RenderingInfo) in
                if info.enumerationItem {
                    // {{# collections }}...{{/ collections }}
                    return try info.tag.render(info.context.extendedContext(self.mustacheBoxWithSetValue(value, box: box)))
                } else {
                    // {{ collection }}
                    // {{# collection }}...{{/ collection }}
                    return try self.renderItems(info, box: box)
                }
            }
        )
    }
}

extension BidirectionalCollection where IndexDistance == Int {
    /// This function returns a MustacheBox that wraps an array-like collection.
    ///
    /// The returned box can be queried for the following keys:
    ///
    /// - `first`: the first object in the collection
    /// - `count`: number of elements in the collection
    /// - `last`: the last object in the collection
    ///
    /// - parameter value: the value of the returned box.
    /// - parameter box: A closure that turns collection items into a
    ///   MustacheBox.
    /// - returns: A MustacheBox that wraps the collection.
    func mustacheBoxWithArrayValue(_ value: Any?, box: @escaping (Iterator.Element) -> MustacheBox) -> MustacheBox {
        return MustacheBox(
            converter: MustacheBox.Converter(arrayValue: { self.map({ box($0) }) }),
            value: value,
            boolValue: !isEmpty,
            keyedSubscript: { (key) in
                switch key {
                case "first":   // C: CollectionType
                    if let first = self.first {
                        return box(first)
                    } else {
                        return Box()
                    }
                case "last":    // C.Index: BidirectionalIndexType
                    if let last = self.last {
                        return box(last)
                    } else {
                        return Box()
                    }
                case "count":   // C.IndexDistance == Int
                    return Box(self.count)
                default:
                    return Box()
                }
            },
            render: { (info: RenderingInfo) in
                if info.enumerationItem {
                    // {{# collections }}...{{/ collections }}
                    return try info.tag.render(info.context.extendedContext(self.mustacheBoxWithArrayValue(value, box: box)))
                } else {
                    // {{ collection }}
                    // {{# collection }}...{{/ collection }}
                    return try self.renderItems(info, box: box)
                }
            }
        )
    }
}


/// Sets can feed Mustache templates.
///
///     let set:Set<Int> = [1,2,3]
///
///     // Renders "132", or "231", etc.
///     let template = try! Template(string: "{{#set}}{{.}}{{/set}}")
///     try! template.render(Box(["set": Box(set)]))
///
///
/// ### Rendering
///
/// - `{{set}}` renders the concatenation of the set items.
///
/// - `{{#set}}...{{/set}}` renders as many times as there are items in `set`,
///   pushing each item on its turn on the top of the context stack.
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
/// Because 0 (zero) is falsey, `{{#set.count}}...{{/set.count}}` renders once,
/// if and only if `set` is not empty.
///
///
/// - parameter set: A set.
/// - returns: A MustacheBox that wraps *set*.
public func Box<Element>(_ set: Set<Element>?) -> MustacheBox {
    guard let set = set else {
        return Box()
    }
    return set.mustacheBoxWithSetValue(set, box: { BoxAny($0) })
}

/// Arrays can feed Mustache templates.
///
///     let array = [1,2,3]
///
///     // Renders "123"
///     let template = try! Template(string: "{{#array}}{{.}}{{/array}}")
///     try! template.render(Box(["array": Box(array)]))
///
///
/// ### Rendering
///
/// - `{{array}}` renders the concatenation of the array items.
///
/// - `{{#array}}...{{/array}}` renders as many times as there are items in
///   `array`, pushing each item on its turn on the top of the context stack.
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
/// Because 0 (zero) is falsey, `{{#array.count}}...{{/array.count}}` renders
/// once, if and only if `array` is not empty.
///
///
/// - parameter array: An array of boxable values.
/// - returns: A MustacheBox that wraps *array*.
public func Box(_ array: [Any?]?) -> MustacheBox {
    guard let array = array else {
        return Box()
    }
    return array.mustacheBoxWithArrayValue(array, box: { BoxAny($0) })
}

/// A dictionary can feed Mustache templates.
///
///     let dictionary: [String: String] = [
///         "firstName": "Freddy",
///         "lastName": "Mercury"]
///
///     // Renders "Freddy Mercury"
///     let template = try! Template(string: "{{firstName}} {{lastName}}")
///     let rendering = try! template.render(Box(dictionary))
///
///
/// ### Rendering
///
/// - `{{dictionary}}` renders the built-in Swift String Interpolation of the
///   dictionary.
///
/// - `{{#dictionary}}...{{/dictionary}}` pushes the dictionary on the top of the
///   context stack, and renders the section once.
///
/// - `{{^dictionary}}...{{/dictionary}}` does not render.
///
///
/// In order to iterate over the key/value pairs of a dictionary, use the `each`
/// filter from the Standard Library:
///
///     // Register StandardLibrary.each for the key "each":
///     let template = try! Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")
///     template.registerInBaseContext("each", Box(StandardLibrary.each))
///
///     // Renders "<firstName:Freddy, lastName:Mercury,>"
///     let dictionary: [String: String] = ["firstName": "Freddy", "lastName": "Mercury"]
///     let rendering = try! template.render(Box(["dictionary": dictionary]))
///
/// - parameter dictionary: A dictionary
/// - returns: A MustacheBox that wraps *dictionary*.
public func Box(_ dictionary: [AnyHashable: Any?]?) -> MustacheBox {
    guard let dictionary = dictionary else {
        return Box()
    }
    return MustacheBox(
        converter: MustacheBox.Converter(dictionaryValue: {
            var boxDictionary: [String: MustacheBox] = [:]
            for (key, value) in dictionary {
                if let key = key as? String {
                    boxDictionary[key] = BoxAny(value)
                } else {
                    NSLog("Mustache: non-string key in dictionary (\(key)) is discarded.")
                }
            }
            return boxDictionary
        }),
        value: dictionary,
        keyedSubscript: { (key: String) in
            if let value = dictionary[key] {
                return BoxAny(value)
            } else {
                return Box()
            }
    })
}

/// A function that wraps a `FilterFunction` into a `MustacheBox` so that it can
/// feed template.
///
///     let square: FilterFunction = Filter { (x: Int?) in
///         return Box(x! * x!)
///     }
///
///     let template = try! Template(string: "{{ square(x) }}")
///     template.registerInBaseContext("square", Box(square))
///
///     // Renders "100"
///     try! template.render(Box(["x": 10]))
///
/// - parameter filter: A FilterFunction.
/// - returns: A MustacheBox that wraps *filter*.
///
/// See also:
///
/// - FilterFunction
public func Box(_ filter: @escaping FilterFunction) -> MustacheBox {
    return MustacheBox(filter: filter)
}

/// A function that wraps a `RenderFunction` into a `MustacheBox` so that it can
/// feed template.
///
///     let foo: RenderFunction = { (_) in Rendering("foo") }
///
///     // Renders "foo"
///     let template = try! Template(string: "{{ foo }}")
///     try! template.render(Box(["foo": Box(foo)]))
///
/// - parameter render: A RenderFunction.
/// - returns: A MustacheBox that wraps *render*.
///
/// See also:
///
/// - RenderFunction
public func Box(_ render: @escaping RenderFunction) -> MustacheBox {
    return MustacheBox(render: render)
}

/// A function that wraps a `WillRenderFunction` into a `MustacheBox` so that it
/// can feed template.
///
///     let logTags: WillRenderFunction = { (tag: Tag, box: MustacheBox) in
///         print("\(tag) will render \(box.value!)")
///         return box
///     }
///
///     // By entering the base context of the template, the logTags function
///     // will be notified of all tags.
///     let template = try! Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")
///     template.extendBaseContext(Box(logTags))
///
///     // Prints:
///     // {{# user }} at line 1 will render { firstName = Errol; lastName = Flynn; }
///     // {{ firstName }} at line 1 will render Errol
///     // {{ lastName }} at line 1 will render Flynn
///     let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
///     try! template.render(Box(data))
///
/// - parameter willRender: A WillRenderFunction
/// - returns: A MustacheBox that wraps *willRender*.
///
/// See also:
///
/// - WillRenderFunction
public func Box(_ willRender: @escaping WillRenderFunction) -> MustacheBox {
    return MustacheBox(willRender: willRender)
}

/// A function that wraps a `DidRenderFunction` into a `MustacheBox` so that it
/// can feed template.
///
///     let logRenderings: DidRenderFunction = { (tag: Tag, box: MustacheBox, string: String?) in
///         print("\(tag) did render \(box.value!) as `\(string!)`")
///     }
///
///     // By entering the base context of the template, the logRenderings function
///     // will be notified of all tags.
///     let template = try! Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")
///     template.extendBaseContext(Box(logRenderings))
///
///     // Renders "Errol Flynn"
///     //
///     // Prints:
///     // {{ firstName }} at line 1 did render Errol as `Errol`
///     // {{ lastName }} at line 1 did render Flynn as `Flynn`
///     // {{# user }} at line 1 did render { firstName = Errol; lastName = Flynn; } as `Errol Flynn`
///     let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
///     try! template.render(Box(data))
///
/// - parameter didRender: A DidRenderFunction/
/// - returns: A MustacheBox that wraps *didRender*.
///
/// See also:
///
/// - DidRenderFunction
public func Box(_ didRender: @escaping DidRenderFunction) -> MustacheBox {
    return MustacheBox(didRender: didRender)
}

/// The empty box, the box that represents missing values.
public func Box() -> MustacheBox {
    return EmptyBox
}

private let EmptyBox = MustacheBox()
