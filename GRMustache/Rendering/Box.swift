//
//  Box.swift
//  GRMustache
//
//  Created by Gwendal Roué on 08/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//



// =============================================================================
// MARK: - Core function types

public typealias SubscriptFunction = (key: String) -> Box?
public typealias FilterFunction = (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box?
public typealias RenderFunction = (info: RenderingInfo, error: NSErrorPointer) -> Rendering?
public typealias WillRenderFunction = (tag: Tag, box: Box) -> Box
public typealias DidRenderFunction = (tag: Tag, box: Box, string: String?) -> Void


// =============================================================================
// MARK: - Box

public struct Box {
    public let isEmpty: Bool
    public let value: Any?
    public let mustacheBool: Bool
    public let objectForKeyedSubscript: SubscriptFunction?
    public private(set) var render: RenderFunction  // It should be a `let` property. But compilers spawns unwanted "variable 'self.render' captured by a closure before being initialized" errors that we work around by modifying this property (see below). Hence the `var`.
    public let filter: FilterFunction?
    public let willRender: WillRenderFunction?
    public let didRender: DidRenderFunction?
    
    private init(value: Any? = nil, mustacheBool: Bool? = nil, objectForKeyedSubscript: SubscriptFunction? = nil, render: RenderFunction? = nil, filter: FilterFunction? = nil, willRender: WillRenderFunction? = nil, didRender: DidRenderFunction? = nil) {
        let empty = (value == nil) && (objectForKeyedSubscript == nil) && (render == nil) && (filter == nil) && (willRender == nil) && (didRender == nil)
        self.isEmpty = empty
        self.value = value
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
    
    public static var empty: Box {
        return Box.empty
    }
}

public func boxValue(value: Any? = nil, mustacheBool: Bool? = nil, objectForKeyedSubscript: SubscriptFunction? = nil, render: RenderFunction? = nil, filter: FilterFunction? = nil, willRender: WillRenderFunction? = nil, didRender: DidRenderFunction? = nil) -> Box {
    return Box(value: value, mustacheBool: mustacheBool, objectForKeyedSubscript: objectForKeyedSubscript, render: render, filter: filter, willRender: willRender, didRender: didRender)
}



// =============================================================================
// MARK: - Box derivation

extension Box {
    // TODO: find better name
    public func boxWithRenderFunction(render: RenderFunction) -> Box {
        return Box(
            value: self.value,
            mustacheBool: self.mustacheBool,
            objectForKeyedSubscript: self.objectForKeyedSubscript,
            render: render,
            filter: self.filter,
            willRender: self.willRender,
            didRender: self.didRender)
    }
    
}



// =============================================================================
// MARK: - Box unwrapping

extension Box {
    
    public var intValue: Int? {
        if let int = value as? Int {
            return int
        } else if let double = value as? Double {
            return Int(double)
        } else {
            return nil
        }
    }
    
    public var doubleValue: Double? {
        if let int = value as? Int {
            return Double(int)
        } else if let double = value as? Double {
            return double
        } else {
            return nil
        }
    }
    
    public var stringValue: String? {
        if value is NSNull {
            return nil
        } else if let value = value {
            return "\(value)"
        } else {
            return nil
        }
    }
}

// =============================================================================
// MARK: - DebugPrintable

extension Box: DebugPrintable {
    
    public var debugDescription: String {
        if let value = value {
            return "Box(\(value))"  // remove the "Optional" in the output
        } else {
            return "Box(\(value))"
        }
    }
}


// =============================================================================
// MARK: - Key extraction

extension Box {
    
    subscript(key: String) -> Box {
        if let objectForKeyedSubscript = objectForKeyedSubscript {
            if let box = objectForKeyedSubscript(key: key) {
                return box
            }
        }
        return Box.empty
    }
}


// =============================================================================
// MARK: - Boxing of Core Mustache functions

public func boxValue(objectForKeyedSubscript: SubscriptFunction) -> Box {
    return Box(objectForKeyedSubscript: objectForKeyedSubscript)
}

public func boxValue(filter: FilterFunction) -> Box {
    return Box(filter: filter)
}

public func boxValue(render: RenderFunction) -> Box {
    return Box(render: render)
}

public func boxValue(willRender: WillRenderFunction) -> Box {
    return Box(willRender: willRender)
}

public func boxValue(didRender: DidRenderFunction) -> Box {
    return Box(didRender: didRender)
}


// =============================================================================
// MARK: - Boxing of Swift scalar types

public protocol MustacheBoxable {
    var mustacheBox: Box { get }
}

public func boxValue<T: MustacheBoxable>(boxable: T?) -> Box {
    if let boxable = boxable {
        return boxable.mustacheBox
    } else {
        return Box.empty
    }
}

extension Box: MustacheBoxable {
    public var mustacheBox: Box {
        return self
    }
}

extension Bool: MustacheBoxable {
    public var mustacheBox: Box {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return Box(
            value: self,
            mustacheBool: self,
            render: render)
    }
}

extension Int: MustacheBoxable {
    public var mustacheBox: Box {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return Box(
            value: self,
            mustacheBool: (self != 0),
            render: render)
    }
}

extension Double: MustacheBoxable {
    public var mustacheBox: Box {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return Box(
            value: self,
            mustacheBool: (self != 0.0),
            render: render)
    }
}

extension String: MustacheBoxable {
    public var mustacheBox: Box {
        let objectForKeyedSubscript = { (key: String) -> Box? in
            switch key {
            case "length":
                return boxValue(countElements(self))
            default:
                return nil
            }
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
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
// MARK: - Boxing of Swift sequences & collections

public func boxValue<S: SequenceType where S.Generator.Element: MustacheBoxable>(sequence: S?) -> Box {
    // TODO: test this method
    if let sequence = sequence {
        var boxSequence = map(sequence) { boxValue($0) }
        var emptySequence: Bool {
            for x in sequence {
                return false
            }
            return true
        }
        return Box(
            value: boxSequence,
            mustacheBool: !emptySequence,
            render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(boxValue(sequence)), error: error)
                } else {
                    var buffer = ""
                    var contentType: ContentType?
                    let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                    for itemBox in boxSequence {
                        if let itemRendering = itemBox.render(info: enumerationRenderingInfo, error: error) {
                            if contentType == nil {
                                contentType = itemRendering.contentType
                                buffer += itemRendering.string
                            } else if contentType == itemRendering.contentType {
                                buffer += itemRendering.string
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
        })
    } else {
        return Box.empty
    }
}

public func boxValue<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C?) -> Box {
    if let collection = collection {
        var boxCollection = map(collection) { boxValue($0) }
        let count = countElements(collection)   // T.Index.Distance == Int
        return Box(
            value: boxCollection,
            mustacheBool: (count > 0),
            objectForKeyedSubscript: { (key: String) -> Box? in
                switch key {
                case "count":
                    return boxValue(count)
                case "firstObject":
                    if count > 0 {
                        return boxValue(collection[collection.startIndex])
                    } else {
                        return Box.empty
                    }
                case "lastObject":
                    if count > 0 {
                        return boxValue(collection[collection.endIndex.predecessor()])    // T.Index: BidirectionalIndexType
                    } else {
                        return Box.empty
                    }
                default:
                    return Box.empty
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(boxValue(collection)), error: error)
                } else {
                    var buffer = ""
                    var contentType: ContentType?
                    let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                    for itemBox in boxCollection {
                        if let boxRendering = itemBox.render(info: enumerationRenderingInfo, error: error) {
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
        })
    } else {
        return Box.empty
    }
}


// =============================================================================
// MARK: - Boxing of Swift dictionaries

public func boxValue<T: MustacheBoxable>(dictionary: [String: T]?) -> Box {
    if let dictionary = dictionary {
        var boxDictionary: [String: Box] = [:]
        for (key, item) in dictionary {
            boxDictionary[key] = boxValue(item)
        }
        return Box(
            value: boxDictionary,
            mustacheBool: true,
            objectForKeyedSubscript: { (key: String) -> Box? in
                return boxDictionary[key]
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(boxDictionary)")
                case .Section:
                    return info.tag.render(info.context.extendedContext(boxValue(dictionary)), error: error)
                }
            }
        )
    } else {
        return Box.empty
    }
}


// =============================================================================
// MARK: - Boxing of Objective-C types

// The MustacheBoxable protocol can not be used by Objc classes, because Box is
// not compatible with ObjC. So let's define another protocol.
@objc public protocol ObjCMustacheBoxable {
    // Can not return a Box, because Box is not compatible with ObjC.
    // So let's return an ObjC object which wraps a Box.
    var mustacheBoxWrapper: ObjCBoxWrapper { get }
}

// The ObjC object which wraps a Box (see ObjCMustacheBoxable)
public class ObjCBoxWrapper: NSObject {
    let box: Box
    init(_ box: Box) {
        self.box = box
    }
}

public func boxValue(boxable: ObjCMustacheBoxable?) -> Box {
    if let boxable = boxable {
        return boxable.mustacheBoxWrapper.box
    } else {
        return Box.empty
    }
}

extension NSObject: ObjCMustacheBoxable {
    public var mustacheBoxWrapper: ObjCBoxWrapper {
        if let enumerable = self as? NSFastEnumeration {
            if respondsToSelector("objectAtIndexedSubscript:") {
                // Array
                var array: [Box] = []
                let generator = NSFastGenerator(enumerable)
                while true {
                    if let item: AnyObject = generator.next() {
                        var itemBox: Box = Box.empty
                        if let item = item as? ObjCMustacheBoxable {
                            itemBox = boxValue(item)
                        }
                        array.append(itemBox)
                    } else {
                        break
                    }
                }
                return ObjCBoxWrapper(boxValue(array))
            } else if respondsToSelector("objectForKeyedSubscript:") {
                // Dictionary
                var dictionary: [String: Box] = [:]
                let generator = NSFastGenerator(enumerable)
                while true {
                    if let key = generator.next() as? String {
                        let item = (self as AnyObject)[key]
                        var itemBox: Box = Box.empty
                        if let item = item as? ObjCMustacheBoxable {
                            itemBox = boxValue(item)
                        }
                        dictionary[key] = itemBox
                    } else {
                        break
                    }
                }
                return ObjCBoxWrapper(boxValue(dictionary))
            } else {
                // Set
                var set = NSMutableSet()
                let generator = NSFastGenerator(enumerable)
                while true {
                    if let object: AnyObject = generator.next() {
                        set.addObject(object)
                    } else {
                        break
                    }
                }
                return ObjCBoxWrapper(boxValue(set))
            }
            
        } else {
            return ObjCBoxWrapper(Box(
                value: self,
                mustacheBool: true,
                objectForKeyedSubscript: { (key: String) -> Box? in
                    if let value = self.valueForKey(key) as? ObjCMustacheBoxable {
                        return boxValue(value)
                    } else {
                        return Box.empty
                    }
                },
                render: { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                    switch info.tag.type {
                    case .Variable:
                        return Rendering("\(self)")
                    case .Section:
                        return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
                    }
            }))
        }
    }
}

extension NSNull: ObjCMustacheBoxable {
    public override var mustacheBoxWrapper: ObjCBoxWrapper {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return ObjCBoxWrapper(Box(
            value: self,
            mustacheBool: false,
            render: render))
    }
}

extension NSNumber: ObjCMustacheBoxable {
    public override var mustacheBoxWrapper: ObjCBoxWrapper {
        switch String.fromCString(objCType)! {
        case "c", "i", "s", "l", "q", "C", "I", "S", "L", "Q":
            return ObjCBoxWrapper(boxValue(Int(longLongValue)))
        case "f", "d":
            return ObjCBoxWrapper(boxValue(doubleValue))
        case "B":
            return ObjCBoxWrapper(boxValue(boolValue))
        default:
            fatalError("Not implemented yet")
        }
    }
}

extension NSString: ObjCMustacheBoxable {
    public override var mustacheBoxWrapper: ObjCBoxWrapper {
        return ObjCBoxWrapper(boxValue(self as String))
    }
}

extension NSSet: ObjCMustacheBoxable {
    public override var mustacheBoxWrapper: ObjCBoxWrapper {
        let objectForKeyedSubscript = { (key: String) -> Box? in
            switch key {
            case "count":
                return boxValue(self.count)
            case "anyObject":
                if let any = self.anyObject() as? ObjCMustacheBoxable {
                    return boxValue(any)
                } else {
                    return Box.empty
                }
            default:
                return nil
            }
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(boxValue(self)), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for item in self {
                    var itemBox: Box = Box.empty
                    if let item = item as? ObjCMustacheBoxable {
                        itemBox = boxValue(item)
                    }
                    if let boxRendering = itemBox.render(info: enumerationRenderingInfo, error: error) {
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
                    switch info.tag.type {
                    case .Variable:
                        return Rendering("")
                    case .Section:
                        return info.tag.render(info.context, error: error)
                    }
                }
            }
        }
        return ObjCBoxWrapper(Box(
            value: self,
            mustacheBool: (self.count > 0),
            objectForKeyedSubscript: objectForKeyedSubscript,
            render: render))
    }
}
