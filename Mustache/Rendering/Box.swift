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


// "It's all boxes all the way down."
//
// Mustache templates don't eat raw values: they eat boxed values.
//
// To box something, you use the Box() function. It comes in several variants so
// that nearly anything can be boxed and feed templates.
//
// This file is organized in five sections with many examples. You can use the
// Playground included in `Mustache.xcworkspace` to run those examples.
//
//
// - MustacheBoxable and the Boxing of Swift types
//
//   The MustacheBoxable protocol makes any Swift type able to be boxed with the
//   Box(MustacheBoxable?) function.
//
//   Learn how the Swift types Bool, Int, UInt, Double, and String are rendered.
//
//
// - Boxing of Swift collections and dictionaries
//
//   There is one Box() function for collections, and another one for 
//   dictionaries.
//
//
// - Boxing of NSObject
//
//   There is a Box() function for NSObject.
//
//   Learn how NSObject, NSNull, NSString, NSNumber, NSArray, NSDictionary and
//   NSSet are rendered.
//
//
// - Boxing of Core Mustache functions
//
//   The "core Mustache functions" are raw filters, Mustache lambdas, etc. Those
//   can be boxed as well so that you can feed templates with filters, Mustache
//   lambdas, and more.
//
//
// - Boxing of multi-facetted values
//
//   Describes the most advanced Box() function.


// =============================================================================
// MARK: - MustacheBoxable and the Boxing of Swift types

/**
The MustacheBoxable protocol gives any type the ability to feed Mustache
templates.

GRMustache ships with built-in `MustacheBoxable` conformance for the following
types: `Bool`, `Int`, `UInt`, `Double`, `String`, `NSObject`.

Your own types can conform to it as well, so that they can feed templates:

    extension Profile: MustacheBoxable { ... }

    let profile = ...
    let template = Template(named: "Profile")!
    let rendering = template.render(Box(profile))!
*/
public protocol MustacheBoxable {
    
    /**
    Returns a MustacheBox.
    
    This method is invoked when a value of your conforming class is boxed with
    the `Box()` function.
    
    Don't return `Box(self)`: this would trigger an infinite loop! Instead, you
    build a Box that explicitly describes how your type interacts with the
    Mustache engine.
    
    You can for example return a box that wraps another value that is already
    boxable, such as Dictionaries. This is all good:

        struct Person {
            let firstName: String
            let lastName: String
        }

        extension Person : MustacheBoxable {
            var mustacheBox: MustacheBox {
                return Box([
                    "firstName": firstName,
                    "lastName": lastName,
                    "fullName": "\(self.firstName) \(self.lastName)",
                ])
            }
        }

        // Renders "Tom Selleck"
        let template = Template(string: "{{person.fullName}}")!
        let person = Person(firstName: "Tom", lastName: "Selleck")
        template.render(Box(["person": Box(person)]))!

    However, there are multiple ways to build a box, several `Box()` functions.
    See their documentations.
    */
    var mustacheBox: MustacheBox { get }
}

/**
Values that conform to the `MustacheBoxable` protocol can feed Mustache
templates.

:param: boxable An optional value that conform to the `MustacheBoxable`
                protocol.

:returns: A MustacheBox that wraps `boxable`
*/
public func Box(boxable: MustacheBoxable?) -> MustacheBox {
    if let boxable = boxable {
        return boxable.mustacheBox
    } else {
        return Box()
    }
}


// IMPLEMENTATION NOTE
//
// This protocol conformance is not only a matter of consistency. It is also
// a convenience for the library implementation: it makes arrays
// [MustacheBox] boxable via Box<C: CollectionType where C.Generator.Element: MustacheBoxable>(collection: C?)
// and dictionaries [String:MustacheBox] boxable via Box<T: MustacheBoxable>(dictionary: [String: T]?)

extension MustacheBox : MustacheBoxable {
    
    /**
    `MustacheBox` conforms to the `MustacheBoxable` protocol so that it can feed
    Mustache templates. Its mustacheBox property returns itself.
    */
    public override var mustacheBox: MustacheBox {
        return self
    }
}


/**
GRMustache provides built-in support for rendering `Bool`.
*/

extension Bool : MustacheBoxable {
    
    /**
    `Bool` conforms to the `MustacheBoxable` protocol so that it can feed
    Mustache templates. It behaves exactly like Objective-C booleans.
    
    
    ### Rendering
    
    - `{{bool}}` renders as `0` or `1`.
    
    - `{{#bool}}...{{/bool}}` renders if and only if `bool` is true.
    
    - `{{^bool}}...{{/bool}}` renders if and only if `bool` is false.
    
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            boolValue: self,
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ bool }}
                    return Rendering("\(self ? 1 : 0)") // Behave like [NSNumber numberWithBool:]
                case .Section:
                    if info.enumerationItem {
                        // {{# bools }}...{{/ bools }}
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# bool }}...{{/ bool }}
                        //
                        // Bools do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}


/**
GRMustache provides built-in support for rendering `Int`.
*/

extension Int : MustacheBoxable {
    
    /**
    `Int` conforms to the `MustacheBoxable` protocol so that it can feed
    Mustache templates. It behaves exactly like Objective-C integers.
    
    
    ### Rendering
    
    - `{{int}}` is rendered with built-in Swift String Interpolation.
      Custom formatting can be explicitly required with NSNumberFormatter, as in
      `{{format(a)}}` (see `NSFormatter`).
    
    - `{{#int}}...{{/int}}` renders if and only if `int` is not 0 (zero).
    
    - `{{^int}}...{{/int}}` renders if and only if `int` is 0 (zero).
    
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            boolValue: (self != 0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ int }}
                    return Rendering("\(self)")
                case .Section:
                    if info.enumerationItem {
                        // {{# ints }}...{{/ ints }}
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# int }}...{{/ int }}
                        //
                        // Ints do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}


/**
GRMustache provides built-in support for rendering `UInt`.
*/

extension UInt : MustacheBoxable {
    
    /**
    `UInt` conforms to the `MustacheBoxable` protocol so that it can feed
    Mustache templates. It behaves exactly like Objective-C unsigned integers.
    
    
    ### Rendering
    
    - `{{uint}}` is rendered with built-in Swift String Interpolation.
      Custom formatting can be explicitly required with NSNumberFormatter, as in
      `{{format(a)}}` (see `NSFormatter`).
    
    - `{{#uint}}...{{/uint}}` renders if and only if `uint` is not 0 (zero).
    
    - `{{^uint}}...{{/uint}}` renders if and only if `uint` is 0 (zero).
    
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            boolValue: (self != 0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ uint }}
                    return Rendering("\(self)")
                case .Section:
                    if info.enumerationItem {
                        // {{# uints }}...{{/ uints }}
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# uint }}...{{/ uint }}
                        //
                        // Uints do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}


/**
GRMustache provides built-in support for rendering `Double`.
*/

extension Double : MustacheBoxable {
    
    /**
    `Double` conforms to the `MustacheBoxable` protocol so that it can feed
    Mustache templates. It behaves exactly like Objective-C doubles.
    
    
    ### Rendering
    
    - `{{double}}` is rendered with built-in Swift String Interpolation.
      Custom formatting can be explicitly required with NSNumberFormatter, as in
      `{{format(a)}}` (see `NSFormatter`).
    
    - `{{#double}}...{{/double}}` renders if and only if `double` is not 0 (zero).
    
    - `{{^double}}...{{/double}}` renders if and only if `double` is 0 (zero).
    
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            boolValue: (self != 0.0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ double }}
                    return Rendering("\(self)")
                case .Section:
                    if info.enumerationItem {
                        // {{# doubles }}...{{/ doubles }}
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# double }}...{{/ double }}
                        //
                        // Doubles do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}


/**
GRMustache provides built-in support for rendering `String`.
*/

extension String : MustacheBoxable {
    
    /**
    `String` conforms to the `MustacheBoxable` protocol so that it can feed
    Mustache templates. It behaves exactly like Objective-C NSString.
    
    
    ### Rendering
    
    - `{{string}}` renders the string, HTML-escaped.
    
    - `{{{string}}}` renders the string, *not* HTML-escaped.
    
    - `{{#string}}...{{/string}}` renders if and only if `string` is not empty.
    
    - `{{^string}}...{{/string}}` renders if and only if `string` is empty.
    
    HTML-escaping of `{{string}}` tags is disabled for Text templates: see
    `Configuration.contentType` for a full discussion of the content type of
    templates.
    
    
    ### Keys exposed to templates

    A string can be queried for the following keys:
    
    - `length`: the number of characters in the string.
    
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            boolValue: (count(self) > 0),
            keyedSubscript: { (key: String) in
                switch key {
                case "length":
                    return Box(count(self))
                default:
                    return Box()
                }
            })
    }
}


// =============================================================================
// MARK: - Boxing of Swift collections and dictionaries


// IMPLEMENTATION NOTE 1
//
// This function is a private helper for collection types CollectionType and
// NSSet. Collections render as the concatenation of the rendering of their
// items.
//
// There are two tricks when rendering collections:
//
// One, items can render as Text or HTML, and our collection should render with
// the same type. It is an error to mix content types.
//
// Two, we have to tell items that they are rendered as an enumeration item.
// This allows collections to avoid enumerating their items when they are part
// of another collections:
//
// ::
//
//   {{# arrays }}  // Each array renders as an enumeration item, and has itself enter the context stack.
//     {{#.}}       // Each array renders "normally", and enumerates its items
//       ...
//     {{/.}}
//   {{/ arrays }}
//
//
// IMPLEMENTATION NOTE 2
//
// This function used to consume a generic collection instead of an explicit
// array. (See commit 9d6c37a9c3f95a4202dcafc4cc7df59e5b86cbc7).
//
// Unfortunately https://github.com/groue/GRMustache.swift/issues/1 has revelead
// that the generic function would not compile in Release configuration.
private func renderBoxArray(boxes: [MustacheBox], var info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
    
    // Prepare the rendering. We don't known the contentType yet: it depends on items
    var buffer = ""
    var contentType: ContentType? = nil
    
    // Tell items they are rendered as an enumeration item.
    //
    // Some values don't render the same whenever they render as an enumeration
    // item, or alone: {{# values }}...{{/ values }} vs.
    // {{# value }}...{{/ value }}.
    //
    // This is the case of Int, UInt, Double, Bool: they enter the context
    // stack when used in an iteration, and do not enter the context stack when
    // used as a boolean.
    //
    // This is also the case of collections: they enter the context stack when
    // used as an item of a collection, and enumerate their items when used as
    // a collection.

    info.enumerationItem = true
    
    for box in boxes {
        if let boxRendering = box.render(info: info, error: error) {
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
                if error != nil {
                    error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Content type mismatch"])
                }
                return nil
            }
        } else {
            return nil
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
        return info.tag.render(info.context, error: error)
    }
}


// IMPLEMENTATION NOTE
//
// We don't provide any boxing function for `SequenceType`, because this type
// makes no requirement on conforming types regarding whether they will be
// destructively "consumed" by iteration (as stated by documentation).
//
// Now we need to consume a sequence several times:
//
// - for converting it to an array for the arrayValue property.
// - for consuming the first element to know if the sequence is empty or not.
// - for rendering it.
//
// So we only provide a boxing function for `CollectionType` which ensures
// non-destructive iteration.

/**
A collection of values that conform to the `MustacheBoxable` protocol can feed
Mustache templates. It behaves exactly like Objective-C `NSArray`.

    let collection: [Int] = [1,2,3]

    // Renders "123"
    let template = Template(string: "{{#collection}}{{.}}{{/collection}}")!
    template.render(Box(["collection": Box(collection)]))!


### Rendering

- `{{collection}}` renders the concatenation of the collection items.

- `{{#collection}}...{{/collection}}` renders as many times as there are items
  in `collection`, pushing each item on its turn on the top of the context
  stack.

- `{{^collection}}...{{/collection}}` renders if and only if `collection` is
  empty.


### Keys exposed to templates

A collection can be queried for the following keys:

- `count`: number of elements in the collection
- `first`: the first object in the collection
- `firstObject`: the first object in the collection
- `last`: the last object in the collection
- `lastObject`: the last object in the collection

Because 0 (zero) is falsey, `{{#collection.count}}...{{/collection.count}}`
renders once, if and only if `collection` is not empty.


### Unwrapping from MustacheBox

Whenever you want to extract a collection of a MustacheBox, use the `arrayValue`
property: it reliably returns an Array of MustacheBox, whatever the actual
type of the raw boxed value (Set, Array, NSArray, NSSet, ...).


:param: collection A collection of values that conform to the `MustacheBoxable`
                   protocol.

:returns: A MustacheBox that wraps `collection`
*/
public func Box<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C?) -> MustacheBox {
    if let collection = collection {
        let count = Swift.count(collection) // C.Index.Distance == Int
        return MustacheBox(
            boolValue: (count > 0),
            value: collection,
            converter: MustacheBox.Converter(arrayValue: map(collection, { Box($0) })),
            keyedSubscript: { (key: String) in
                switch key {
                case "count":
                    // Support for both Objective-C and Swift arrays.
                    return Box(count)
                    
                case "firstObject", "first":
                    // Support for both Objective-C and Swift arrays.
                    if count > 0 {
                        return Box(collection[collection.startIndex])
                    } else {
                        return Box()
                    }
                    
                case "lastObject", "last":
                    // Support for both Objective-C and Swift arrays.
                    if count > 0 {
                        return Box(collection[collection.endIndex.predecessor()])   // C.Index: BidirectionalIndexType
                    } else {
                        return Box()
                    }
                    
                default:
                    return Box()
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                if info.enumerationItem {
                    // {{# collections }}...{{/ collections }}
                    return info.tag.render(info.context.extendedContext(Box(collection)), error: error)
                } else {
                    // {{ collection }}
                    // {{# collection }}...{{/ collection }}
                    return renderBoxArray(map(collection, { Box($0) }), info, error)
                }
        })
    } else {
        return Box()
    }
}

/**
A collection of optional values that conform to the `MustacheBoxable` protocol
can feed Mustache templates. It behaves exactly like Objective-C `NSArray`.

    let collection: [Int] = [1,2,3]

    // Renders "123"
    let template = Template(string: "{{#collection}}{{.}}{{/collection}}")!
    template.render(Box(["collection": Box(collection)]))!


### Rendering

- `{{collection}}` renders the concatenation of the collection items.

- `{{#collection}}...{{/collection}}` renders as many times as there are items
  in `collection`, pushing each item on its turn on the top of the context
  stack.

- `{{^collection}}...{{/collection}}` renders if and only if `collection` is
  empty.


### Keys exposed to templates

A collection can be queried for the following keys:

- `count`: number of elements in the collection
- `first`: the first object in the collection
- `firstObject`: the first object in the collection
- `last`: the last object in the collection
- `lastObject`: the last object in the collection

Because 0 (zero) is falsey, `{{#collection.count}}...{{/collection.count}}`
renders once, if and only if `collection` is not empty.


### Unwrapping from MustacheBox

Whenever you want to extract a collection of a MustacheBox, use the `arrayValue`
property: it reliably returns an Array of MustacheBox, whatever the actual
type of the raw boxed value (Set, Array, NSArray, NSSet, ...).


:param: collection A collection of optional values that conform to the
                   `MustacheBoxable` protocol.

:returns: A MustacheBox that wraps `collection`
*/
public func Box<C: CollectionType, T where C.Generator.Element == Optional<T>, T: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C?) -> MustacheBox {
    if let collection = collection {
        let count = Swift.count(collection) // C.Index.Distance == Int
        return MustacheBox(
            boolValue: (count > 0),
            value: collection,
            converter: MustacheBox.Converter(arrayValue: map(collection, { Box($0) })),
            keyedSubscript: { (key: String) in
                switch key {
                case "count":
                    // Support for both Objective-C and Swift arrays.
                    return Box(count)
                    
                case "firstObject", "first":
                    // Support for both Objective-C and Swift arrays.
                    if count > 0 {
                        return Box(collection[collection.startIndex])
                    } else {
                        return Box()
                    }
                    
                case "lastObject", "last":
                    // Support for both Objective-C and Swift arrays.
                    if count > 0 {
                        return Box(collection[collection.endIndex.predecessor()])   // C.Index: BidirectionalIndexType
                    } else {
                        return Box()
                    }
                    
                default:
                    return Box()
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                if info.enumerationItem {
                    // {{# collections }}...{{/ collections }}
                    return info.tag.render(info.context.extendedContext(Box(collection)), error: error)
                } else {
                    // {{ collection }}
                    // {{# collection }}...{{/ collection }}
                    // {{^ collection }}...{{/ collection }}
                    return renderBoxArray(map(collection, { Box($0) }), info, error)
                }
        })
    } else {
        return Box()
    }
}


/**
A set of values that conform to the `MustacheBoxable` protocol can feed Mustache
templates. It behaves exactly like Objective-C `NSSet`.

    let set: Set<Int> = [1,2,3]

    // Renders "213"
    let template = Template(string: "{{#set}}{{.}}{{/set}}")!
    template.render(Box(["set": Box(set)]))!


### Rendering

- `{{set}}` renders the concatenation of the renderings of the set items, in
any order.

- `{{#set}}...{{/set}}` renders as many times as there are items in `set`,
pushing each item on its turn on the top of the context stack.

- `{{^set}}...{{/set}}` renders if and only if `set` is empty.


### Keys exposed to templates

A set can be queried for the following keys:

- `anyObject`: the first object in the set
- `count`: number of elements in the set
- `first`: the first object in the set

Because 0 (zero) is falsey, `{{#set.count}}...{{/set.count}}` renders once,
if and only if `set` is not empty.


### Unwrapping from MustacheBox

Whenever you want to extract a collection of a MustacheBox, use the `arrayValue`
property: it reliably returns an Array of MustacheBox, whatever the actual
type of the raw boxed value (Set, Array, NSArray, NSSet, ...).


:param: set A set of values that conform to the `MustacheBoxable` protocol.

:returns: A MustacheBox that wraps `set`
*/
public func Box<T: MustacheBoxable>(set: Set<T>?) -> MustacheBox {
    if let set = set {
        let count = Swift.count(set)
        return MustacheBox(
            boolValue: (count > 0),
            value: set,
            converter: MustacheBox.Converter(arrayValue: map(set, { Box($0) })),
            keyedSubscript: { (key: String) in
                switch key {
                case "count":
                    return Box(count)
                case "first", "anyObject":
                    return Box(set.first)
                default:
                    return Box()
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                if info.enumerationItem {
                    // {{# sets }}...{{/ sets }}
                    return info.tag.render(info.context.extendedContext(Box(set)), error: error)
                } else {
                    // {{ set }}
                    // {{# set }}...{{/ set }}
                    // {{^ set }}...{{/ set }}
                    return renderBoxArray(map(set, { Box($0) }), info, error)
                }
        })
    } else {
        return Box()
    }
}


/**
A dictionary of values that conform to the `MustacheBoxable` protocol can feed
Mustache templates. It behaves exactly like Objective-C `NSDictionary`.

    // Renders "Freddy Mercury"
    let dictionary: [String: String] = [
        "firstName": "Freddy",
        "lastName": "Mercury"]
    let template = Template(string: "{{firstName}} {{lastName}}")!
    let rendering = template.render(Box(dictionary))!


### Rendering

- `{{dictionary}}` renders the built-in Swift String Interpolation of the
  dictionary.

- `{{#dictionary}}...{{/dictionary}}` pushes the dictionary on the top of the
  context stack, and renders the section once.

- `{{^dictionary}}...{{/dictionary}}` does not render.


In order to iterate over the key/value pairs of a dictionary, use the `each`
filter from the Standard Library:

    // Register StandardLibrary.each for the key "each":
    let template = Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")!
    template.registerInBaseContext("each", Box(StandardLibrary.each))

    // Renders "<firstName:Freddy, lastName:Mercury,>"
    let dictionary: [String: String] = ["firstName": "Freddy", "lastName": "Mercury"]
    let rendering = template.render(Box(["dictionary": dictionary]))!


### Unwrapping from MustacheBox

Whenever you want to extract a dictionary of a MustacheBox, use the
`dictionaryValue` property: it reliably returns an `[String: MustacheBox]`
dictionary, whatever the actual type of the raw boxed value.


:param: dictionary A dictionary of values that conform to the `MustacheBoxable`
                   protocol.

:returns: A MustacheBox that wraps `dictionary`
*/
public func Box<T: MustacheBoxable>(dictionary: [String: T]?) -> MustacheBox {
    if let dictionary = dictionary {
        return MustacheBox(
            value: dictionary,
            converter: MustacheBox.Converter(
                dictionaryValue: reduce(dictionary, [String: MustacheBox](), { (var boxDictionary, pair) -> [String: MustacheBox] in
                        let (key, value) = pair
                        boxDictionary[key] = Box(value)
                        return boxDictionary
                    })),
            keyedSubscript: { (key: String) in
                return Box(dictionary[key])
            })
    } else {
        return Box()
    }
}

/**
A dictionary of optional values that conform to the `MustacheBoxable` protocol
can feed Mustache templates. It behaves exactly like Objective-C `NSDictionary`.

    // Renders "Freddy Mercury"
    let dictionary: [String: String?] = [
        "firstName": "Freddy",
        "lastName": "Mercury"]
    let template = Template(string: "{{firstName}} {{lastName}}")!
    let rendering = template.render(Box(dictionary))!


### Rendering

- `{{dictionary}}` renders the built-in Swift String Interpolation of the
  dictionary.

- `{{#dictionary}}...{{/dictionary}}` pushes the dictionary on the top of the
  context stack, and renders the section once.

- `{{^dictionary}}...{{/dictionary}}` does not render.


In order to iterate over the key/value pairs of a dictionary, use the `each`
filter from the Standard Library:

    // Register StandardLibrary.each for the key "each":
    let template = Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")!
    template.registerInBaseContext("each", Box(StandardLibrary.each))

    // Renders "<firstName:Freddy, lastName:Mercury,>"
    let dictionary: [String: String?] = ["firstName": "Freddy", "lastName": "Mercury"]
    let rendering = template.render(Box(["dictionary": dictionary]))!


### Unwrapping from MustacheBox

Whenever you want to extract a dictionary of a MustacheBox, use the
`dictionaryValue` property: it reliably returns an `[String: MustacheBox]`
dictionary, whatever the actual type of the raw boxed value.


:param: dictionary A dictionary of optional values that conform to the
                   `MustacheBoxable` protocol.

:returns: A MustacheBox that wraps `dictionary`
*/
public func Box<T: MustacheBoxable>(dictionary: [String: T?]?) -> MustacheBox {
    if let dictionary = dictionary {
        return MustacheBox(
            value: dictionary,
            converter: MustacheBox.Converter(
                dictionaryValue: reduce(dictionary, [String: MustacheBox](), { (var boxDictionary, pair) -> [String: MustacheBox] in
                    let (key, value) = pair
                    boxDictionary[key] = Box(value)
                    return boxDictionary
                })),
            keyedSubscript: { (key: String) in
                if let value = dictionary[key] {
                    return Box(value)
                } else {
                    return Box()
                }
        })
    } else {
        return Box()
    }
}


// =============================================================================
// MARK: - Boxing of NSObject

// IMPLEMENTATION NOTE
//
// Why is there a Box(NSObject?) function, when Box(MustacheBoxable?) should be
// enough, given NSObject conforms to MustacheBoxable?
//
// Well, this is another Swift oddity.
//
// Without this explicit NSObject support, many compound values like the ones
// below could not be boxed:
//
// - ["cats": ["Kitty", "Pussy", "Melba"]]
// - [[0,1],[2,3]]
//
// It looks like Box(object: NSObject?) triggers the silent conversion of those
// values to NSArray and NSDictionary.
//
// It's an extra commodity we want to keep, in order to prevent the user to
// rewrite them as:
//
// - ["cats": Box([Box("Kitty"), Box("Pussy"), Box("Melba")])]
// - [Box([0,1]), Box([2,3])]

/**
See the documentation of `NSObject.mustacheBox`.

:param: object An NSObject
:returns: A MustacheBox that wraps `object`
*/
public func Box(object: NSObject?) -> MustacheBox {
    if let object = object {
        return object.mustacheBox
    } else {
        return Box()
    }
}

// IMPLEMENTATION NOTE
//
// Why is there a BoxAnyObject(AnyObject?) function, but no Box(AnyObject?)
//
// GRMustache aims at having a single boxing function: Box(), with many
// overloaded variants. This lets the user box anything, standard Swift types
// (Bool, String, etc.), custom types, as well as opaque types (such as
// StandardLibrary.javascriptEscape).
//
// For example:
//
//      public func Box(boxable: MustacheBoxable?) -> MustacheBox
//      public func Box(filter: FilterFunction) -> MustacheBox
//
// Sometimes values come out of Foundation objects:
//
//     class NSDictionary {
//         subscript (key: NSCopying) -> AnyObject? { get }
//     }
//
// So we need a Box(AnyObject?) function, right?
//
// Unfortunately, this will not work:
//
//     protocol MustacheBoxable {}
//     class Thing: MustacheBoxable {}
//
//     func Box(x: MustacheBoxable?) -> String { return "MustacheBoxable" }
//     func Box(x: AnyObject?) -> String { return "AnyObject" }
//
//     // error: ambiguous use of 'Box'
//     Box(Thing())
//
// Maybe if we turn the func Box(x: MustacheBoxable?) into a generic one? Well,
// it does not make the job either:
//
//     protocol MustacheBoxable {}
//     class Thing: MustacheBoxable {}
//
//     func Box<T: MustacheBoxable>(x: T?) -> String { return "MustacheBoxable" }
//     func Box(x: AnyObject?) -> String { return "AnyObject" }
//
//     // Wrong: uses the AnyObject variant
//     Box(Thing())
//
//     // Error: cannot find an overload for 'Box' that accepts an argument list of type '(MustacheBoxable)'
//     Box(Thing() as MustacheBoxable)
//
//     // Error: Crash the compiler
//     Box(Thing() as MustacheBoxable?)
//
// And if we turn the func Box(x: AnyObject) into a generic one? Well, it gets
// better:
//
//     protocol MustacheBoxable {}
//     class Thing: MustacheBoxable {}
//
//     func Box(x: MustacheBoxable?) -> String { return "MustacheBoxable" }
//     func Box<T:AnyObject>(object: T?) -> String { return "AnyObject" }
//
//     // OK: uses the MustacheBox variant
//     Box(Thing())
//
//     // OK: uses the MustacheBox variant
//     Box(Thing() as MustacheBoxable)
//
//     // OK: uses the MustacheBox variant
//     Box(Thing() as MustacheBoxable?)
//
//     // OK: uses the AnyObject variant
//     Box(Thing() as AnyObject)
//
//     // OK: uses the AnyObject variant
//     Box(Thing() as AnyObject?)
//
// This looks OK, doesn't it? Well, it's not satisfying yet.
//
// According to http://airspeedvelocity.net/2015/03/26/protocols-and-generics-2/
// there are reasons for preferring func Box<T: MustacheBoxable>(x: T?) over
// func Box(x: MustacheBoxable?). The example above have shown that the boxing
// of AnyObject with an overloaded version of Box() would make this choice for
// us.
//
// It's better not to make any choice right now, until we have a better
// knowledge of Swift performances and optimization, and of the way Swift
// resolves overloaded functions.
// 
// So let's avoid having any Box(AnyObject?) variant in the public API, and
// let's expose the BoxAnyObject(object: AnyObject?) instead.

/**
`AnyObject` can feed Mustache templates.

Yet, due to constraints in the Swift language, there is no `Box(AnyObject)`
function. Instead, you use `BoxAnyObject`:

    let set = NSSet(object: "Mario")
    let object: AnyObject = set.anyObject()
    let box = BoxAnyObject(object)
    box.value as String  // "Mario"

The object is tested at runtime whether it conforms to the `MustacheBoxable`
protocol. In this case, this function behaves just like `Box(MustacheBoxable)`.

Otherwise, GRMustache logs a warning, and returns the empty box.

:param: object An object

:returns: A MustacheBox that wraps `object`
*/
public func BoxAnyObject(object: AnyObject?) -> MustacheBox {
    if let boxable = object as? MustacheBoxable {
        return Box(boxable)
    } else if let object: AnyObject = object {
        
        // IMPLEMENTATION NOTE
        //
        // In the example below, the Thing class can not be turned into any
        // relevant MustacheBox.
        // 
        // Yet we can not prevent the user from trying to box it, because the
        // Thing class conforms to the AnyObject protocol, just as all Swift
        // classes.
        //
        // ::
        //
        //   class Thing { }
        //   
        //   // Compilation error (OK): cannot find an overload for 'Box' that accepts an argument list of type '(Thing)'
        //   Box(Thing())
        //   
        //   // Runtime warning (Not OK but unavoidable): value `Thing` is not NSObject and does not conform to MustacheBoxable: it is discarded.
        //   BoxAnyObject(Thing())
        //   
        //   // Foundation collections can also contain unsupported classes:
        //   let array = NSArray(object: Thing())
        //   
        //   // Runtime warning (Not OK but unavoidable): value `Thing` is not NSObject and does not conform to MustacheBoxable: it is discarded.
        //   Box(array)
        //   
        //   // Compilation error (OK): cannot find an overload for 'Box' that accepts an argument list of type '(AnyObject)'
        //   Box(array[0])
        //   
        //   // Runtime warning (Not OK but unavoidable): value `Thing` is not NSObject and does not conform to MustacheBoxable: it is discarded.
        //   BoxAnyObject(array[0])
        
        NSLog("Mustache.BoxAnyObject(): value `\(object)` is does not conform to MustacheBoxable: it is discarded.")
        return Box()
    } else {
        return Box()
    }
}


/**
GRMustache provides built-in support for rendering `NSObject`.
*/

extension NSObject : MustacheBoxable {
    
    /**
    `NSObject` can feed Mustache templates.
    
    NSObject's default implementation handles two general cases:
    
    - Enumerable objects that conform to the `NSFastEnumeration` protocol, such
      as `NSArray` and `NSOrderedSet`.
    - All other objects
    
    GRMustache ships with a few specific classes that escape the general cases
    and provide their own rendering behavior: `NSDictionary`, `NSFormatter`,
    `NSNull`, `NSNumber`, `NSString`, and `NSSet` (see the documentation for
    those classes).
    
    Your own subclasses of NSObject can also override the `mustacheBox` method
    and provide their own custom behavior.
    
    
    ## Arrays
    
    An object is treated as an array if it conforms to `NSFastEnumeration`. This
    is the case of `NSArray` and `NSOrderedSet`, for example. `NSDictionary` and
    `NSSet` have their own custom Mustache rendering: see their documentation
    for more information.
    
    
    ### Rendering
    
    - `{{array}}` renders the concatenation of the renderings of the array items.
    
    - `{{#array}}...{{/array}}` renders as many times as there are items in
      `array`, pushing each item on its turn on the top of the context stack.
    
    - `{{^array}}...{{/array}}` renders if and only if `array` is empty.
    
    
    ### Keys exposed to templates
    
    An array can be queried for the following keys:
    
    - `count`: number of elements in the array
    - `first`: the first object in the array
    - `firstObject`: the first object in the array
    - `last`: the last object in the array
    - `lastObject`: the last object in the array
    
    Because 0 (zero) is falsey, `{{#array.count}}...{{/array.count}}` renders
    once, if and only if `array` is not empty.
    
    
    ## Other objects
    
    Other objects fall in the general case.
    
    Their keys are extracted with the `valueForKey:` method, as long as the key
    is a property name, a custom property getter, or the name of a
    `NSManagedObject` attribute.
    
    
    ### Rendering
    
    - `{{object}}` renders the result of the `description` method, HTML-escaped.
    
    - `{{{object}}}` renders the result of the `description` method, *not*
      HTML-escaped.
    
    - `{{#object}}...{{/object}}` renders once, pushing `object` on the top of
      the context stack.
    
    - `{{^object}}...{{/object}}` does not render.
    
    */
    public var mustacheBox: MustacheBox {
        if let enumerable = self as? NSFastEnumeration {
            // Enumerable
            
            // Turn enumerable into a Swift array of MustacheBoxes
            let boxArray = map(GeneratorSequence(NSFastGenerator(enumerable)), BoxAnyObject)
            let count = Swift.count(boxArray)
            
            return MustacheBox(
                boolValue: (count > 0),
                value: self,
                converter: MustacheBox.Converter(arrayValue: boxArray),
                keyedSubscript: { (key: String) in
                    switch key {
                    case "count":
                        // Support for both Objective-C and Swift arrays.
                        return Box(count)
                        
                    case "firstObject", "first":
                        // Support for both Objective-C and Swift arrays.
                        if count > 0 {
                            return boxArray[0]
                        } else {
                            return Box()
                        }
                        
                    case "lastObject", "last":
                        // Support for both Objective-C and Swift arrays.
                        if count > 0 {
                            return boxArray[count - 1]
                        } else {
                            return Box()
                        }
                        
                    default:
                        return Box()
                    }
                },
                render: { (info: RenderingInfo, error: NSErrorPointer) in
                    if info.enumerationItem {
                        // {{# collections }}...{{/ collections }}
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{ collection }}
                        // {{# collection }}...{{/ collection }}
                        return renderBoxArray(boxArray, info, error)
                    }
            })
        } else {
            // Generic NSObject
            
            return MustacheBox(
                value: self,
                keyedSubscript: { (key: String) in
                    if GRMustacheKeyAccess.isSafeMustacheKey(key, forObject: self) {
                        // Use valueForKey: for safe keys
                        return BoxAnyObject(self.valueForKey(key))
                    } else {
                        // Missing key
                        return Box()
                    }
                })
        }
    }
}


/**
GRMustache provides built-in support for rendering `NSNull`.
*/

extension NSNull {
    
    /**
    `NSNull` can feed Mustache templates.
    
    
    ### Rendering
    
    - `{{null}}` does not render.
    
    - `{{#null}}...{{/null}}` does not render (NSNull is falsey).
    
    - `{{^null}}...{{/null}}` does render (NSNull is falsey).
    */
    public override var mustacheBox: MustacheBox {
        return MustacheBox(
            boolValue: false,
            value: self,
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                return Rendering("")
        })
    }
}


/**
GRMustache provides built-in support for rendering `NSNumber`.
*/

extension NSNumber {
    
    /**
    `NSNumber` can feed Mustache templates. It behaves exactly like Swift
    numbers: depending on its internal objCType, an NSNumber is rendered as a
    Swift Bool, Int, UInt, or Double.
    
    
    ### Rendering
    
    - `{{number}}` is rendered with built-in Swift String Interpolation.
      Custom formatting can be explicitly required with NSNumberFormatter, as in
      `{{format(a)}}` (see `NSFormatter`).
    
    - `{{#number}}...{{/number}}` renders if and only if `number` is not 0 (zero).
    
    - `{{^number}}...{{/number}}` renders if and only if `number` is 0 (zero).
    
    */
    public override var mustacheBox: MustacheBox {
        let objCType = String.fromCString(self.objCType)!
        switch objCType {
        case "c", "i", "s", "l", "q":
            return Box(Int(longLongValue))
        case "C", "I", "S", "L", "Q":
            return Box(UInt(unsignedLongLongValue))
        case "f", "d":
            return Box(doubleValue)
        case "B":
            return Box(boolValue)
        default:
            NSLog("GRMustache support for NSNumber of type \(objCType) is not implemented yet: value is discarded.")
            return Box()
        }
    }
}


/**
GRMustache provides built-in support for rendering `NSString`.
*/

extension NSString {
    
    /**
    `NSString` can feed Mustache templates. It behaves exactly like Swift
    strings.
    
    
    ### Rendering
    
    - `{{string}}` renders the string, HTML-escaped.
    
    - `{{{string}}}` renders the string, *not* HTML-escaped.
    
    - `{{#string}}...{{/string}}` renders if and only if `string` is not empty.
    
    - `{{^string}}...{{/string}}` renders if and only if `string` is empty.
    
    HTML-escaping of `{{string}}` tags is disabled for Text templates: see
    `Configuration.contentType` for a full discussion of the content type of
    templates.
    
    
    ### Keys exposed to templates

    A string can be queried for the following keys:
    
    - `length`: the number of characters in the string (using Swift method).
    
    */
    public override var mustacheBox: MustacheBox {
        return Box(self as String)
    }
}


/**
GRMustache provides built-in support for rendering `NSDictionary`.
*/

extension NSDictionary {
    
    /**
    `NSDictionary` can feed Mustache templates. It behaves exactly like Swift
    dictionaries.

        // Renders "Freddy Mercury"
        let dictionary: NSDictionary = [
            "firstName": "Freddy",
            "lastName": "Mercury"]
        let template = Template(string: "{{firstName}} {{lastName}}")!
        let rendering = template.render(Box(dictionary))!


    ### Rendering
    
    - `{{dictionary}}` renders the result of the `description` method, HTML-escaped.
    
    - `{{{dictionary}}}` renders the result of the `description` method, *not* HTML-escaped.
    
    - `{{#dictionary}}...{{/dictionary}}` renders once, pushing `dictionary` on
    the top of the context stack.
    
    - `{{^dictionary}}...{{/dictionary}}` does not render.
    
    
    In order to iterate over the key/value pairs of a dictionary, use the `each`
    filter from the Standard Library:
    
        // Attach StandardLibrary.each to the key "each":
        let template = Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))

        // Renders "<name:Arthur, age:36, >"
        let dictionary = ["name": "Arthur", "age": 36] as NSDictionary
        let rendering = template.render(Box(["dictionary": dictionary]))!


    ### Unwrapping from MustacheBox

    Whenever you want to extract a dictionary of a MustacheBox, use the
    `dictionaryValue` property: it reliably returns an `[String: MustacheBox]`
    dictionary, whatever the actual type of the raw boxed value.
    */
    public override var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                dictionaryValue: reduce(GeneratorSequence(NSFastGenerator(self)), [String: MustacheBox](), { (var boxDictionary, key) in
                    if let key = key as? String {
                        let item = (self as AnyObject)[key] // Cast to AnyObject so that we can use subscript notation.
                        boxDictionary[key] = BoxAnyObject(item)
                    }
                    return boxDictionary
                })),
            keyedSubscript: { (key: String) in
                let item = (self as AnyObject)[key] // Cast to AnyObject so that we can access subscript notation.
                return BoxAnyObject(item)
        })
    }
}


/**
GRMustache provides built-in support for rendering `NSSet`.
*/

extension NSSet {
    
    /**
    `NSSet` can feed Mustache templates. It behaves exactly like Swift sets.
    
        let set: NSSet = [1,2,3]
        
        // Renders "213"
        let template = Template(string: "{{#set}}{{.}}{{/set}}")!
        template.render(Box(["set": Box(set)]))!
        
        
    ### Rendering
    
    - `{{set}}` renders the concatenation of the renderings of the set items, in
    any order.
    
    - `{{#set}}...{{/set}}` renders as many times as there are items in `set`,
    pushing each item on its turn on the top of the context stack.
    
    - `{{^set}}...{{/set}}` renders if and only if `set` is empty.
    
    
    ### Keys exposed to templates
    
    A set can be queried for the following keys:
    
    - `anyObject`: the first object in the set
    - `count`: number of elements in the set
    - `first`: the first object in the set
    
    Because 0 (zero) is falsey, `{{#set.count}}...{{/set.count}}` renders once,
    if and only if `set` is not empty.
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract a collection of a MustacheBox, use the
    `arrayValue` property: it reliably returns an Array of MustacheBox, whatever
    the actual type of the raw boxed value (Set, Array, NSArray, NSSet, ...)
    */
    public override var mustacheBox: MustacheBox {
        return MustacheBox(
            boolValue: (self.count > 0),
            value: self,
            converter: MustacheBox.Converter(arrayValue: map(GeneratorSequence(NSFastGenerator(self)), BoxAnyObject)),
            keyedSubscript: { (key: String) in
                switch key {
                case "count":
                    return Box(self.count)
                case "anyObject":
                    return BoxAnyObject(self.anyObject())
                default:
                    return Box()
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                if info.enumerationItem {
                    // {{# sets }}...{{/ sets }}
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    // {{ set }}
                    // {{# set }}...{{/ set }}
                    let boxes = map(GeneratorSequence(NSFastGenerator(self)), BoxAnyObject)
                    return renderBoxArray(boxes, info, error)
                }
        })
    }
}


// =============================================================================
// MARK: - Boxing of Core Mustache functions

/**
A function that wraps a `FilterFunction` into a `MustacheBox` so that it can
feed template.

    let square: FilterFunction = Filter { (x: Int?, _) in
        return Box(x! * x!)
    }

    let template = Template(string: "{{ square(x) }}")!
    template.registerInBaseContext("square", Box(square))

    // Renders "100"
    template.render(Box(["x": 10]))!

:param: filter A FilterFunction
:returns: A MustacheBox

:see: FilterFunction
*/
public func Box(filter: FilterFunction) -> MustacheBox {
    return MustacheBox(filter: filter)
}

/**
A function that wraps a `RenderFunction` into a `MustacheBox` so that it can
feed template.

    let foo: RenderFunction = { (_, _) in Rendering("foo") }

    // Renders "foo"
    let template = Template(string: "{{ foo }}")!
    template.render(Box(["foo": Box(foo)]))!

:param: render A RenderFunction
:returns: A MustacheBox

:see: RenderFunction
*/
public func Box(render: RenderFunction) -> MustacheBox {
    return MustacheBox(render: render)
}

/**
A function that wraps a `WillRenderFunction` into a `MustacheBox` so that it can
feed template.

    let logTags: WillRenderFunction = { (tag: Tag, box: MustacheBox) in
        println("\(tag) will render \(box.value!)")
        return box
    }

    // By entering the base context of the template, the logTags function
    // will be notified of all tags.
    let template = Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")!
    template.extendBaseContext(Box(logTags))

    // Prints:
    // {{# user }} at line 1 will render { firstName = Errol; lastName = Flynn; }
    // {{ firstName }} at line 1 will render Errol
    // {{ lastName }} at line 1 will render Flynn
    let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
    template.render(Box(data))!

:param: willRender A WillRenderFunction
:returns: A MustacheBox

:see: WillRenderFunction
*/
public func Box(willRender: WillRenderFunction) -> MustacheBox {
    return MustacheBox(willRender: willRender)
}

/**
A function that wraps a `DidRenderFunction` into a `MustacheBox` so that it can
feed template.

    let logRenderings: DidRenderFunction = { (tag: Tag, box: MustacheBox, string: String?) in
        println("\(tag) did render \(box.value!) as `\(string!)`")
    }

    // By entering the base context of the template, the logRenderings function
    // will be notified of all tags.
    let template = Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")!
    template.extendBaseContext(Box(logRenderings))

    // Renders "Errol Flynn"
    //
    // Prints:
    // {{ firstName }} at line 1 did render Errol as `Errol`
    // {{ lastName }} at line 1 did render Flynn as `Flynn`
    // {{# user }} at line 1 did render { firstName = Errol; lastName = Flynn; } as `Errol Flynn`
    let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
    template.render(Box(data))!

:param: didRender A DidRenderFunction
:returns: A MustacheBox

:see: DidRenderFunction
*/
public func Box(didRender: DidRenderFunction) -> MustacheBox {
    return MustacheBox(didRender: didRender)
}


// =============================================================================
// MARK: - Boxing of multi-facetted values


/**
This function is the most low-level function that lets you build MustacheBox
for feeding templates.

It is suited for building "advanced" boxes. There are other simpler versions of
the `Box` function that may well better suit your need: you should check them.

It can take up to seven parameters, all optional, that define how the box
interacts with the Mustache engine:

- `boolValue`:      an optional boolean value for the Box.
- `value`:          an optional boxed value
- `keyedSubscript`: an optional KeyedSubscriptFunction
- `filter`:         an optional FilterFunction
- `render`:         an optional RenderFunction
- `willRender`:     an optional WillRenderFunction
- `didRender`:      an optional DidRenderFunction


To illustrate the usage of all those parameters, let's look at how the
`{{f(a)}}` tag is rendered.

First the `a` and `f` expressions are evaluated. The Mustache engine looks in
the context stack for boxes whose *keyedSubscript* return non-empty boxes for
the keys "a" and "f". Let's call them aBox and fBox.

Then the *filter* of the fBox is evaluated with aBox as an argument. It is
likely that the result depends on the *value* of the aBox: it is the resultBox.

Then the Mustache engine is ready to render resultBox. It looks in the context
stack for boxes whose *willRender* function is defined. Those willRender
functions have the opportunity to process the resultBox, and eventually provide
the box that will be actually rendered: the renderedBox.

The renderedBox has a *render* function: it is evaluated by the Mustache engine
which appends its result to the final rendering.

Finally the Mustache engine looks in the context stack for boxes whose
*didRender* function is defined, and call them.


### boolValue

The optional `boolValue` parameter tells whether the Box should trigger or
prevent the rendering of regular `{{#section}}...{{/}}` and inverted
`{{^section}}...{{/}}` tags. The default value is true, unless the function is
called without argument to build the empty box: `Box()`.

    // Render "true", "false"
    let template = Template(string:"{{#.}}true{{/.}}{{^.}}false{{/.}}")!
    template.render(Box(boolValue: true))!
    template.render(Box(boolValue: false))!


### value

The optional `value` parameter gives the boxed value. The value is used when the
box is rendered (unless you provide a custom RenderFunction).

    let aBox = Box(value: 1)

    // Renders "1"
    let template = Template(string: "{{a}}")!
    let rendering = template.render(Box(["a": aBox]))!


### keyedSubscript

The optional `keyedSubscript` parameter is a `KeyedSubscriptFunction` that lets
the Mustache engine extract keys out of the box. For example, the `{{a}}` tag
would call the subscript function with `"a"` as an argument, and render the
returned box.

The default value is nil, which means that no key can be extracted.

See `KeyedSubscriptFunction` for a full discussion of this type.

    let box = Box(keyedSubscript: { (key: String) in
        return Box("key:\(key)")
    })

    // Renders "key:a"
    let template = Template(string:"{{a}}")!
    template.render(box)!


### filter

The optional `filter` parameter is a `FilterFunction` that lets the Mustache
engine evaluate filtered expression that involve the box. The default value is
nil, which means that the box can not be used as a filter.

See `FilterFunction` for a full discussion of this type.

    let box = Box(filter: Filter { (x: Int?, _) in
        return Box(x! * x!)
    })

    // Renders "100"
    let template = Template(string:"{{square(x)}}")!
    template.render(Box(["square": box, "x": Box(10)]))!


### render

The optional `render` parameter is a `RenderFunction` that is evaluated when the
Box is rendered.

The default value is nil, which makes the box perform default Mustache
rendering:

- `{{box}}` renders the built-in Swift String Interpolation of the value,
  HTML-escaped.

- `{{{box}}}` renders the built-in Swift String Interpolation of the value,
not HTML-escaped.

- `{{#box}}...{{/box}}` does not render if `boolValue` is false. Otherwise, it
  pushes the box on the top of the context stack, and renders the section once.

- `{{^box}}...{{/box}}` renders once if `boolValue` is false. Otherwise, it
  does not render.

See `RenderFunction` for a full discussion of this type.

    let box = Box(render: { (info: RenderingInfo, _) in
        return Rendering("foo")
    })

    // Renders "foo"
    let template = Template(string:"{{.}}")!
    template.render(box)!


### willRender, didRender

The optional `willRender` and `didRender` parameters are a `WillRenderFunction`
and `DidRenderFunction` that are evaluated for all tags as long as the box is in
the context stack.

See `WillRenderFunction` and `DidRenderFunction` for a full discussion of those
types.

    let box = Box(willRender: { (tag: Tag, box: MustacheBox) in
        return Box("baz")
    })

    // Renders "baz baz"
    let template = Template(string:"{{#.}}{{foo}} {{bar}}{{/.}}")!
    template.render(box)!


### Multi-facetted boxes

By mixing all those parameters, you can finely tune the behavior of a box.

GRMustache source code ships a few multi-facetted boxes, which may inspire you.
See for example:

- NSFormatter.mustacheBox
- HTMLEscape.mustacheBox
- StandardLibrary.Localizer.mustacheBox

Let's give an example:

    // A regular class:

    class Person {
        let firstName: String
        let lastName: String
        
        init(firstName: String, lastName: String) {
            self.firstName = firstName
            self.lastName = lastName
        }
    }

We want:

1. `{{person.firstName}}` and `{{person.lastName}}` should render the matching
   properties.
2. `{{person}}` should render the concatenation of the first and last names.

We'll provide a `KeyedSubscriptFunction` to implement 1, and a `RenderFunction`
to implement 2:

    // Have Person conform to MustacheBoxable so that we can box people, and
    // render them:

    extension Person : MustacheBoxable {
        
        // MustacheBoxable protocol requires objects to implement this property
        // and return a MustacheBox:
        
        var mustacheBox: MustacheBox {
            
            // A person is a multi-facetted object:
            return Box(
                // It has a value:
                value: self,
                
                // It lets Mustache extracts properties by name:
                keyedSubscript: { (key: String) -> MustacheBox in
                    switch key {
                    case "firstName": return Box(self.firstName)
                    case "lastName":  return Box(self.lastName)
                    default:          return Box()
                    }
                },
                
                // It performs custom rendering:
                render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                    switch info.tag.type {
                    case .Variable:
                        // {{ person }}
                        return Rendering("\(self.firstName) \(self.lastName)")
                    case .Section:
                        // {{# person }}...{{/}}
                        //
                        // Perform the default rendering: push self on the top
                        // of the context stack, and render the section:
                        let context = info.context.extendedContext(Box(self))
                        return info.tag.render(context, error: error)
                    }
                }
            )
        }
    }

    // Renders "The person is Errol Flynn"
    let person = Person(firstName: "Errol", lastName: "Flynn")
    let template = Template(string: "{{# person }}The person is {{.}}{{/ person }}")!
    template.render(Box(["person": person]))!

:param: boolValue      An optional boolean value for the Box.
:param: value          An optional boxed value
:param: keyedSubscript An optional KeyedSubscriptFunction
:param: filter         An optional FilterFunction
:param: render         An optional RenderFunction
:param: willRender     An optional WillRenderFunction
:param: didRender      An optional DidRenderFunction
:returns: A MustacheBox
*/
public func Box(
    boolValue: Bool? = nil,
    value: Any? = nil,
    keyedSubscript: KeyedSubscriptFunction? = nil,
    filter: FilterFunction? = nil,
    render: RenderFunction? = nil,
    willRender: WillRenderFunction? = nil,
    didRender: DidRenderFunction? = nil) -> MustacheBox
{
    return MustacheBox(
        boolValue: boolValue,
        value: value,
        keyedSubscript: keyedSubscript,
        filter: filter,
        render: render,
        willRender: willRender,
        didRender: didRender)
}

