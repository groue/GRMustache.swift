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

"It's all boxes all the way down."

Mustache templates don't eat raw values: they eat boxed values.

To box something, you use the Box() function. It comes in several variants so
that nearly anything can be boxed and feed templates.

This file is organized in five sections with many examples. You can use the
Playground included in `Mustache.xcworkspace` to run those examples.


- MustacheBoxable and the Boxing of Swift types

  The MustacheBoxable protocol makes any Swift type able to be boxed with the
  Box(MustacheBoxable?) function.

  Learn how the Swift types Bool, Int, UInt, Double, and String are rendered.


- Boxing of Swift collections and dictionaries

  There is one Box() function for collections, and another one for dictionaries.


- ObjCMustacheBoxable and the Boxing of Objective-C objects

  There is a Box() function for Objective-C objects.

  Learn how NSObject, NSNull, NSString, NSNumber, NSArray, NSDictionary and
  NSSet are rendered.


- Boxing of Core Mustache functions

  The "core Mustache functions" are raw filters, Mustache lambdas, etc. Those
  can be boxed as well so that you can feed templates with filters, Mustache
  lambdas, and more.


- Boxing of multi-facetted values

  Describes the most advanced Box() function.

*/


// =============================================================================
// MARK: - MustacheBoxable and the Boxing of Swift types

/**
The MustacheBoxable protocol lets your custom Swift types feed Mustache
templates.

NB: this protocol is not tailored for Objective-C classes. See the
documentation of NSObject.mustacheBox for more information.
*/
public protocol MustacheBoxable {
    
    /**
    Returns a MustacheBox.
    
    This method is invoked when a value of your conforming class is boxed with
    the Box() function. You can not return Box(self) since this would trigger
    an infinite loop. Instead you build a Box that explicitly describes how your
    conforming type interacts with the Mustache engine.
    
    For example:
    
    ::
    
      struct Person {
          let firstName: String
          let lastName: String
      }
    
      extension Person : MustacheBoxable {
          var mustacheBox: MustacheBox {
              // Return a Box that wraps our user, and exposes the `firstName`,
              // `lastName` and `fullName` to templates:
              return Box(value: self) { (key: String) in
                  switch key {
                  case "firstName":
                      return Box(self.firstName)
                  case "lastName":
                      return Box(self.lastName)
                  case "fullName":
                      return Box("\(self.firstName) \(self.lastName)")
                  default:
                      return Box()
                  }
              }
          }
      }
    
      // Renders "Tom Selleck"
      let template = Template(string: "{{person.fullName}}")!
      let person = Person(firstName: "Tom", lastName: "Selleck")
      template.render(Box(["person": Box(person)]))!
    
    There are several variants of the Box() function. Check their documentation.
    */
    var mustacheBox: MustacheBox { get }
}

/**
Boxes a value that conforms to the `MustacheBoxable` protocol.

GRMustache ships with built-in `MustacheBoxable` conformance for the following
types, so that they can feed Mustache templates: `MustacheBox`, `Bool`, `Int`,
`UInt`, `Double`, and `String`. The protocol can also be implemented by your own
types.


### Rendering

- `{{boxable}}` invokes `boxable.render`, and renders the result with eventual
  HTML-escaping.

- `{{{boxable}}}` invokes `boxable.render`, and renders the result without
  HTML-escaping.

- `{{#boxable}}...{{/boxable}}` invokes `boxable.render`, and renders the result
  with eventual HTML-escaping, if and only if `boxable.boolValue` is true.

- `{{^boxable}}...{{/boxable}}` renders if and only if `boxable.boolValue` is
  false.

:params: boxable A value
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
    public var mustacheBox: MustacheBox {
        return self
    }
}

extension Bool : MustacheBoxable {
    
    /**
    `Bool` conforms to the `MustacheBoxable` protocol so that it can feed
    Mustache templates. It behaves exactly like Objective-C booleans.
    
    
    ### Rendering
    
    - `{{bool}}` renders as `0` or `1`.
    
    - `{{#bool}}...{{//bool}}` renders if and only if `bool` is true.
    
    - `{{^bool}}...{{//bool}}` renders if and only if `bool` is false.
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract a Bool out of a MustacheBox, use the boolValue
    property: it reliably returns a Bool whatever the actual type of the raw
    boxed value.
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { self ? 1 : 0 },         // Behave like [NSNumber numberWithBool:]
                uintValue: { self ? 1 : 0 },        // Behave like [NSNumber numberWithBool:]
                doubleValue: { self ? 1.0 : 0.0 }), // Behave like [NSNumber numberWithBool:]
            boolValue: self,
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ bool }}
                    return Rendering("\(self ? 1 : 0)") // Behave like [NSNumber numberWithBool:]
                case .Section:
                    if info.enumerationItem {
                        // {{# bools }}...{{/ bools }}
                        return info.tag.renderInnerContent(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# bool }}...{{/ bool }}
                        //
                        // Bools do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.renderInnerContent(info.context, error: error)
                    }
                }
        })
    }
}

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
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract an integer out of a MustacheBox, use the
    intValue property: it reliably returns an Int whatever the actual type of
    the raw boxed value (Int, UInt, Float, Bool, NSNumber).
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { self },
                uintValue: { MustacheBox.Converter.uint(self) },
                doubleValue: { Double(self) }),
            boolValue: (self != 0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ int }}
                    return Rendering("\(self)")
                case .Section:
                    if info.enumerationItem {
                        // {{# ints }}...{{/ ints }}
                        return info.tag.renderInnerContent(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# int }}...{{/ int }}
                        //
                        // Ints do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.renderInnerContent(info.context, error: error)
                    }
                }
        })
    }
}

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
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract an unsigned integer out of a MustacheBox, use
    the uintValue property: it reliably returns a UInt whatever the actual type
    of the raw boxed value (Int, UInt, Float, Bool, NSNumber).
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { MustacheBox.Converter.int(self) },
                uintValue: { self },
                doubleValue: { Double(self) }),
            boolValue: (self != 0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ uint }}
                    return Rendering("\(self)")
                case .Section:
                    if info.enumerationItem {
                        // {{# uints }}...{{/ uints }}
                        return info.tag.renderInnerContent(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# uint }}...{{/ uint }}
                        //
                        // Uints do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.renderInnerContent(info.context, error: error)
                    }
                }
        })
    }
}

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
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract a double out of a MustacheBox, use
    the doubleValue property: it reliably returns a Double whatever the actual
    type of the raw boxed value (Int, UInt, Float, Bool, NSNumber).
    */
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { MustacheBox.Converter.int(self) },
                uintValue: { MustacheBox.Converter.uint(self) },
                doubleValue: { self }),
            boolValue: (self != 0.0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    // {{ double }}
                    return Rendering("\(self)")
                case .Section:
                    if info.enumerationItem {
                        // {{# doubles }}...{{/ doubles }}
                        return info.tag.renderInnerContent(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        // {{# double }}...{{/ double }}
                        //
                        // Doubles do not enter the context stack when used in a
                        // boolean section.
                        //
                        // This behavior must not change:
                        // https://github.com/groue/GRMustache/issues/83
                        return info.tag.renderInnerContent(info.context, error: error)
                    }
                }
        })
    }
}

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

    Strings can be queried for the following keys:
    
    - `length`: the number of characters in the string.
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract a string out of a box, cast the boxed value to
    String or NSString:
    
        let box = Box("foo")
        box.value as! String     // "foo"
        box.value as! NSString   // "foo"
    
    If the box does not contain a String, this cast would fail. If you want to
    process the rendering of a value ("123" for 123), consider looking at the
    documentation of:
    
    - `func Filter(filter: (Rendering, NSErrorPointer) -> Rendering?) -> FilterFunction`
    - `RenderFunction`
    
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
        // renderInnerContent method of the tag.
        return info.tag.renderInnerContent(info.context, error: error)
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
Boxes a collection of values that conform to the `MustacheBoxable` protocol.

GRMustache ships with built-in `MustacheBoxable` conformance for the following
types, so that they can feed Mustache templates: `MustacheBox`, `Bool`, `Int`,
`UInt`, `Double`, and `String`. The protocol can also be implemented by own
types.

    let collection: [Int] = [1,2,3]

    // Renders "123"
    let template = Template(string: "{{#collection}}{{.}}{{/collection}}")!
    template.render(Box(["collection": Box(collection)]))!


### Rendering

- `{{collection}}` renders the concatenation of the collection items.
  items.

- `{{#collection}}...{{/collection}}` renders as many times as there are items
  in `collection`, pushing each item on its turn on the top of the context
  stack.

- `{{^collection}}...{{/collection}}` renders if and only if `collection` is
  empty.

*Advanced topic*: Precisely speaking, both `{{collection}}` and `{{#collection}}...{{/collection}}`
render the concatenation of the renderings of each items

### Keys exposed to templates

Collections can be queried for the following keys:

- `count`: number of elements in the collection
- `first`: the first object in the collection
- `firstObject`: the first object in the collection
- `last`: the last object in the collection
- `lastObject`: the last object in the collection

Because 0 (zero) is falsey, `{{#collection.count}}...{{/collection.count}}`
renders once, if and only if `collection` is not empty.
*/
public func Box<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C?) -> MustacheBox {
    if let collection = collection {
        let count = distance(collection.startIndex, collection.endIndex)    // C.Index.Distance == Int
        return MustacheBox(
            boolValue: (count > 0),
            value: collection,
            converter: MustacheBox.Converter(arrayValue: { map(collection) { Box($0) } }),
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
                    return info.tag.renderInnerContent(info.context.extendedContext(Box(collection)), error: error)
                } else {
                    // {{ collection }}
                    // {{# collection }}...{{/ collection }}
                    return renderBoxArray(map(collection) { Box($0) }, info, error)
                }
        })
    } else {
        return Box()
    }
}

/**
Boxes a collection of optional values that conform to the `MustacheBoxable`
protocol.

GRMustache ships with built-in `MustacheBoxable` conformance for the following
types, so that they can feed Mustache templates: `MustacheBox`, `Bool`, `Int`,
`UInt`, `Double`, and `String`. The protocol can also be implemented by your own
types.

    let collection: [Int?] = [1,2,3]

    // Renders "123"
    let template = Template(string: "{{#collection}}{{.}}{{/collection}}")!
    template.render(Box(["collection": Box(collection)]))!


### Rendering

- `{{collection}}` renders the concatenation of the renderings of the collection
items.

- `{{#collection}}...{{/collection}}` renders as many times as there are items
in `collection`, pushing each item on its turn on the top of the context
stack.

- `{{^collection}}...{{/collection}}` renders if and only if `collection` is
empty.


### Keys exposed to templates

Collections can be queried for the following keys:

- `count`: number of elements in the collection
- `first`: the first object in the collection
- `firstObject`: the first object in the collection
- `last`: the last object in the collection
- `lastObject`: the last object in the collection

Because 0 (zero) is falsey, `{{#collection.count}}...{{/collection.count}}`
renders once, if and only if `collection` is not empty.
*/
public func Box<C: CollectionType, T where C.Generator.Element == Optional<T>, T: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C?) -> MustacheBox {
    if let collection = collection {
        let count = distance(collection.startIndex, collection.endIndex)    // C.Index.Distance == Int
        return MustacheBox(
            boolValue: (count > 0),
            value: collection,
            converter: MustacheBox.Converter(arrayValue: { map(collection) { Box($0) } }),
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
                    return info.tag.renderInnerContent(info.context.extendedContext(Box(collection)), error: error)
                } else {
                    // {{ collection }}
                    // {{# collection }}...{{/ collection }}
                    // {{^ collection }}...{{/ collection }}
                    return renderBoxArray(map(collection) { Box($0) }, info, error)
                }
        })
    } else {
        return Box()
    }
}


/**
A function that wraps a dictionary of MustacheBoxable.

::

  // Renders "Freddy Mercury"
  let dictionary: [String: String] = ["firstName": "Freddy", "lastName": "Mercury"]
  let template = Template(string: "{{firstName}} {{lastName}}")!
  let rendering = template.render(Box(dictionary))!

The genuine Mustache won't let you iterate over the key/value pairs of a
dictionary. Yet GRMustache ships with an `each` filter that performs that very
job:

::

  // Attach StandardLibrary.each to the key "each":
  let template = Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")!
  template.registerInBaseContext("each", Box(StandardLibrary.each))

  // Renders "<firstName:Freddy, lastName:Mercury,>"
  let dictionary: [String: String] = ["firstName": "Freddy", "lastName": "Mercury"]
  let rendering = template.render(Box(["dictionary": dictionary]))!

*/
public func Box<T: MustacheBoxable>(dictionary: [String: T]?) -> MustacheBox {
    if let dictionary = dictionary {
        return MustacheBox(
            value: dictionary,
            converter: MustacheBox.Converter(
                dictionaryValue: {
                    var boxDictionary: [String: MustacheBox] = [:]
                    for (key, item) in dictionary {
                        boxDictionary[key] = Box(item)
                    }
                    return boxDictionary
                }),
            keyedSubscript: { (key: String) in
                return Box(dictionary[key])
            })
    } else {
        return Box()
    }
}

/**
A function that wraps a dictionary of optional MustacheBoxable.

::

  // Renders "Freddy Mercury"
  let dictionary: [String: String?] = ["firstName": "Freddy", "lastName": "Mercury"]
  let template = Template(string: "{{firstName}} {{lastName}}")!
  let rendering = template.render(Box(dictionary))!

The genuine Mustache won't let you iterate over the key/value pairs of a
dictionary. Yet GRMustache ships with an `each` filter that performs that very
job:

::

  // Attach StandardLibrary.each to the key "each":
  let template = Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")!
  template.registerInBaseContext("each", Box(StandardLibrary.each))

  // Renders "<firstName:Freddy, lastName:Mercury,>"
  let dictionary: [String: String?] = ["firstName": "Freddy", "lastName": "Mercury"]
  let rendering = template.render(Box(["dictionary": dictionary]))!

*/
public func Box<T: MustacheBoxable>(dictionary: [String: T?]?) -> MustacheBox {
    if let dictionary = dictionary {
        return MustacheBox(
            value: dictionary,
            converter: MustacheBox.Converter(
                dictionaryValue: {
                    var boxDictionary: [String: MustacheBox] = [:]
                    for (key, item) in dictionary {
                        boxDictionary[key] = Box(item)
                    }
                    return boxDictionary
            }),
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
// MARK: - ObjCMustacheBoxable and the Boxing of Objective-C objects

/**
The ObjCMustacheBoxable protocol lets Objective-C classes interact with the
Mustache engine.

The NSObject class already conforms to this protocol: you will override the
mustacheBox if you need to provide custom rendering behavior. For an example,
look at the NSFormatter.swift source file.

See the Swift-targetted MustacheBoxable protocol for more information.
*/
@objc public protocol ObjCMustacheBoxable {
    
    // IMPLEMENTATION NOTE
    //
    // Why do we need this ObjC-dedicated protocol, when we already have the
    // MustacheBoxable protocol?
    //
    // Swift does not allow a class extension to override a method that is
    // inherited from an extension to its superclass and incompatible with
    // Objective-C. This prevents NSObject subclasses such as NSNull, NSNumber,
    // etc. to override NSObject.mustacheBox, and provide custom rendering
    // behavior.
    //
    // For an example of this limitation, see example below:
    //
    // ::
    //
    //   import Foundation
    //
    //   // A protocol that is not compatible with Objective-C
    //   struct MustacheBox { }
    //   protocol MustacheBoxable {
    //       var mustacheBox: MustacheBox { get }
    //   }
    //   
    //   // So far so good
    //   extension NSObject : MustacheBoxable {
    //       var mustacheBox: MustacheBox { return MustacheBox() }
    //   }
    //   
    //   // Error: declarations in extensions cannot override yet
    //   extension NSNull {
    //       override var mustacheBox: MustacheBox { return MustacheBox() }
    //   }
    //
    // This problem does not apply to Objc-C compatible protocols:
    //
    // ::
    //
    //   import Foundation
    //
    //   // A protocol that is compatible with Objective-C
    //   protocol ObjCCompatibleProtocol {
    //       var prop: String { get }
    //   }
    //
    //   // So far so good
    //   extension NSObject : ObjCCompatibleProtocol {
    //       var prop: String { return "NSObject" }
    //   }
    //
    //   // No error
    //   extension NSNull {
    //       override var prop: String { return "NSNull" }
    //   }
    //
    //   NSObject().prop // "NSObject"
    //   NSNull().prop   // "NSNull"
    //
    // So we chose to dedicate the Swift-only protocol MustacheBoxable to Swift
    // values, and the Objective-C compatible protocol ObjCMustacheBoxable to
    // Objective-C values. When Swift eventually improves, we may alleviate
    // this inconsistency.
    
    /**
    Returns a MustacheBox wrapped in a ObjCMustacheBox (this wrapping is
    required by the constraints of the Swift type system).
    
    This method is invoked when a value of your conforming class is boxed with
    the Box() function. You can not return Box(self) since this would trigger
    an infinite loop. Instead you build a Box that explicitly describes how your
    conforming type interacts with the Mustache engine.
    
    See the Swift-targetted MustacheBoxable protocol for more information.
    */
    var mustacheBox: ObjCMustacheBox { get }
}

/**
See the documentation of the ObjCMustacheBoxable protocol.
*/
public class ObjCMustacheBox: NSObject {
    let box: MustacheBox
    init(_ box: MustacheBox) {
        self.box = box
    }
}

/**
See the documentation of the ObjCMustacheBoxable protocol.
*/
public func Box(boxable: ObjCMustacheBoxable?) -> MustacheBox {
    if let boxable = boxable {
        return boxable.mustacheBox.box
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
// ::
//
//   public func Box(boxable: MustacheBoxable?) -> MustacheBox
//   public func Box(filter: FilterFunction) -> MustacheBox
//
// Sometimes values come out of Foundation objects:
//
// ::
//
//     class NSDictionary {
//         subscript (key: NSCopying) -> AnyObject? { get }
//     }
//
// So we need a Box(AnyObject?) function, right?
//
// Unfortunately, this will not work:
//
// ::
//
//   protocol MustacheBoxable {}
//   class Thing: MustacheBoxable {}
//
//   func Box(x: MustacheBoxable?) -> String { return "MustacheBoxable" }
//   func Box(x: AnyObject?) -> String { return "AnyObject" }
//
//   // error: ambiguous use of 'Box'
//   Box(Thing())
//
// Maybe if we turn the func Box(x: MustacheBoxable?) into a generic one? Well,
// it does not make the job either:
//
// ::
//
//   protocol MustacheBoxable {}
//   class Thing: MustacheBoxable {}
//   
//   func Box<T: MustacheBoxable>(x: T?) -> String { return "MustacheBoxable" }
//   func Box(x: AnyObject?) -> String { return "AnyObject" }
//   
//   // Wrong: uses the AnyObject variant
//   Box(Thing())
//   
//   // Error: cannot find an overload for 'Box' that accepts an argument list of type '(MustacheBoxable)'
//   Box(Thing() as MustacheBoxable)
//   
//   // Error: Crash the compiler
//   Box(Thing() as MustacheBoxable?)
//
// And if we turn the func Box(x: AnyObject) into a generic one? Well, it gets
// better:
//
// ::
//
//   protocol MustacheBoxable {}
//   class Thing: MustacheBoxable {}
//   
//   func Box(x: MustacheBoxable?) -> String { return "MustacheBoxable" }
//   func Box<T:AnyObject>(object: T?) -> String { return "AnyObject" }
//   
//   // OK: uses the MustacheBox variant
//   Box(Thing())
//   
//   // OK: uses the MustacheBox variant
//   Box(Thing() as MustacheBoxable)
//   
//   // OK: uses the MustacheBox variant
//   Box(Thing() as MustacheBoxable?)
//   
//   // OK: uses the AnyObject variant
//   Box(Thing() as AnyObject)
//   
//   // OK: uses the AnyObject variant
//   Box(Thing() as AnyObject?)
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
Due to constraints in the Swift language, there is no Box(AnyObject) function.

Instead, you use the BoxAnyObject() function:

::

  let set = NSSet(object: "Mario")
  let box = BoxAnyObject(set.anyObject())
  box.value as String  // "Mario"

*/
public func BoxAnyObject(object: AnyObject?) -> MustacheBox {
    if let boxable = object as? MustacheBoxable {
        return Box(boxable)
    } else if let boxable = object as? ObjCMustacheBoxable {
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
        //   // Runtime warning (Not OK but unavoidable): value `Thing` does not conform to MustacheBoxable or ObjCMustacheBoxable protocol, and is discarded.
        //   BoxAnyObject(Thing())
        //   
        //   // Foundation collections can also contain unsupported classes:
        //   let array = NSArray(object: Thing())
        //   
        //   // Runtime warning (Not OK but unavoidable): value `Thing` does not conform to MustacheBoxable or ObjCMustacheBoxable protocol, and is discarded.
        //   Box(array)
        //   
        //   // Compilation error (OK): cannot find an overload for 'Box' that accepts an argument list of type '(AnyObject)'
        //   Box(array[0])
        //   
        //   // Runtime warning (Not OK but unavoidable): value `Thing` does not conform to MustacheBoxable or ObjCMustacheBoxable protocol, and is discarded.
        //   BoxAnyObject(array[0])
        
        NSLog("Mustache.BoxAnyObject(): value `\(object)` does not conform to MustacheBoxable or ObjCMustacheBoxable protocol, and is discarded.")
        return Box()
    } else {
        return Box()
    }
}

extension NSObject : ObjCMustacheBoxable {
    
    /**
    `NSObject` conforms to the `ObjCMustacheBoxable` protocol so that all 
    Objective-C objects can feed Mustache templates.
    
    NSObject's default implementation handles two general cases:
    
    - Enumerable objects that conform to the `NSFastEnumeration` protocol, such
      as `NSArray` and `NSOrderedSet`.
    - All other objects
    
    GRMustache ships with a few specific classes that escape the general cases
    and provide their own rendering behavior: `NSDictionary, `NSFormatter`,
    `NSNull`, `NSNumber`, `NSString`, and `NSSet` (see the documentation for
    those classes).
    
    Your own subclasses of NSObject can also override the `mustacheBox` method
    and provide their own custom behavior.
    
    
    ## Arrays
    
    An objet is treated as an array if it conforms to `NSFastEnumeration`. This
    is the case of `NSArray` and `NSOrderedSet`, for example. `NSDictionary` and
    `NSSet` have their own custom Mustache rendering: see their documentation
    for more information.
    
    
    ### Rendering
    
    - `{{array}}` renders the concatenation of the renderings of the array items.
    
    - `{{#array}}...{{/array}}` renders as many times as there are items in
      `array`, pushing each item on its turn on the top of the context stack.
    
    - `{{^array}}...{{/array}}` renders if and only if `array` is empty.
    
    
    ### Keys exposed to templates
    
    Arrays can be queried for the following keys:
    
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
    is a property names, a custom property getter, or the name of a
    `NSManagedObject` attribute.
    
    
    ### Rendering
    
    - `{{object}}` renders the result of the `description` method, HTML-escaped.
    
    - `{{{object}}}` renders the result of the `description` method, *not* HTML-escaped.
    
    - `{{#object}}...{{/object}}` renders once, pushing `object` on the top of
      the context stack.
    
    - `{{^object}}...{{/object}}` does not render.
    
    HTML-escaping of `{{object}}` tags is disabled for Text templates: see
    `Configuration.contentType` for a full discussion of the content type of
    templates.
    */
    public var mustacheBox: ObjCMustacheBox {
        let box: MustacheBox
        
        if let enumerable = self as? NSFastEnumeration {
            // Enumerable
            
            // Box an Array<MustacheBox>, but keep the original NSArray value
            let array = map(GeneratorSequence(NSFastGenerator(enumerable))) { BoxAnyObject($0) }
            box = Box(array).boxWithValue(self)
            
        } else {
            // Generic NSObject
            
            box = MustacheBox(
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
        
        // Objective-C classes must return a box wrapped in the ObjCMustacheBox
        // class. This inconvenience comes from a limitation of the Swift
        // language (see IMPLEMENTATION NOTE for the ObjCMustacheBoxable
        // protocol).
        return ObjCMustacheBox(box)
    }
}

extension NSNull : ObjCMustacheBoxable {
    
    /**
    `NSNull` conforms to the `ObjCMustacheBoxable` protocol so that it can feed
    Mustache templates.
    
    
    ### Rendering
    
    - `{{null}}` does not render.
    
    - `{{#null}}...{{/null}}` does not render (NSNull is falsey).
    
    - `{{^null}}...{{/null}}` does render (NSNull is falsey).
    */
    public override var mustacheBox: ObjCMustacheBox {
        let box = MustacheBox(
            boolValue: false,
            value: self,
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                return Rendering("")
        })
        
        // Objective-C classes must return a box wrapped in the ObjCMustacheBox
        // class. This inconvenience comes from a limitation of the Swift
        // language (see IMPLEMENTATION NOTE for the ObjCMustacheBoxable
        // protocol).
        return ObjCMustacheBox(box)
    }
}

extension NSNumber : ObjCMustacheBoxable {
    
    /**
    `NSNumber` conforms to the `ObjCMustacheBoxable` protocol so that it can
    feed Mustache templates. It behaves exactly like Swift numbers: depending on
    its internal objCType, an NSNumber is rendered as a Swift Bool, Int, UInt,
    or Double.
    
    
    ### Rendering
    
    - `{{number}}` is rendered with built-in Swift String Interpolation.
      Custom formatting can be explicitly required with NSNumberFormatter, as in
      `{{format(a)}}` (see `NSFormatter`).
    
    - `{{#number}}...{{/number}}` renders if and only if `number` is not 0 (zero).
    
    - `{{^number}}...{{/number}}` renders if and only if `number` is 0 (zero).
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract a number out of a MustacheBox, use the
    intValue, uintValue, doubleValue or boolValue properties: they reliably
    return the expected type whatever the actual type of the raw boxed value.
    */
    public override var mustacheBox: ObjCMustacheBox {
        // Objective-C classes must return a box wrapped in the ObjCMustacheBox
        // class. This inconvenience comes from a limitation of the Swift
        // language (see IMPLEMENTATION NOTE for the ObjCMustacheBoxable
        // protocol).
        
        let objCType = String.fromCString(self.objCType)!
        switch objCType {
        case "c", "i", "s", "l", "q":
            return ObjCMustacheBox(Box(Int(longLongValue)))
        case "C", "I", "S", "L", "Q":
            return ObjCMustacheBox(Box(UInt(unsignedLongLongValue)))
        case "f", "d":
            return ObjCMustacheBox(Box(doubleValue))
        case "B":
            return ObjCMustacheBox(Box(boolValue))
        default:
            NSLog("GRMustache support for NSNumber of type \(objCType) is not implemented yet: value is discarded.")
            return ObjCMustacheBox(Box())
        }
    }
}

extension NSString : ObjCMustacheBoxable {
    
    /**
    `NSString` conforms to the `ObjCMustacheBoxable` protocol so that it can
    feed Mustache templates. It behaves exactly like Swift strings.
    
    
    ### Rendering
    
    - `{{string}}` renders the string, HTML-escaped.
    
    - `{{{string}}}` renders the string, *not* HTML-escaped.
    
    - `{{#string}}...{{/string}}` renders if and only if `string` is not empty.
    
    - `{{^string}}...{{/string}}` renders if and only if `string` is empty.
    
    HTML-escaping of `{{string}}` tags is disabled for Text templates: see
    `Configuration.contentType` for a full discussion of the content type of
    templates.
    
    
    ### Keys exposed to templates

    Strings can be queried for the following keys:
    
    - `length`: the number of characters in the string (using Swift method).
    
    
    ### Unwrapping from MustacheBox
    
    Whenever you want to extract a string out of a box, cast the boxed value to
    String or NSString:
    
        let box = Box("foo")
        box.value as! String     // "foo"
        box.value as! NSString   // "foo"
    
    If the box does not contain a String, this cast would fail. If you want to
    process the rendering of a value ("123" for 123), consider looking at the
    documentation of:
    
    - `func Filter(filter: (Rendering, NSErrorPointer) -> Rendering?) -> FilterFunction`
    - `RenderFunction`
    
    */
    public override var mustacheBox: ObjCMustacheBox {
        let box = Box(self as String)
        
        // Objective-C classes must return a box wrapped in the ObjCMustacheBox
        // class. This inconvenience comes from a limitation of the Swift
        // language (see IMPLEMENTATION NOTE for the ObjCMustacheBoxable
        // protocol).
        return ObjCMustacheBox(box)
    }
}

extension NSDictionary : ObjCMustacheBoxable {
    
    /**
    `NSDictionary` conforms to the `ObjCMustacheBoxable` protocol so that it can
    feed Mustache templates.
    
    
    ### Rendering
    
    - `{{dictionary}}` renders the result of the `description` method, HTML-escaped.
    
    - `{{{dictionary}}}` renders the result of the `description` method, *not* HTML-escaped.
    
    - `{{#dictionary}}...{{/dictionary}}` renders once, pushing `dictionary` on
    the top of the context stack.
    
    - `{{^dictionary}}...{{/dictionary}}` does not render.

    HTML-escaping of `{{dictionary}}` tags is disabled for Text templates: see
    `Configuration.contentType` for a full discussion of the content type of
    templates.
    
    In order to iterate over the key/value pairs of a dictionary, use the `each`
    filter from the Standard Library:
    
        // Attach StandardLibrary.each to the key "each":
        let template = Template(string: "<{{# each(dictionary) }}{{@key}}:{{.}}, {{/}}>")!
        template.registerInBaseContext("each", Box(StandardLibrary.each))

        // Renders "<name:Arthur, age:36, >"
        let dictionary = ["name": "Arthur", "age": 36] as NSDictionary
        let rendering = template.render(Box(["dictionary": dictionary]))!

    */
    public override var mustacheBox: ObjCMustacheBox {
        let box = MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                dictionaryValue: {
                    return reduce(GeneratorSequence(NSFastGenerator(self)), [:] as [String: MustacheBox]) { (var boxDictionary, key) in
                        if let key = key as? String {
                            let item = (self as AnyObject)[key] // Cast to AnyObject so that we can access subscript notation.
                            boxDictionary[key] = BoxAnyObject(item)
                        }
                        return boxDictionary
                    }
            }),
            keyedSubscript: { (key: String) in
                let item = (self as AnyObject)[key] // Cast to AnyObject so that we can access subscript notation.
                return BoxAnyObject(item)
        })
        
        // Objective-C classes must return a box wrapped in the ObjCMustacheBox
        // class. This inconvenience comes from a limitation of the Swift
        // language (see IMPLEMENTATION NOTE for the ObjCMustacheBoxable
        // protocol).
        return ObjCMustacheBox(box)
    }
}

extension NSSet : ObjCMustacheBoxable {
    
    /**
    `NSSet` conforms to the `ObjCMustacheBoxable` protocol so that it can feed
    Mustache templates.
    
    
    ### Rendering
    
    - `{{set}}` renders the concatenation of the renderings of the set items, in
      any order.
    
    - `{{#set}}...{{/set}}` renders as many times as there are items in `set`,
      pushing each item on its turn on the top of the context stack.
    
    - `{{^set}}...{{/set}}` renders if and only if `set` is empty.
    
    
    ### Keys exposed to templates
    
    Sets can be queried for the following keys:
    
    - `count`: number of elements in the set
    - `anyObject`: any object of the set
    
    Because 0 (zero) is falsey, `{{#set.count}}...{{/set.count}}` renders once,
    if and only if `set` is not empty.
    */
    public override var mustacheBox: ObjCMustacheBox {
        let box = MustacheBox(
            boolValue: (self.count > 0),
            value: self,
            converter: MustacheBox.Converter(arrayValue: { map(GeneratorSequence(NSFastGenerator(self))) { BoxAnyObject($0) } }),
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
                    return info.tag.renderInnerContent(info.context.extendedContext(Box(self)), error: error)
                } else {
                    // {{ set }}
                    // {{# set }}...{{/ set }}
                    let boxes = map(GeneratorSequence(NSFastGenerator(self))) { BoxAnyObject($0) }
                    return renderBoxArray(boxes, info, error)
                }
        })
        
        // Objective-C classes must return a box wrapped in the ObjCMustacheBox
        // class. This inconvenience comes from a limitation of the Swift
        // language (see IMPLEMENTATION NOTE for the ObjCMustacheBoxable
        // protocol).
        return ObjCMustacheBox(box)
    }
}


// =============================================================================
// MARK: - Boxing of Core Mustache functions

/**
A function that wraps a value and a KeyedSubscriptFunction into a MustacheBox.

:see: KeyedSubscriptFunction

::

  struct Person {
      let firstName: String
      let lastName: String
  }

  extension Person : MustacheBoxable {
      var mustacheBox: MustacheBox {
          // Return a Box that wraps our user, and exposes `firstName`,
          // `lastName` and `fullName` to templates:
          return Box(value: self) { (key: String) in
              switch key {
              case "firstName":
                  return Box(self.firstName)
              case "lastName":
                  return Box(self.lastName)
              case "fullName":
                  return Box("\(self.firstName) \(self.lastName)")
              default:
                  return Box()
              }
          }
      }
  }

  // Renders "Tom Selleck"
  let template = Template(string: "{{ person.fullName }}")!
  let person = Person(firstName: "Tom", lastName: "Selleck")
  template.render(Box(["person": Box(person)]))!
*/
public func Box(value: Any? = nil, keyedSubscript: KeyedSubscriptFunction) -> MustacheBox {
    return MustacheBox(value: value, keyedSubscript: keyedSubscript)
}

/**
A function that wraps a FilterFunction into a MustacheBox.

:see: FilterFunction

::

  let square: FilterFunction = Filter { (x: Int, _) in
      return Box(x * x)
  }

  let template = Template(string: "{{ square(x) }}")!
  template.registerInBaseContext("square", Box(square))

  // Renders "100"
  template.render(Box(["x": 10]))!
*/
public func Box(filter: FilterFunction) -> MustacheBox {
    return MustacheBox(filter: filter)
}

/**
A function that wraps a RenderFunction into a MustacheBox.

RenderFunction is the core function type that lets you implement Mustache
lambdas, and more.

:see: RenderFunction

::

  let foo: RenderFunction = { (_, _) in Rendering("foo") }

  // Renders "foo"
  let template = Template(string: "{{ foo }}")!
  template.render(Box(["foo": Box(foo)]))!
*/
public func Box(render: RenderFunction) -> MustacheBox {
    return MustacheBox(render: render)
}

/**
A function that wraps a WillRenderFunction into a MustacheBox.

:see: WillRenderFunction

::

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
*/
public func Box(willRender: WillRenderFunction) -> MustacheBox {
    return MustacheBox(willRender: willRender)
}

/**
A function that wraps a DidRenderFunction into a MustacheBox.

:see: DidRenderFunction

::

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
*/
public func Box(didRender: DidRenderFunction) -> MustacheBox {
    return MustacheBox(didRender: didRender)
}


// =============================================================================
// MARK: - Boxing of multi-facetted values


/**
This function is the most low-level function that lets you build MustacheBox
for feeding templates.

It is suited for building somewhat "advanced" boxes. There are other simpler
versions of the Box() function that may well better suit your need; you should
check them.

It can take up to seven parameters, all optional, that define how the box
interacts with the Mustache engine:

:param: boolValue      An optional boolean value for the Box.
:param: value          An optional boxed value
:param: keyedSubscript An optional KeyedSubscriptFunction
:param: filter         An optional FilterFunction
:param: render         An optional RenderFunction
:param: willRender     An optional WillRenderFunction
:param: didRender      An optional DidRenderFunction


To illustrate the usage of all those parameters, let's look at how the {{f(a)}}
tag is rendered.

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


The optional boolValue parameter tells whether the Box should trigger or prevent
the rendering of regular {{#section}}...{{/}} and inverted {{^section}}...{{/}}.
The default value is true, unless the function is called without argument to
build the empty box: Box().

::

  // Render "true", "false"
  let template = Template(string:"{{#.}}true{{/.}}{{^.}}false{{/.}}")!
  template.render(Box(boolValue: true))!
  template.render(Box(boolValue: false))!


The optional value parameter gives the boxed value. You should generally provide
one, although the value is only used when evaluating filters, and not all
templates use filters. The default value is nil.


The optional keyedSubscript parameter is a KeyedSubscriptFunction that lets the
Mustache engine extract keys out of the box. For example, the {{a}} tag would
call the SubscriptFunction with "a" as an argument, and render the returned box.
The default value is nil, which means that no key can be extracted.

:see: KeyedSubscriptFunction for a full discussion of this type.

::

  // Renders "key:a"
  let template = Template(string:"{{a}}")!
  let box = Box(keyedSubscript: { (key: String) in
      return Box("key:\(key)")
  })
  template.render(box)!


The optional filter parameter is a FilterFunction that lets the Mustache engine
evaluate filtered expression that involve the box. The default value is nil,
which means that the box can not be used as a filter.

:see: FilterFunction for a full discussion of this type.

::

  // Renders "100"
  let template = Template(string:"{{square(x)}}")!
  let box = Box(filter: Filter { (int: Int, _) in
      return Box(int * int)
  })
  template.render(Box(["square": box, "x": Box(10)]))!


The optional render parameter is a RenderFunction that is evaluated when the Box
gets rendered. The default value is nil, which makes the box perform default
Mustache rendering of values. RenderFunctions are functions that let you
implement, for example, Mustache lambdas.

:see: RenderFunction for a full discussion of this type.

::

  // Renders "foo"
  let template = Template(string:"{{.}}")!
  let box = Box(render: { (info: RenderingInfo, _) in
      return Rendering("foo")
  })
  template.render(box)!


The optional willRender and didRender parameters are a WillRenderFunction and
DidRenderFunction that are evaluated for all tags as long as the box is in the
context stack.

:see: WillRenderFunction and DidRenderFunction for a full discussion of those
types.

::

  // Renders "baz baz"
  let template = Template(string:"{{#.}}{{foo}} {{bar}}{{/.}}")!
  let box = Box(willRender: { (tag: Tag, box: MustacheBox) in
      return Box("baz")
  })
  template.render(box)!


By mixing all those parameters, you can tune the behavior of a box. Example:

::

  // Nothing special here:

  class Person {
      let firstName: String
      let lastName: String
      
      init(firstName: String, lastName: String) {
          self.firstName = firstName
          self.lastName = lastName
      }
  }
  

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
              
              // It lets Mustache extracts values by name:
              keyedSubscript: self.keyedSubscript,
              
              // It performs custom rendering:
              render: self.render)
      }
      

      // The KeyedSubscriptFunction that lets the Mustache engine extract values
      // by name. Let's expose the `firstName`, `lastName` and `fullName`:

      func keyedSubscript(key: String) -> MustacheBox {
          switch key {
          case "firstName": return Box(firstName)
          case "lastName": return Box(lastName)
          case "fullName": return Box("\(firstName) \(lastName)")
          default: return Box()
          }
      }

      
      // A custom RenderFunction that avoids default Mustache rendering:

      func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
          switch info.tag.type {
          case .Variable:
              // Custom rendering of {{ person }} variable tags:
              return Rendering("\(firstName) \(lastName)")
          case .Section:
              // Regular rendering of {{# person }}...{{/}} section tags:
              // Extend the context with self, and render the inner content of
              // the section tag:
              let context = info.context.extendedContext(Box(self))
              return info.tag.renderInnerContent(context, error: error)
          }
      }
  }
  
  // Renders "The person is Errol Flynn"
  let person = Person(firstName: "Errol", lastName: "Flynn")
  let template = Template(string: "{{# person }}The person is {{.}}{{/ person }}")!
  template.render(Box(["person": person]))!
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

