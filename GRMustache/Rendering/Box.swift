//
//  Box.swift
//  GRMustache
//
//  Created by Gwendal Roué on 08/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//



// =============================================================================
// MARK: - Core function types

public typealias InspectFunction = (key: String) -> Box?
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
    public let inspect: InspectFunction?
    public private(set) var render: RenderFunction  // It should be a `let` property. But compilers spawns unwanted "variable 'self.render' captured by a closure before being initialized" errors that we work around by modifying this property (see below). Hence the `var`.
    public let filter: FilterFunction?
    public let willRender: WillRenderFunction?
    public let didRender: DidRenderFunction?
    
    public init(value: Any? = nil, mustacheBool: Bool? = nil, inspect: InspectFunction? = nil, render: RenderFunction? = nil, filter: FilterFunction? = nil, willRender: WillRenderFunction? = nil, didRender: DidRenderFunction? = nil) {
        let empty = (value == nil) && (inspect == nil) && (render == nil) && (filter == nil) && (willRender == nil) && (didRender == nil)
        self.isEmpty = empty
        self.value = value
        self.mustacheBool = mustacheBool ?? !empty
        self.inspect = inspect
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


// =============================================================================
// MARK: - Box derivation

extension Box {
    // TODO: find better name
    public func boxWithRenderFunction(render: RenderFunction) -> Box {
        return Box(
            value: self.value,
            mustacheBool: self.mustacheBool,
            inspect: self.inspect,
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
        return "Box\(value)"
    }
}


// =============================================================================
// MARK: - Key extraction

extension Box {
    
    subscript(key: String) -> Box {
        if let inspect = inspect {
            if let box = inspect(key: key) {
                return box
            }
        }
        return Box()
    }
}


// =============================================================================
// MARK: - Support for built-in types

extension Box {
    
    public init(_ bool: Bool) {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(bool)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(bool)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        self.init(
            value: bool,
            mustacheBool: bool,
            render: render)
    }
    
    public init(_ int: Int) {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(int)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(int)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        self.init(
            value: int,
            mustacheBool: (int != 0),
            render: render)
    }
    
    public init(_ double: Double) {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(double)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(double)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        self.init(
            value: double,
            mustacheBool: (double != 0.0),
            render: render)
    }
    
    public init(_ string: String) {
        let inspect = { (key: String) -> Box? in
            switch key {
            case "length":
                return Box(countElements(string))
            default:
                return nil
            }
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(string)")
            case .Section:
                return info.tag.render(info.context.extendedContext(Box(string)), error: error)
            }
        }
        self.init(
            value: string,
            mustacheBool: (countElements(string) > 0),
            inspect: inspect,
            render: render)
    }
    
    public init(_ null: NSNull) {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(null)), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        self.init(
            value: null,
            mustacheBool: false,
            render: render)
    }
    
    public init(_ number: NSNumber) {
        let objCType = number.objCType
        let str = String.fromCString(objCType)
        switch str! {
        case "c", "i", "s", "l", "q", "C", "I", "S", "L", "Q":
            self.init(Int(number.longLongValue))
        case "f", "d":
            self.init(number.doubleValue)
        case "B":
            self.init(number.boolValue)
        default:
            fatalError("Not implemented yet")
        }
    }
    
    public init(_ set: NSSet) {
        let inspect = { (key: String) -> Box? in
            switch key {
            case "count":
                return Box(set.count)
            case "anyObject":
                return Box(set.anyObject())
            default:
                return nil
            }
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(Box(set)), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for object in set {
                    if let boxRendering = Box(object).render(info: enumerationRenderingInfo, error: error) {
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
        self.init(
            value: set,
            mustacheBool: (set.count > 0),
            inspect: inspect,
            render: render)
    }
    
    public init(_ dictionary: [String: Box]) {
        self.isEmpty = false
        self.value = dictionary
        self.mustacheBool = true
        self.inspect = { (key: String) -> Box? in
            return dictionary[key]
        }
        // Avoid compiler error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(dictionary)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
    }
    
    public init<T: SequenceType where T.Generator.Element == Box>(_ sequence: T) {
        var emptySequence: Bool {
            for x in sequence {
                return false
            }
            return true
        }
        self.isEmpty = false
        self.value = sequence
        self.mustacheBool = !emptySequence
        // Avoid compiler error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(self), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for box in sequence {
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
        }
    }
    
    public init<T: CollectionType where T.Generator.Element == Box, T.Index: BidirectionalIndexType, T.Index.Distance == Int>(_ collection: T) {
        self.isEmpty = false
        self.value = collection
        self.mustacheBool = (countElements(collection) > 0)
        self.inspect = { (key: String) -> Box? in
            switch key {
            case "count":
                return Box(countElements(collection))   // T.Index.Distance == Int
            case "firstObject":
                if countElements(collection) > 0 {
                    return collection[collection.startIndex]
                } else {
                    return Box()
                }
            case "lastObject":
                if countElements(collection) > 0 {
                    return collection[collection.endIndex.predecessor()]    // T.Index: BidirectionalIndexType
                } else {
                    return Box()
                }
            default:
                return Box()
            }
        }
        // Avoid compiler error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(self), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for box in collection {
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
        }
    }
    
    public init(_ object: AnyObject?) {
        if let object: AnyObject = object {
            if let null = object as? NSNull {
                self.init(null)
                
            } else if let number = object as? NSNumber {
                self.init(number)
                
            } else if let set = object as? NSSet {
                self.init(set)
                
            } else if let string = object as? String {
                self.init(string)
                
            } else if let object = object as? NSObjectProtocol {
                if let enumerable = object as? NSFastEnumeration {
                    if object.respondsToSelector("objectAtIndexedSubscript:") {
                        // Array
                        var array: [Box] = []
                        let generator = NSFastGenerator(enumerable)
                        while true {
                            if let item: AnyObject = generator.next() {
                                array.append(Box(item))
                            } else {
                                break
                            }
                        }
                        self.init(array)
                    } else if object.respondsToSelector("objectForKeyedSubscript:") {
                        // Dictionary
                        var dictionary: [String: Box] = [:]
                        let generator = NSFastGenerator(enumerable)
                        while true {
                            if let key = generator.next() as? String {
                                dictionary[key] = Box((object as AnyObject)[key])
                            } else {
                                break
                            }
                        }
                        self.init(dictionary)
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
                        self.init(set)
                    }
                    
                } else if let object = object as? NSObject {
                    self.init(object)
                    
                } else {
                    fatalError("\(object) can not be boxed.")
                }
                
            } else {
                fatalError("\(object) can not be boxed.")
            }
            
        } else {
            self.init()
        }
    }

    private init(_ object: NSObject) {
        self.isEmpty = false
        self.value = object
        self.mustacheBool = true
        self.inspect = { (key: String) -> Box? in
            return Box(object.valueForKey(key))
        }
        // Avoid compiler error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(object)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
    }
    
}
