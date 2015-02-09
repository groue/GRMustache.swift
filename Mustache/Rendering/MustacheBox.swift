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


// =============================================================================
// MARK: - Core rendering types

/**
GRMustache distinguishes Text from HTML: escaped tags such as {{name}} escape
text values, and templates can be configured to render text or HTML.

The ContentType enum represents this content type.
*/
public enum ContentType {
    case Text
    case HTML
}

/**
A Rendering is a tainted String, which knows its content type, Text or HTML.
*/
public struct Rendering {
    public let string: String
    public let contentType: ContentType
    
    /**
    Builds a Rendering with a String and a ContentType.
    
    Usage:
    
    ::
    
      Rendering("foo")        // Defaults to Text
      Rendering("foo", .Text)
      Rendering("foo", .HTML)
    
    You will meet the Rendering type when you implement custom rendering
    functions. Example:
    
    ::
    
      let render: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
          return Rendering("foo")
      }
    
      // Renders "foo"
      let template = Template(string: "{{object}}")!
      let data = ["object": Box(render)]
      let rendering = template.render(Box(data))!
    
    :param: string A string
    :param: contentType A content type
    
    :see: RenderFunction
    */
    public init(_ string: String, _ contentType: ContentType = .Text) {
        self.string = string
        self.contentType = contentType
    }
}

/**
You will meet the RenderingInfo when you implement custom rendering
functions of type RenderFunction.

A RenderFunction is invoked as soon as a variable tag {{name}} or a section
tag {{#name}}...{{/name}} is rendered.

The RenderingInfo parameter provides information about the rendered tag,
variable or section, and the context stack.

Example:

::

  let render: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in

      switch info.tag.type {
      case .Variable:
          // Render the {{object}} variable tag

          return Rendering("variable")
          
      case .Section:
          // Render the {{#object}}...{{/object}} section tag.
          //
          // Extend the current context with ["value": "foo"], and proceed
          // with regular rendering of the inner content of the section.

          let context = info.context.extendedContext(Box(["value": "foo"]))
          return info.tag.render(context, error: error)
      }
  }
  let data = ["object": Box(render)]
  
  // Renders "variable"
  let template1 = Template(string: "{{object}}")!
  let rendering1 = template1.render(Box(data))!

  // Renders "value: foo"
  let template2 = Template(string: "{{#object}}value: {{value}}{{/object}}")!
  let rendering2 = template2.render(Box(data))!

:see: RenderFunction
*/
public struct RenderingInfo {
    public let tag: Tag
    public var context: Context
    let enumerationItem: Bool
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(tag: tag, context: context, enumerationItem: true)
    }
}


// =============================================================================
// MARK: - Core function types
//
// GRMustache defines five "core function types". Each defines a way to interact
// with the rendering engine.
//
// - SubscriptFunction extracts keys: {{name}} invokes a SubscriptFunction with
//   the "name" argument.
//
// - FilterFunction evaluates filter expressions: {{f(x)}} invokes a
//   FilterFunction.
//
// - RenderFunction renders Mustache tags: {{name}} and {{#items}}...{{/items}}
//   both invoke a RenderFunction
//
// - WillRenderFunction can TODO
//
//
// MARK: SubscriptFunction
public typealias SubscriptFunction = (key: String) -> MustacheBox?

// MARK: FilterFunction
public typealias FilterFunction = (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox?

// MARK: RenderFunction
public typealias RenderFunction = (info: RenderingInfo, error: NSErrorPointer) -> Rendering?

// MARK: WillRenderFunction
public typealias WillRenderFunction = (tag: Tag, box: MustacheBox) -> MustacheBox

// MARK: DidRenderFunction
public typealias DidRenderFunction = (tag: Tag, box: MustacheBox, string: String?) -> Void


// =============================================================================
// MARK: - MustacheBox

public struct MustacheBox {
    public let isEmpty: Bool
    public let value: Any?
    public let mustacheBool: Bool
    public let objectForKeyedSubscript: SubscriptFunction?
    public let render: RenderFunction
    public let filter: FilterFunction?
    public let willRender: WillRenderFunction?
    public let didRender: DidRenderFunction?
    private let _intValue: (() -> Int?)?
    private let _uintValue: (() -> UInt?)?
    private let _doubleValue: (() -> Double?)?
    private let _arrayValue: (() -> [MustacheBox]?)?
    private let _dictionaryValue: (() -> [String: MustacheBox]?)?
    
    private init(
        mustacheBool: Bool? = nil,
        value: Any? = nil,
        intValue: (() -> Int?)? = nil,
        uintValue: (() -> UInt?)? = nil,
        doubleValue: (() -> Double?)? = nil,
        arrayValue: (() -> [MustacheBox]?)? = nil,
        dictionaryValue: (() -> [String: MustacheBox]?)? = nil,
        objectForKeyedSubscript: SubscriptFunction? = nil,
        filter: FilterFunction? = nil,
        render: RenderFunction? = nil,
        willRender: WillRenderFunction? = nil,
        didRender: DidRenderFunction? = nil)
    {
        let empty = (value == nil) && (objectForKeyedSubscript == nil) && (render == nil) && (filter == nil) && (willRender == nil) && (didRender == nil)
        self.isEmpty = empty
        self.value = value
        self._intValue = intValue
        self._uintValue = uintValue
        self._doubleValue = doubleValue
        self._arrayValue = arrayValue
        self._dictionaryValue = dictionaryValue
        self.mustacheBool = mustacheBool ?? !empty
        self.objectForKeyedSubscript = objectForKeyedSubscript
        self.filter = filter
        self.willRender = willRender
        self.didRender = didRender
        if let render = render {
            self.render = render
        } else {
            // Avoid compiler error: variable 'self.render' captured by a closure before being initialized
            self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
            self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                switch info.tag.type {
                case .Variable:
                    if let value = value {
                        return Rendering("\(value)")
                    } else {
                        return Rendering("")
                    }
                case .Section:
                    return info.tag.render(info.context.extendedContext(self), error: error)
                }
            }
        }
    }
}

public func Box(
    mustacheBool: Bool? = nil,
    value: Any? = nil,
    objectForKeyedSubscript: SubscriptFunction? = nil,
    filter: FilterFunction? = nil,
    render: RenderFunction? = nil,
    willRender: WillRenderFunction? = nil,
    didRender: DidRenderFunction? = nil) -> MustacheBox
{
    return MustacheBox(
        mustacheBool: mustacheBool,
        value: value,
        objectForKeyedSubscript: objectForKeyedSubscript,
        filter: filter,
        render: render,
        willRender: willRender,
        didRender: didRender)
}



// =============================================================================
// MARK: - MustacheBox derivation

extension MustacheBox {
    private func boxWithRenderFunction(render: RenderFunction) -> MustacheBox {
        return MustacheBox(
            mustacheBool: self.mustacheBool,
            value: self.value,
            intValue: self._intValue,
            uintValue: self._uintValue,
            doubleValue: self._doubleValue,
            arrayValue: self._arrayValue,
            dictionaryValue: self._dictionaryValue,
            objectForKeyedSubscript: self.objectForKeyedSubscript,
            filter: self.filter,
            render: render,
            willRender: self.willRender,
            didRender: self.didRender)
    }
    
    // Hackish helper function which helps us boxing NSArray and NSString: we
    // just box a regular [MustacheBox] or Swift String, and rewrite the value
    // to the original Objective-C value.
    private func boxWithValue(value: Any?) -> MustacheBox {
        return MustacheBox(
            mustacheBool: self.mustacheBool,
            value: value,
            intValue: self._intValue,
            uintValue: self._uintValue,
            doubleValue: self._doubleValue,
            arrayValue: self._arrayValue,
            dictionaryValue: self._dictionaryValue,
            objectForKeyedSubscript: self.objectForKeyedSubscript,
            filter: self.filter,
            render: self.render,
            willRender: self.willRender,
            didRender: self.didRender)
    }
}

public func Box(box: MustacheBox, # render: RenderFunction) -> MustacheBox {
    return box.boxWithRenderFunction(render)
}


// =============================================================================
// MARK: - Value unwrapping

extension MustacheBox {
    
    // If the boxed value is numerical (Swift numerical types, Bool, and
    // NSNumber), returns this value as an Int.
    public var intValue: Int? {
        if let intValue = _intValue {
            return intValue()
        } else {
            return nil
        }
    }
    
    // If the boxed value is numerical (Swift numerical types, Bool, and
    // NSNumber), returns this value as a UInt.
    public var uintValue: UInt? {
        if let uintValue = _uintValue {
            return uintValue()
        } else {
            return nil
        }
    }
    
    // If the boxed value is numerical (Swift numerical types, Bool, and
    // NSNumber), returns this value as a Double.
    public var doubleValue: Double? {
        if let doubleValue = _doubleValue {
            return doubleValue()
        } else {
            return nil
        }
    }
    
    // Returns the String description of the boxed value, or nil if there is
    // no value or if the value is NSNull.
    public var stringValue: String? {
        if value is NSNull {
            return nil
        } else if let value = value {
            return "\(value)"
        } else {
            return nil
        }
    }
    
    // If boxed value can be iterated (Swift collection, NSArray, NSSet, etc.),
    // returns a [MustacheBox].
    public var arrayValue: [MustacheBox]? {
        if let arrayValue = _arrayValue {
            return arrayValue()
        } else {
            return nil
        }
    }
    
    // If boxed value is a dictionary (Swift dictionary, NSDictionary, etc.),
    // returns a [String: MustacheBox] dictionary.
    public var dictionaryValue: [String: MustacheBox]? {
        if let dictionaryValue = _dictionaryValue {
            return dictionaryValue()
        } else {
            return nil
        }
    }

}


// =============================================================================
// MARK: - DebugPrintable

extension MustacheBox: DebugPrintable {
    
    public var debugDescription: String {
        if let value = value {
            return "MustacheBox(\(value))"  // remove "Optional" from the output
        } else {
            return "MustacheBox(nil)"
        }
    }
}


// =============================================================================
// MARK: - Key extraction

extension MustacheBox {
    
    subscript(key: String) -> MustacheBox {
        if let objectForKeyedSubscript = objectForKeyedSubscript {
            if let box = objectForKeyedSubscript(key: key) {
                return box
            }
        }
        return Box()
    }
}


// =============================================================================
// MARK: - Boxing of Core Mustache functions

public func Box(objectForKeyedSubscript: SubscriptFunction) -> MustacheBox {
    return MustacheBox(objectForKeyedSubscript: objectForKeyedSubscript)
}

public func Box(filter: FilterFunction) -> MustacheBox {
    return MustacheBox(filter: filter)
}

public func Box(render: RenderFunction) -> MustacheBox {
    return MustacheBox(render: render)
}

public func Box(willRender: WillRenderFunction) -> MustacheBox {
    return MustacheBox(willRender: willRender)
}

public func Box(didRender: DidRenderFunction) -> MustacheBox {
    return MustacheBox(didRender: didRender)
}


// =============================================================================
// MARK: - Boxing of Swift scalar types

public protocol MustacheBoxable {
    var mustacheBox: MustacheBox { get }
}

public func Box(boxable: MustacheBoxable?) -> MustacheBox {
    if let boxable = boxable {
        return boxable.mustacheBox
    } else {
        return Box()
    }
}

extension MustacheBox: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        return self
    }
}

extension Bool: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                // https://github.com/groue/GRMustache/issues/83
                //
                // {{# NSNumber }}...{{/}} renders the section if the number is
                // not zero, and does not push the number on the top of the
                // context stack.
                //
                // Be consistent with Objective-C, and make Bool behave just
                // like [NSNumber numberWithBool:]
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return MustacheBox(
            value: self,
            intValue: { self ? 1 : 0 },             // Behave like [NSNumber numberWithBool:]
            uintValue: { self ? 1 : 0 },            // Behave like [NSNumber numberWithBool:]
            doubleValue: { self ? 1.0 : 0.0 },      // Behave like [NSNumber numberWithBool:]
            mustacheBool: self,
            render: render)
    }
}

extension Int: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                // https://github.com/groue/GRMustache/issues/83
                //
                // {{# NSNumber }}...{{/}} renders the section if the number is
                // not zero, and does not push the number on the top of the
                // context stack.
                //
                // Be consistent with Objective-C, and make Int behave just
                // like [NSNumber numberWithInteger:]
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return MustacheBox(
            value: self,
            intValue: { self },
            uintValue: { UInt(self) },
            doubleValue: { Double(self) },
            mustacheBool: (self != 0),
            render: render)
    }
}

extension UInt: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                // https://github.com/groue/GRMustache/issues/83
                //
                // {{# NSNumber }}...{{/}} renders the section if the number is
                // not zero, and does not push the number on the top of the
                // context stack.
                //
                // Be consistent with Objective-C, and make Int behave just
                // like [NSNumber numberWithInteger:]
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return MustacheBox(
            value: self,
            intValue: { Int(self) },
            uintValue: { self },
            doubleValue: { Double(self) },
            mustacheBool: (self != 0),
            render: render)
    }
}

extension Double: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                // https://github.com/groue/GRMustache/issues/83
                //
                // {{# NSNumber }}...{{/}} renders the section if the number is
                // not zero, and does not push the number on the top of the
                // context stack.
                //
                // Be consistent with Objective-C, and make Double behave just
                // like [NSNumber numberWithDouble:]
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return MustacheBox(
            value: self,
            intValue: { Int(self) },
            uintValue: { UInt(self) },
            doubleValue: { self },
            mustacheBool: (self != 0.0),
            render: render)
    }
}

extension String: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        let objectForKeyedSubscript = { (key: String) -> MustacheBox? in
            switch key {
            case "length":
                return Box(countElements(self))
            default:
                return nil
            }
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                return info.tag.render(info.context.extendedContext(Box(self)), error: error)
            }
        }
        return Box(
            value: self,
            mustacheBool: (countElements(self) > 0),
            objectForKeyedSubscript: objectForKeyedSubscript,
            render: render)
    }
}


// =============================================================================
// MARK: - Boxing of Swift collections

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
// So if we could provide some support for rendering sequences, it is somewhat
// difficult: give up for now, and provide a boxing function for
// `CollectionType` which ensures non-destructive iteration.


private func renderCollection<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C, info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
    var buffer = ""
    var contentType: ContentType?
    let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
    for item in collection {
        let box = Box(item)
        if let boxRendering = box.render(info: enumerationRenderingInfo, error: error) {
            if contentType == nil {
                contentType = boxRendering.contentType
                buffer += boxRendering.string
            } else if contentType == boxRendering.contentType {
                buffer += boxRendering.string
            } else {
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
        return Rendering(buffer, contentType)
    } else {
        return info.tag.render(info.context, error: error)
    }
}

public func Box<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C?) -> MustacheBox {
    if let collection = collection {
        let count = distance(collection.startIndex, collection.endIndex)    // C.Index.Distance == Int
        return MustacheBox(
            mustacheBool: (count > 0),
            value: collection,
            arrayValue: { map(collection) { Box($0) } },
            objectForKeyedSubscript: { (key: String) -> MustacheBox? in
                switch key {
                case "count":
                    // Support for both Objective-C and Swift arrays.
                    return Box(count)
                    
                case "isEmpty":
                    // Support for Swift arrays.
                    return Box(count == 0)
                    
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
            render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(collection)), error: error)
                } else {
                    return renderCollection(collection, info, error)
                }
        })
    } else {
        return Box()
    }
}


// =============================================================================
// MARK: - Boxing of Swift dictionaries

public func Box<T: MustacheBoxable>(dictionary: [String: T]?) -> MustacheBox {
    if let dictionary = dictionary {
        
        return MustacheBox(
            mustacheBool: true,
            value: dictionary,
            dictionaryValue: {
                var boxDictionary: [String: MustacheBox] = [:]
                for (key, item) in dictionary {
                    boxDictionary[key] = Box(item)
                }
                return boxDictionary
            },
            objectForKeyedSubscript: { (key: String) -> MustacheBox? in
                return Box(dictionary[key])
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(dictionary)")
                case .Section:
                    return info.tag.render(info.context.extendedContext(Box(dictionary)), error: error)
                }
            }
        )
    } else {
        return Box()
    }
}


// =============================================================================
// MARK: - Boxing of Objective-C types

// The MustacheBoxable protocol can not be used by Objc classes, because MustacheBox is
// not compatible with ObjC. So let's define another protocol.
@objc public protocol ObjCMustacheBoxable {
    // Can not return a MustacheBox, because MustacheBox is not compatible with ObjC.
    // So let's return an ObjC object which wraps a MustacheBox.
    var mustacheBox: ObjCMustacheBox { get }
}

// The ObjC object which wraps a MustacheBox (see ObjCMustacheBoxable)
public class ObjCMustacheBox: NSObject {
    let box: MustacheBox
    init(_ box: MustacheBox) {
        self.box = box
    }
}

public func Box(boxable: ObjCMustacheBoxable?) -> MustacheBox {
    if let boxable = boxable {
        return boxable.mustacheBox.box
    } else {
        return Box()
    }
}

public func BoxAnyObject(object: AnyObject?) -> MustacheBox {
    if let object: AnyObject = object {
        if let boxable = object as? ObjCMustacheBoxable {
            return Box(boxable)
        } else {
            // This code path will only run if object is not a NSObject
            // instance, since NSObject conforms to ObjCMustacheBoxable.
            //
            // This may mean that the class of object is NSProxy or any other
            // Objective-C class that does not derive from NSObject.
            //
            // This may also mean that object is an instance of a pure Swift
            // class.
            //
            // Objective-C objects and containers can contain pure Swift
            // instances. For example, given the following array:
            //
            //     class C: MustacheBoxable { ... }
            //     var array = NSMutableArray()
            //     array.addObject(C())
            //
            // GRMustache *can not* known that the array contains a valid
            // boxable value, because NSArray exposes its contents as AnyObject,
            // and AnyObject can not be tested for MustacheBoxable conformance:
            //
            // https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html#//apple_ref/doc/uid/TP40014097-CH25-XID_363
            // > you need to mark your protocols with the @objc attribute if you want to be able to check for protocol conformance.
            //
            // So GRMustache, when given an AnyObject, generally assumes that it
            // is an Objective-C value, even when it is wrong, and ends up here.
            //
            // As a conclusion: let's apologize.
            //
            // TODO: document caveat with something like:
            //
            // If GRMustache.BoxAnyObject was called from your own code, check
            // the type of the value you provide. If not, it is likely that an
            // Objective-C collection like NSArray, NSDictionary, NSSet or any
            // other Objective-C object contains a value that is not an
            // Objective-C object. GRMustache does not support such mixing of
            // Objective-C and Swift values.
            NSLog("Mustache.BoxAnyObject(): value `\(object)` does not conform to the ObjCMustacheBoxable protocol, and is discarded.")
            return Box()
        }
    } else {
        return Box()
    }
}

/**
Conform to the GRMustacheSafeKeyAccess protocol in order to filter the keys that
can be accessed by GRMustache templates.
*/
@objc public protocol GRMustacheSafeKeyAccess {

    /**
    List the name of the keys GRMustache.swift can access on this class using
    the `valueForKey:` method.

    When objects do not respond to this method, only declared properties can be
    accessed. All properties of Core Data NSManagedObjects are also accessible,
    even without property declaration.

    This method is not used for objects responding to objectForKeyedSubscript:.
    For those objects, all keys are accessible from templates.

    @return The set of accessible keys on the class.
    */
    class func safeMustacheKeys() -> NSSet
}

extension NSObject: ObjCMustacheBoxable {
    public var mustacheBox: ObjCMustacheBox {
        if let enumerable = self as? NSFastEnumeration
        {
            // Enumerable
            
            if respondsToSelector("objectForKeyedSubscript:")
            {
                // Dictionary-like enumerable
                
                return ObjCMustacheBox(MustacheBox(
                    mustacheBool: true,
                    value: self,
                    dictionaryValue: {
                        var boxDictionary: [String: MustacheBox] = [:]
                        for key in GeneratorSequence(NSFastGenerator(enumerable)) {
                            if let key = key as? String {
                                let item = (self as AnyObject)[key] // Cast to AnyObject so that we can access subscript notation.
                                boxDictionary[key] = BoxAnyObject(item)
                            }
                        }
                        return boxDictionary
                    },
                    objectForKeyedSubscript: { (key: String) -> MustacheBox? in
                        let item = (self as AnyObject)[key] // Cast to AnyObject so that we can access subscript notation.
                        return BoxAnyObject(item)
                    },
                    render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                        switch info.tag.type {
                        case .Variable:
                            return Rendering("\(self)")
                        case .Section:
                            return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                        }
                    }
                ))
            }
            else
            {
                // Array-like enumerable
                
                let array = map(GeneratorSequence(NSFastGenerator(enumerable))) { BoxAnyObject($0) }
                let box = Box(array).boxWithValue(self)
                return ObjCMustacheBox(box)
            }
        }
        else
        {
            // Generic NSObject
            
            return ObjCMustacheBox(MustacheBox(
                mustacheBool: true,
                value: self,
                objectForKeyedSubscript: { (key: String) -> MustacheBox? in
                    if self.respondsToSelector("objectForKeyedSubscript:")
                    {
                        // Use objectForKeyedSubscript: first (see https://github.com/groue/GRMustache/issues/66:)
                        return BoxAnyObject((self as AnyObject)[key]) // Cast to AnyObject so that we can access subscript notation.
                    }
                    else if GRMustacheKeyAccess.isSafeMustacheKey(key, forObject: self)
                    {
                        // Use valueForKey: for safe keys
                        return BoxAnyObject(self.valueForKey(key))
                    }
                    else
                    {
                        // Missing key
                        return Box()
                    }
                },
                render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                    switch info.tag.type {
                    case .Variable:
                        return Rendering("\(self)")
                    case .Section:
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    }
            }))
        }
    }
}

extension NSNull: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(MustacheBox(
            mustacheBool: false,
            value: self,
            render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                switch info.tag.type {
                case .Variable:
                    return Rendering("")
                case .Section:
                    if info.enumerationItem {
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        return info.tag.render(info.context, error: error)
                    }
                }
        }))
    }
}

extension NSNumber: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return ObjCMustacheBox(MustacheBox(
            value: self,
            intValue: { self.integerValue },
            uintValue: { UInt(self.unsignedIntegerValue) }, // Oddly, -[NSNumber unsignedIntegerValue] returns an Int
            doubleValue: { self.doubleValue },
            mustacheBool: self.boolValue,
            render: render))
    }
}

extension NSString: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(Box(self as String).boxWithValue(self))
    }
}

extension NSSet: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(MustacheBox(
            mustacheBool: (self.count > 0),
            value: self,
            arrayValue: { map(GeneratorSequence(NSFastGenerator(self))) { BoxAnyObject($0) } },
            objectForKeyedSubscript: { (key: String) -> MustacheBox? in
                switch key {
                case "isEmpty":
                    return Box(self.count == 0)
                case "count":
                    return Box(self.count)
                case "anyObject":
                    return BoxAnyObject(self.anyObject())
                default:
                    return nil
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    let boxArray = map(GeneratorSequence(NSFastGenerator(self))) { BoxAnyObject($0) }
                    return renderCollection(boxArray, info, error)
                }
            }))
    }
}
