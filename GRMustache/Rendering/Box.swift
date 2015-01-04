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
// MARK: - Filters

// Single argument filter
public func Filter(filter: (Box, NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else {
            return filter(argument, error)
        }
    }
}

// Single argument filter with generic unboxing
public func Filter<T>(filter: (T?, NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.value as? T {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Single argument filter with Int conversion (see intValue)
public func Filter(filter: (Int?, NSErrorPointer) -> Box?) -> FilterFunction {
    // TODO: test
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.intValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Single argument filter with Double conversion (see doubleValue)
public func Filter(filter: (Double?, NSErrorPointer) -> Box?) -> FilterFunction {
    // TODO: test
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.doubleValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Single argument filter with String conversion (see stringValue)
public func Filter(filter: (String?, NSErrorPointer) -> Box?) -> FilterFunction {
    // TODO: test
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.stringValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Variadic filter
public func MakeVariadicFilter(filter: (arguments: [Box], error: NSErrorPointer) -> Box?) -> FilterFunction {
    return MakePartialVariadicFilter([], filter)
}

private func MakePartialVariadicFilter(arguments: [Box], filter: (arguments: [Box], error: NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        let arguments = arguments + [argument]
        if partialApplication {
            return Box(MakePartialVariadicFilter(arguments, filter))
        } else {
            return filter(arguments: arguments, error: error)
        }
    }
}

// Single argument filter for custom rendering
public func Filter(filter: (Box, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (box: Box, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(box, info, error)
        })
    })
}

// Single argument filter with generic unboxing for custom rendering
public func Filter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (t: T?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(t, info, error)
        })
    })
}

// Single argument filter with Int conversion (see intValue) for custom rendering
public func Filter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (int: Int?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(int, info, error)
        })
    })
}

// Single argument filter with Double conversion (see doubleValue) for custom rendering
public func Filter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (double: Double?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(double, info, error)
        })
    })
}

// Single argument filter with String conversion (see stringValue) for custom rendering
public func Filter(filter: (String?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (string: String?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(string, info, error)
        })
    })
}


// =============================================================================
// MARK: - Box

public protocol MustacheBoxable {
    func mustacheBox() -> Box
}

public struct Box {
    public let isEmpty: Bool
    public let value: Any?
    public let mustacheBool: Bool
    public let inspect: InspectFunction?
    public private(set) var render: RenderFunction  // It should be a `let` property. But compilers spawns unwanted "variable 'self.render' captured by a closure before being initialized" errors that we work around by modifying this property (see below). Hence the `var`.
    public let filter: FilterFunction?
    public let willRender: WillRenderFunction?
    public let didRender: DidRenderFunction?
    
    // True if only willRender or didRender are non nil.
    let isHook: Bool
    
    public init(value: Any? = nil, mustacheBool: Bool? = nil, inspect: InspectFunction? = nil, render: RenderFunction? = nil, filter: FilterFunction? = nil, willRender: WillRenderFunction? = nil, didRender: DidRenderFunction? = nil) {
        let hasHook = willRender != nil || didRender != nil
        let hasNonHook = value != nil || inspect != nil || render != nil || filter != nil
        let empty = !hasHook && !hasNonHook
        
        self.isEmpty = empty
        self.isHook = hasHook && !hasNonHook
        self.value = value
        self.mustacheBool = mustacheBool ?? !empty
        self.inspect = inspect
        if let render = render {
            self.render = render
        } else {
            // Avoid error: variable 'self.render' captured by a closure before being initialized
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
        self.filter = filter
        self.willRender = willRender
        self.didRender = didRender
    }
    
    public init(_ box: Box) {
        isEmpty = box.isEmpty
        isHook = box.isHook
        value = box.value
        mustacheBool = box.mustacheBool
        inspect = box.inspect
        render = box.render
        filter = box.filter
        willRender = box.willRender
        didRender = box.didRender
    }
    
    public init(_ dictionary: [String: Box]) {
        self.isEmpty = false
        self.isHook = false
        self.value = dictionary
        self.mustacheBool = true
        self.inspect = { (key: String) -> Box? in
            return dictionary[key]
        }
        // Avoid error: variable 'self.render' captured by a closure before being initialized
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
        self.isHook = false
        self.value = sequence
        self.mustacheBool = !emptySequence
        // Avoid error: variable 'self.render' captured by a closure before being initialized
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
        self.isHook = false
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
        // Avoid error: variable 'self.render' captured by a closure before being initialized
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
    
    public init(_ filter: FilterFunction) {
        self.isEmpty = false
        self.isHook = false
        self.value = filter
        self.mustacheBool = true
        self.filter = filter
        // Avoid error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(filter)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
    }
    
    public init(_ inspect: InspectFunction) {
        self.isEmpty = false
        self.isHook = false
        self.value = inspect
        self.mustacheBool = true
        self.inspect = inspect
        // Avoid error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(inspect)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
    }
    
    public init(_ render: RenderFunction) {
        self.isEmpty = false
        self.isHook = false
        self.value = render
        self.mustacheBool = true
        self.render = render
    }
    
    public init(_ willRender: WillRenderFunction) {
        self.isEmpty = false
        self.isHook = true
        self.value = willRender
        self.mustacheBool = true
        // Avoid error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(willRender)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
        self.willRender = willRender
    }
    
    public init(_ didRender: DidRenderFunction) {
        self.isEmpty = false
        self.isHook = true
        self.value = didRender
        self.mustacheBool = true
        // Avoid error: variable 'self.render' captured by a closure before being initialized
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(didRender)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
        self.didRender = didRender
    }
    
    private init(_ object: NSObject) {
        self.isEmpty = false
        self.isHook = false
        self.value = object
        self.mustacheBool = true
        self.inspect = { (key: String) -> Box? in
            return Box(object.valueForKey(key))
        }
        // Avoid error: variable 'self.render' captured by a closure before being initialized
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
    
    public init(_ object: AnyObject?) {
        if let object: AnyObject = object {
            if let null = object as? NSNull {
                self.init(null.mustacheBox())
                
            } else if let number = object as? NSNumber {
                self.init(number.mustacheBox())
                
            } else if let set = object as? NSSet {
                self.init(set.mustacheBox())
                
            } else if let string = object as? String {
                self.init(string.mustacheBox())
                
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
                        self.init(set.mustacheBox())
                    }
                    
                } else if let object = object as? NSObject {
                    self.init(object)
                    
                } else {
                    fatalError("\(object) can not be boxed. Check that it conforms to the MustacheBoxable protocol.")
                }
                
            } else {
                fatalError("\(object) can not be boxed. Check that it conforms to the MustacheBoxable protocol, and that it is not an optional.")
            }
            
        } else {
            self.init()
        }
    }
    
    public init<T: MustacheBoxable>(_ boxable: T) {
        self.init(boxable.mustacheBox())
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

extension Bool: MustacheBoxable {
    public func mustacheBox() -> Box {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.mustacheBox()), error: error)
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
    public func mustacheBox() -> Box {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.mustacheBox()), error: error)
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
    public func mustacheBox() -> Box {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.mustacheBox()), error: error)
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
    public func mustacheBox() -> Box {
        let inspect = { (key: String) -> Box? in
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
                return info.tag.render(info.context.extendedContext(self.mustacheBox()), error: error)
            }
        }
        return Box(
            value: self,
            mustacheBool: (countElements(self) > 0),
            inspect: inspect,
            render: render)
    }
}

extension NSNull: MustacheBoxable {
    public func mustacheBox() -> Box {
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.mustacheBox()), error: error)
                } else {
                    return info.tag.render(info.context, error: error)
                }
            }
        }
        return Box(
            value: self,
            mustacheBool: false,
            render: render)
    }
}

extension NSNumber: MustacheBoxable {
    public func mustacheBox() -> Box {
        let objCType = self.objCType
        let str = String.fromCString(objCType)
        switch str! {
        case "c", "i", "s", "l", "q", "C", "I", "S", "L", "Q":
            return Box(Int(longLongValue))
        case "f", "d":
            return Box(doubleValue)
        case "B":
            return Box(boolValue)
        default:
            fatalError("Not implemented yet")
        }
    }
}

extension NSSet: MustacheBoxable {
    public func mustacheBox() -> Box {
        let inspect = { (key: String) -> Box? in
            switch key {
            case "count":
                return Box(self.count)
            case "anyObject":
                return Box(self.anyObject())
            default:
                return nil
            }
        }
        let render = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(self.mustacheBox()), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for object in self {
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
        return Box(
            value: self,
            mustacheBool: (self.count > 0),
            inspect: inspect,
            render: render)
    }
}