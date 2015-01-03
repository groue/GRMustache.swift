//
//  Box.swift
//  GRMustache
//
//  Created by Gwendal Roué on 08/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//



// =============================================================================
// MARK: - Core function types

// Key Extraction
public typealias Inspector = (key: String) -> Box?

// Filter
public typealias Filter = (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box?

// Rendering
public typealias Renderer = (info: RenderingInfo, error: NSErrorPointer) -> Rendering?

// Pre-rendering hook
public typealias PreRenderer = (tag: Tag, box: Box) -> Box

// Post-rendering hook
public typealias PostRenderer = (tag: Tag, box: Box, string: String?) -> Void


// =============================================================================
// MARK: - Filters

// Single argument filter
public func MakeFilter(filter: (Box, NSErrorPointer) -> Box?) -> Filter {
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
public func MakeFilter<T>(filter: (T?, NSErrorPointer) -> Box?) -> Filter {
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
public func MakeFilter(filter: (Int?, NSErrorPointer) -> Box?) -> Filter {
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
public func MakeFilter(filter: (Double?, NSErrorPointer) -> Box?) -> Filter {
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
public func MakeFilter(filter: (String?, NSErrorPointer) -> Box?) -> Filter {
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
public func MakeVariadicFilter(filter: (arguments: [Box], error: NSErrorPointer) -> Box?) -> Filter {
    return MakePartialVariadicFilter([], filter)
}

private func MakePartialVariadicFilter(arguments: [Box], filter: (arguments: [Box], error: NSErrorPointer) -> Box?) -> Filter {
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
public func MakeFilter(filter: (Box, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (box: Box, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(box, info, error)
        })
    })
}

// Single argument filter with generic unboxing for custom rendering
public func MakeFilter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (t: T?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(t, info, error)
        })
    })
}

// Single argument filter with Int conversion (see intValue) for custom rendering
public func MakeFilter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (int: Int?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(int, info, error)
        })
    })
}

// Single argument filter with Double conversion (see doubleValue) for custom rendering
public func MakeFilter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (double: Double?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(double, info, error)
        })
    })
}

// Single argument filter with String conversion (see stringValue) for custom rendering
public func MakeFilter(filter: (String?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (string: String?, error: NSErrorPointer) -> Box? in
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
    public let inspector: Inspector?
    public private(set) var renderer: Renderer  // It should be a `let` property. But compilers spawns unwanted "variable 'self.renderer' captured by a closure before being initialized" errors that we work around by modifying this property (see below). Hence the `var`.
    public let filter: Filter?
    public let preRenderer: PreRenderer?
    public let postRenderer: PostRenderer?
    
    // True if only preRenderer or postRenderer are non nil.
    let isHook: Bool
    
    public init(value: Any? = nil, mustacheBool: Bool? = nil, inspector: Inspector? = nil, renderer: Renderer? = nil, filter: Filter? = nil, preRenderer: PreRenderer? = nil, postRenderer: PostRenderer? = nil) {
        let hasHook = preRenderer != nil || postRenderer != nil
        let hasNonHook = value != nil || inspector != nil || renderer != nil || filter != nil
        let empty = !hasHook && !hasNonHook
        
        self.isEmpty = empty
        self.isHook = hasHook && !hasNonHook
        self.value = value
        self.mustacheBool = mustacheBool ?? !empty
        self.inspector = inspector
        if let renderer = renderer {
            self.renderer = renderer
        } else {
            // Avoid error: variable 'self.renderer' captured by a closure before being initialized
            self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
            self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
        self.preRenderer = preRenderer
        self.postRenderer = postRenderer
    }
    
    public init(_ box: Box) {
        isEmpty = box.isEmpty
        isHook = box.isHook
        value = box.value
        mustacheBool = box.mustacheBool
        inspector = box.inspector
        renderer = box.renderer
        filter = box.filter
        preRenderer = box.preRenderer
        postRenderer = box.postRenderer
    }
    
    public init(_ dictionary: [String: Box]) {
        self.isEmpty = false
        self.isHook = false
        self.value = dictionary
        self.mustacheBool = true
        self.inspector = { (key: String) -> Box? in
            return dictionary[key]
        }
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(self), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for box in sequence {
                    if let boxRendering = box.renderer(info: enumerationRenderingInfo, error: error) {
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
    
    public init<T: CollectionType where T.Generator.Element == Box, T.Index: Comparable, T.Index.Distance == Int>(_ collection: T) {
        self.isEmpty = false
        self.isHook = false
        self.value = collection
        self.mustacheBool = (countElements(collection) > 0)
        self.inspector = { (key: String) -> Box? in
            switch key {
            case "count":
                return Box(countElements(collection))
            case "firstObject":
                if countElements(collection) > 0 {
                    return collection[collection.startIndex]
                } else {
                    return Box()
                }
            case "lastObject":
                if countElements(collection) > 0 {
                    return collection[advance(collection.endIndex, -1)]
                } else {
                    return Box()
                }
            default:
                return Box()
            }
        }
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(self), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for box in collection {
                    if let boxRendering = box.renderer(info: enumerationRenderingInfo, error: error) {
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
    
    public init(_ filter: Filter) {
        self.isEmpty = false
        self.isHook = false
        self.value = filter
        self.mustacheBool = true
        self.filter = filter
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(filter)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
    }
    
    public init(_ inspector: Inspector) {
        self.isEmpty = false
        self.isHook = false
        self.value = inspector
        self.mustacheBool = true
        self.inspector = inspector
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(inspector)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
    }
    
    public init(_ renderer: Renderer) {
        self.isEmpty = false
        self.isHook = false
        self.value = renderer
        self.mustacheBool = true
        self.renderer = renderer
    }
    
    public init(_ preRenderer: PreRenderer) {
        self.isEmpty = false
        self.isHook = true
        self.value = preRenderer
        self.mustacheBool = true
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(preRenderer)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
        self.preRenderer = preRenderer
    }
    
    public init(_ postRenderer: PostRenderer) {
        self.isEmpty = false
        self.isHook = true
        self.value = postRenderer
        self.mustacheBool = true
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(postRenderer)")
            case .Section:
                return info.tag.render(info.context.extendedContext(self), error: error)
            }
        }
        self.postRenderer = postRenderer
    }
    
    private init(_ object: NSObject) {
        self.isEmpty = false
        self.isHook = false
        self.value = object
        self.mustacheBool = true
        self.inspector = { (key: String) -> Box? in
            return Box(object.valueForKey(key))
        }
        // Avoid error: variable 'self.renderer' captured by a closure before being initialized
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
                    fatalError("\(object) can not be boxed. Consider having it implement the MustacheBoxable protocol.")
                }
                
            } else {
                fatalError("\(object) can not be boxed. Consider having it implement the MustacheBoxable protocol.")
            }
            
        } else {
            self.init()
        }
    }
    
    public init<T: MustacheBoxable>(_ value: T) {
        self.init(value.mustacheBox())
    }
    
}


// =============================================================================
// MARK: - Box derivation

extension Box {
    
    public func boxWithRenderer(renderer: Renderer) -> Box {
        return Box(
            value: self.value,
            mustacheBool: self.mustacheBool,
            inspector: self.inspector,
            renderer: renderer,
            filter: self.filter,
            preRenderer: self.preRenderer,
            postRenderer: self.postRenderer)
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
        if let inspector = inspector {
            if let box = inspector(key: key) {
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
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
            renderer: renderer)
    }
}

extension Int: MustacheBoxable {
    public func mustacheBox() -> Box {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
            renderer: renderer)
    }
}

extension Double: MustacheBoxable {
    public func mustacheBox() -> Box {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
            renderer: renderer)
    }
}

extension String: MustacheBoxable {
    public func mustacheBox() -> Box {
        let inspector = { (key: String) -> Box? in
            switch key {
            case "length":
                return Box(countElements(self))
            default:
                return nil
            }
        }
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
            inspector: inspector,
            renderer: renderer)
    }
}

extension NSNull: MustacheBoxable {
    public func mustacheBox() -> Box {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
            renderer: renderer)
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
        let inspector = { (key: String) -> Box? in
            switch key {
            case "count":
                return Box(self.count)
            case "anyObject":
                return Box(self.anyObject())
            default:
                return nil
            }
        }
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            if info.enumerationItem {
                return info.tag.render(info.context.extendedContext(self.mustacheBox()), error: error)
            } else {
                var buffer = ""
                var contentType: ContentType?
                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
                for object in self {
                    if let boxRendering = Box(object).renderer(info: enumerationRenderingInfo, error: error) {
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
            inspector: inspector,
            renderer: renderer)
    }
}