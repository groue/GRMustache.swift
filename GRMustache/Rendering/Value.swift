//
//  Box.swift
//  GRMustache
//
//  Created by Gwendal Roué on 08/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public typealias Inspector = (identifier: String) -> Box?
public typealias Filter = (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box?
public typealias Renderer = (info: RenderingInfo, error: NSErrorPointer) -> Rendering?
public typealias PreRenderer = (tag: Tag, box: Box) -> Box
public typealias PostRenderer = (tag: Tag, box: Box, string: String?) -> Void

public protocol MustacheBoxable {
    func toBox() -> Box
}

private let DefaultInspector: Inspector = { (identifier: String) -> Box? in
    return nil
}

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

public func MakeFilter(filter: (Int?, NSErrorPointer) -> Box?) -> Filter {
    // TODO: test
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.intValue() {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

public func MakeFilter(filter: (Double?, NSErrorPointer) -> Box?) -> Filter {
    // TODO: test
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.doubleValue() {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

public func MakeFilter(filter: (String?, NSErrorPointer) -> Box?) -> Filter {
    // TODO: test
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.stringValue() {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

public func MakeFilter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (t: T?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(t, info, error)
        })
    })
}

public func MakeFilter(filter: (Box, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (box: Box, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(box, info, error)
        })
    })
}

public func MakeFilter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (int: Int?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(int, info, error)
        })
    })
}

public func MakeFilter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (double: Double?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(double, info, error)
        })
    })
}

public func MakeFilter(filter: (String?, RenderingInfo, NSErrorPointer) -> Rendering?) -> Filter {
    return MakeFilter({ (string: String?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(string, info, error)
        })
    })
}

public struct Box {
    public let value: Any?
    public let mustacheBool: Void -> Bool
    public let inspector: Inspector?
    public private(set) var renderer: Renderer
    public let filter: Filter?
    public let preRenderer: PreRenderer?
    public let postRenderer: PostRenderer?
    
    public init() {
        self.mustacheBool = { return false }
        self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("")
            case .Section:
                return info.tag.render(info.context, error: error)
            }
        }
    }
    
    public init(value: Any, mustacheBool: Bool = true, inspector: Inspector? = DefaultInspector, renderer: Renderer? = nil, filter: Filter? = nil, preRenderer: PreRenderer? = nil, postRenderer: PostRenderer? = nil) {
        self.value = value
        self.mustacheBool = { return mustacheBool }
        self.inspector = inspector
        if let renderer = renderer {
            self.renderer = renderer
        } else {
            // Avoid error: variable 'self.renderer' captured by a closure before being initialized
            self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in return nil }
            self.renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(value)")
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
        value = box.value
        mustacheBool = box.mustacheBool
        inspector = box.inspector
        renderer = box.renderer
        filter = box.filter
        preRenderer = box.preRenderer
        postRenderer = box.postRenderer
    }
    
    public init(_ dictionary: [String: Box]) {
        self.value = dictionary
        self.mustacheBool = { return true }
        self.inspector = { (identifier: String) -> Box? in
            return dictionary[identifier]
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
    
//    public init(_ array: [Box]) {
//        value = array
//        mustacheBool = { return countElements(array) > 0 }
//        inspector = { (identifier: String) -> Box? in
//            switch identifier {
//            case "count":
//                return Box(countElements(array))
//            case "firstObject":
//                return array.first
//            case "lastObject":
//                return array.last
//            default:
//                return nil
//            }
//        }
//        renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            if info.enumerationItem {
//                return info.tag.render(info.context.extendedContext(self), error: error)
//            } else {
//                var buffer = ""
//                var contentType: ContentType?
//                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
//                for item in array {
//                    if let itemRendering = item.render(enumerationRenderingInfo, error: error) {
//                        if contentType == nil {
//                            contentType = itemRendering.contentType
//                            buffer += itemRendering.string
//                        } else if contentType == itemRendering.contentType {
//                            buffer += itemRendering.string
//                        } else {
//                            if error != nil {
//                                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Content type mismatch"])
//                            }
//                            return nil
//                        }
//                    } else {
//                        return nil
//                    }
//                }
//                if let contentType = contentType {
//                    return Rendering(buffer, contentType)
//                } else {
//                    switch info.tag.type {
//                    case .Variable:
//                        return Rendering("")
//                    case .Section:
//                        return info.tag.render(info.context, error: error)
//                    }
//                }
//            }
//        }
//    }
    
    public init<T: SequenceType where T.Generator.Element == Box>(_ sequence: T) {
        self.value = sequence
        self.mustacheBool = {
            for x in sequence {
                return true
            }
            return false
        }
        self.inspector = DefaultInspector
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
                    switch info.tag.type {
                    case .Variable:
                        return Rendering("")
                    case .Section:
                        return info.tag.render(info.context, error: error)
                    }
                }
            }
        }
    }
    
    public init<T: CollectionType where T.Generator.Element == Box, T.Index: Comparable, T.Index.Distance == Int>(_ collection: T) {
        self.value = collection
        self.mustacheBool = {
            return countElements(collection) > 0
        }
        self.inspector = { (identifier: String) -> Box? in
            switch identifier {
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
                    switch info.tag.type {
                    case .Variable:
                        return Rendering("")
                    case .Section:
                        return info.tag.render(info.context, error: error)
                    }
                }
            }
        }
    }
    
    public init(_ filter: Filter) {
        self.mustacheBool = { return true }
        self.inspector = DefaultInspector
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
        self.mustacheBool = { return true }
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
        self.mustacheBool = { return true }
        self.inspector = DefaultInspector
        self.renderer = renderer
    }
    
    public init(_ preRenderer: PreRenderer) {
        self.mustacheBool = { return true }
        self.inspector = nil
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
        self.mustacheBool = { return true }
        self.inspector = nil
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
        self.value = object
        self.mustacheBool = { return true }
        self.inspector = { (identifier: String) -> Box? in
            return Box(object.valueForKey(identifier))
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
                self.init(null.toBox())
            } else if let number = object as? NSNumber {
                self.init(number.toBox())
            } else if let set = object as? NSSet {
                self.init(set.toBox())
            } else if let string = object as? String {
                self.init(string.toBox())
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
                        self.init(set.toBox())
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
        self.init(value.toBox())
    }
    
    public var isEmpty: Bool {
        return value == nil && inspector == nil && preRenderer == nil && postRenderer == nil
    }

    public func intValue() -> Int? {
        if let int = value as? Int {
            return int
        } else if let double = value as? Double {
            return Int(double)
        } else {
            return nil
        }
    }
    
    public func doubleValue() -> Double? {
        if let int = value as? Int {
            return Double(int)
        } else if let double = value as? Double {
            return double
        } else {
            return nil
        }
    }
    
    public func stringValue() -> String? {
        if value is NSNull {
            return nil
        } else if let value = value {
            return "\(value)"
        } else {
            return nil
        }
    }
}

//// =============================================================================
//// MARK: - Facet Protocols
//
//public protocol MustacheWrappable {
//}
//
//public protocol MustacheCluster: MustacheWrappable {
//    
//    /**
//    Controls whether the object should trigger or avoid the rendering
//    of Mustache sections.
//    
//    - true: `{{#object}}...{{/}}` are rendered, `{{^object}}...{{/}}`
//    are not.
//    - false: `{{^object}}...{{/}}` are rendered, `{{#object}}...{{/}}`
//    are not.
//    
//    Example:
//    
//    class MyObject: MustacheCluster {
//    let mustacheBool = true
//    }
//    
//    :returns: Whether the object should trigger the rendering of
//    Mustache sections.
//    */
//    var mustacheBool: Bool { get }
//    
//    /**
//    TODO
//    */
//    var mustacheInspectable: MustacheInspectable? { get }
//    
//    /**
//    Controls whether the object can be used as a filter.
//    
//    :returns: An optional filter object that should be applied when the object
//    is involved in a filter expression such as `object(...)`.
//    */
//    var mustacheFilter: MustacheFilter? { get }
//    
//    /**
//    TODO
//    */
//    var mustacheTagObserver: MustacheTagObserver? { get }
//    
//    /**
//    TODO
//    */
//    var mustacheRenderable: MustacheRenderable? { get }
//}
//
//public protocol MustacheFilter: MustacheWrappable {
//    func mustacheFilterByApplyingArgument(argument: Box) -> MustacheFilter?
//    func transformedMustacheValue(box: Box, error: NSErrorPointer) -> Box?
//}
//
//public protocol MustacheInspectable: MustacheWrappable {
//    func valueForMustacheKey(key: String) -> Box?
//}
//
//public protocol MustacheRenderable: MustacheWrappable {
//    func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering?
//}
//
//public protocol MustacheTagObserver: MustacheWrappable {
//    func mustacheTag(tag: Tag, willRender box: Box) -> Box
//    
//    // If rendering is nil then an error has occurred.
//    func mustacheTag(tag: Tag, didRender box: Box, asString: String?)
//}
//
//
//// =============================================================================
//// MARK: - Box
//
//public class Box {
//    private enum Type {
//        case None
//        case AnyObjectValue(AnyObject)
//        case DictionaryValue([String: Box])
//        case ArrayValue([Box])
//        case SetValue(NSSet)
//        case ClusterValue(MustacheCluster)
//    }
//    
//    private let type: Type
//    
//    public var isEmpty: Bool {
//        switch type {
//        case .None:
//            return true
//        default:
//            return false
//        }
//    }
//    
//    private init(type: Type) {
//        self.type = type
//    }
//    
//    public convenience init() {
//        self.init(type: .None)
//    }
//    
//    public convenience init(_ object: AnyObject?) {
//        if let object: AnyObject = object {
//            if let value = object as? Box {
//                self.init(type: value.type)
//                
//            } else if let dictionary = object as? [String: Box] {
//                self.init(type: .DictionaryValue(dictionary))
//                
//            } else if let array = object as? [Box] {
//                self.init(type: .ArrayValue(array))
//                
//            } else if object is NSNull {
//                self.init()
//                
//            } else if let number = object as? NSNumber {
//                let objCType = number.objCType
//                let str = String.fromCString(objCType)
//                switch str! {
//                case "c", "i", "s", "l", "q", "C", "I", "S", "L", "Q":
//                    self.init(Int(number.longLongValue))
//                case "f", "d":
//                    self.init(number.doubleValue)
//                case "B":
//                    self.init(number.boolValue)
//                default:
//                    fatalError("Not implemented yet")
//                }
//                
//            } else if let string = object as? NSString {
//                self.init(string as String)
//                
//            } else if let object = object as? NSObjectProtocol {
//                if let enumerable = object as? NSFastEnumeration {
//                    if object.respondsToSelector("objectAtIndexedSubscript:") {
//                        // Array
//                        var array: [Box] = []
//                        let generator = NSFastGenerator(enumerable)
//                        while true {
//                            if let item: AnyObject = generator.next() {
//                                array.append(Box(item))
//                            } else {
//                                break
//                            }
//                        }
//                        self.init(type: .ArrayValue(array))
//                    } else if object.respondsToSelector("objectForKeyedSubscript:") {
//                        // Dictionary
//                        var dictionary: [String: Box] = [:]
//                        let generator = NSFastGenerator(enumerable)
//                        while true {
//                            if let key = generator.next() as? String {
//                                dictionary[key] = Box((object as AnyObject)[key])
//                            } else {
//                                break
//                            }
//                        }
//                        self.init(type: .DictionaryValue(dictionary))
//                    } else {
//                        // Set
//                        var set = NSMutableSet()
//                        let generator = NSFastGenerator(enumerable)
//                        while true {
//                            if let item: AnyObject = generator.next() {
//                                set.addObject(item)
//                            } else {
//                                break
//                            }
//                        }
//                        self.init(type: .SetValue(set))
//                    }
//                } else {
//                    self.init(type: .AnyObjectValue(object))
//                }
//                
//            } else {
//                fatalError("Not implemented")
//            }
//        } else {
//            self.init()
//        }
//    }
//    
//    private class func wrappableFromCluster(cluster: MustacheCluster?) -> MustacheWrappable? {
//        return cluster?.mustacheFilter ?? cluster?.mustacheInspectable ?? cluster?.mustacheRenderable ?? cluster?.mustacheTagObserver ?? cluster
//    }
//    
//}
//
//
//// =============================================================================
//// MARK: - MustacheFilter Factory Methods
//
//private struct BlockFilter: MustacheFilter {
//    let block: (Box, NSErrorPointer) -> Box?
//    
//    func mustacheFilterByApplyingArgument(argument: Box) -> MustacheFilter? {
//        return nil
//    }
//    
//    func transformedMustacheValue(box: Box, error: NSErrorPointer) -> Box? {
//        return block(box, error)
//    }
//}
//
//public func BoxedFilter(block: (Box, NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockFilter(block: block))
//}
//
//public func BoxedFilter(block: (AnyObject?, NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockFilter(block: { (box: Box, error: NSErrorPointer) -> Box? in
//        if let object:AnyObject = box.value() {
//            return block(object, error)
//        } else {
//            return block(nil, error)
//        }
//    }))
//}
//
//public func BoxedFilter<T: MustacheWrappable>(block: (T?, NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockFilter(block: { (argument: Box, error: NSErrorPointer) -> Box? in
//        if let object:T = argument.value() {
//            return block(object, error)
//        } else {
//            return block(nil, error)
//        }
//    }))
//}
//
//public func BoxedFilter<T: NSObjectProtocol>(block: (T?, NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockFilter(block: { (argument: Box, error: NSErrorPointer) -> Box? in
//        if let object:T = argument.value() {
//            return block(object, error)
//        } else {
//            return block(nil, error)
//        }
//    }))
//}
//
//public func BoxedFilter(block: (Int?, NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockFilter(block: { (argument: Box, error: NSErrorPointer) -> Box? in
//        if let int = argument.toInt() {
//            return block(int, error)
//        } else {
//            return block(nil, error)
//        }
//    }))
//}
//
//public func BoxedFilter(block: (Double?, NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockFilter(block: { (argument: Box, error: NSErrorPointer) -> Box? in
//        if let double = argument.toDouble() {
//            return block(double, error)
//        } else {
//            return block(nil, error)
//        }
//    }))
//}
//
//public func BoxedFilter(block: (String?, NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockFilter(block: { (argument: Box, error: NSErrorPointer) -> Box? in
//        if let string = argument.toString() {
//            return block(string, error)
//        } else {
//            return block(nil, error)
//        }
//    }))
//}
//
//private struct BlockVariadicFilter: MustacheFilter {
//    let arguments: [Box]
//    let block: ([Box], NSErrorPointer) -> Box?
//    
//    func mustacheFilterByApplyingArgument(argument: Box) -> MustacheFilter? {
//        return BlockVariadicFilter(arguments: arguments + [argument], block: block)
//    }
//    
//    func transformedMustacheValue(box: Box, error: NSErrorPointer) -> Box? {
//        return block(arguments + [box], error)
//    }
//}
//
//public func BoxedVariadicFilter(block: ([Box], NSErrorPointer) -> Box?) -> Box {
//    return Box(BlockVariadicFilter(arguments: [], block: block))
//}
//
//
//// =============================================================================
//// MARK: - MustacheFilter + MustacheRenderable Factory Methods
//
//public func BoxedFilter(block: (Box, info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return BoxedFilter({ (box: Box, error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return block(box, info: info, error: error)
//        })
//    })
//}
//
//public func BoxedFilter(block: ([Box], info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return BoxedVariadicFilter({ (arguments: [Box], error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return block(arguments, info: info, error: error)
//        })
//    })
//}
//
//public func BoxedFilter(block: (AnyObject?, info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return BoxedFilter({ (object: AnyObject?, error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return block(object, info: info, error: error)
//        })
//    })
//}
//
//public func BoxedFilter<T: MustacheWrappable>(block: (T?, info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return Box(BlockFilter(block: { (box: Box, error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            if let object:T = box.value() {
//                return block(object, info: info, error: error)
//            } else {
//                return block(nil, info: info, error: error)
//            }
//        })
//    }))
//}
//
//public func BoxedFilter<T: NSObjectProtocol>(block: (T?, info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return Box(BlockFilter(block: { (box: Box, error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            if let object:T = box.value() {
//                return block(object, info: info, error: error)
//            } else {
//                return block(nil, info: info, error: error)
//            }
//        })
//    }))
//}
//
//public func BoxedFilter(block: (Int?, info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return BoxedFilter({ (int: Int?, error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return block(int, info: info, error: error)
//        })
//    })
//}
//
//public func BoxedFilter(block: (Double?, info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return BoxedFilter({ (double: Double?, error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return block(double, info: info, error: error)
//        })
//    })
//}
//
//public func BoxedFilter(block: (String?, info: RenderingInfo, error: NSErrorPointer) -> Rendering?) -> Box {
//    return BoxedFilter({ (string: String?, error: NSErrorPointer) -> Box? in
//        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
//            return block(string, info: info, error: error)
//        })
//    })
//}
//
//
//// =============================================================================
//// MARK: - MustacheRenderable Factory Methods
//
//private struct BlockRenderable: MustacheRenderable {
//    let block: (RenderingInfo, NSErrorPointer) -> Rendering?
//    
//    func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
//        return block(info, error)
//    }
//}
//
//public func Box(block: (RenderingInfo, NSErrorPointer) -> Rendering?) -> Box {
//    return Box(BlockRenderable(block: block))
//}
//
//
//// =============================================================================
//// MARK: - MustacheCluster Convenience Initializers
//
//extension Box {
//    
//    public convenience init(_ object: protocol<MustacheCluster>) { self.init(type: .ClusterValue(object)) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheInspectable>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheInspectable, MustacheRenderable>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheInspectable, MustacheRenderable, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheInspectable, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheRenderable>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheInspectable>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheInspectable, MustacheRenderable>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheInspectable, MustacheRenderable, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheInspectable, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheRenderable>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheCluster, MustacheTagObserver>) { self.init(object as MustacheCluster) }
//    public convenience init(_ object: protocol<MustacheFilter>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheFilter, MustacheInspectable>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheFilter, MustacheInspectable, MustacheRenderable>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheFilter, MustacheInspectable, MustacheRenderable, MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheFilter, MustacheInspectable, MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheFilter, MustacheRenderable>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheFilter, MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheInspectable>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheInspectable, MustacheRenderable>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheInspectable, MustacheRenderable, MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheInspectable, MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheRenderable>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheRenderable, MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    public convenience init(_ object: protocol<MustacheTagObserver>) { self.init(ClusterWrapper(object)) }
//    
//    private struct ClusterWrapper: MustacheCluster, DebugPrintable {
//        let mustacheBool = true
//        let mustacheFilter: MustacheFilter?
//        let mustacheInspectable: MustacheInspectable?
//        let mustacheRenderable: MustacheRenderable?
//        let mustacheTagObserver: MustacheTagObserver?
//
//        init(_ object: protocol<MustacheFilter>) { mustacheFilter = object }
//        init(_ object: protocol<MustacheFilter, MustacheInspectable>) { mustacheFilter = object; mustacheInspectable = object }
//        init(_ object: protocol<MustacheFilter, MustacheInspectable, MustacheRenderable>) { mustacheFilter = object; mustacheInspectable = object; mustacheRenderable = object }
//        init(_ object: protocol<MustacheFilter, MustacheInspectable, MustacheRenderable, MustacheTagObserver>) { mustacheFilter = object; mustacheInspectable = object; mustacheRenderable = object; mustacheTagObserver = object }
//        init(_ object: protocol<MustacheFilter, MustacheInspectable, MustacheTagObserver>) { mustacheFilter = object; mustacheInspectable = object; mustacheTagObserver = object }
//        init(_ object: protocol<MustacheFilter, MustacheRenderable>) { mustacheFilter = object; mustacheRenderable = object }
//        init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>) { mustacheFilter = object; mustacheRenderable = object; mustacheTagObserver = object }
//        init(_ object: protocol<MustacheFilter, MustacheTagObserver>) { mustacheFilter = object; mustacheTagObserver = object }
//        init(_ object: protocol<MustacheInspectable>) { mustacheInspectable = object }
//        init(_ object: protocol<MustacheInspectable, MustacheRenderable>) { mustacheInspectable = object; mustacheRenderable = object }
//        init(_ object: protocol<MustacheInspectable, MustacheRenderable, MustacheTagObserver>) { mustacheInspectable = object; mustacheRenderable = object; mustacheTagObserver = object }
//        init(_ object: protocol<MustacheInspectable, MustacheTagObserver>) { mustacheInspectable = object; mustacheTagObserver = object }
//        init(_ object: protocol<MustacheRenderable>) { mustacheRenderable = object }
//        init(_ object: protocol<MustacheRenderable, MustacheTagObserver>) { mustacheRenderable = object; mustacheTagObserver = object }
//        init(_ object: protocol<MustacheTagObserver>) { mustacheTagObserver = object }
//        
//        var debugDescription: String {
//            let object: Any = mustacheFilter ?? mustacheRenderable ?? mustacheTagObserver ?? mustacheInspectable ?? "null"
//            return "ClusterWrapper(\(object))"
//        }
//    }
//}
//
//
//// =============================================================================
//// MARK: - Box unwrapping
//
//extension Box {
//    
//    public func value() -> AnyObject? {
//        switch type {
//        case .AnyObjectValue(let object):
//            return object
//        case .DictionaryValue(let dictionary):
//            var result = NSMutableDictionary()
//            for (key, item) in dictionary {
//                if let object:AnyObject = item.value() {
//                    result[key] = object
//                }
//            }
//            return result
//        case .ArrayValue(let array):
//            var result = NSMutableArray()
//            for item in array {
//                if let object:AnyObject = item.value() {
//                    result.addObject(object)
//                }
//            }
//            return result
//        case .SetValue(let set):
//            return set
//        case .ClusterValue(let cluster):
//            // The four types declared as Clusters in RenderingEngine.swift
//            if let bool: Bool = value() {
//                return bool
//            } else if let int: Int = value() {
//                return int
//            } else if let double: Double = value() {
//                return double
//            } else if let string: String = value() {
//                return string
//            } else {
//                return nil
//            }
//        default:
//            return nil
//        }
//    }
//    
//    public func value() -> MustacheCluster? {
//        switch type {
//        case .ClusterValue(let cluster):
//            return cluster
//        default:
//            return nil
//        }
//    }
//    
//    public func value() -> [String: Box]? {
//        switch type {
//        case .DictionaryValue(let dictionary):
//            return dictionary
//        default:
//            return nil
//        }
//    }
//    
//    public func value() -> [Box]? {
//        switch type {
//        case .ArrayValue(let array):
//            return array
//        default:
//            return nil
//        }
//    }
//    
//    public func toInt() -> Int? {
//        if let int: Int = value() {
//            return int
//        } else if let double: Double = value() {
//            return Int(double)
//        } else {
//            return nil
//        }
//    }
//    
//    public func toDouble() -> Double? {
//        if let int: Int = value() {
//            return Double(int)
//        } else if let double: Double = value() {
//            return double
//        } else {
//            return nil
//        }
//    }
//    
//    public func toString() -> String? {
//        switch type {
//        case .None:
//            return nil
//        case .AnyObjectValue(let object):
//            return "\(object)"
//        case .DictionaryValue(let dictionary):
//            return "\(dictionary)"
//        case .ArrayValue(let array):
//            return "\(array)"
//        case .SetValue(let set):
//            return "\(set)"
//        case .ClusterValue(let cluster):
//            return "\(cluster)"
//        }
//    }
//    
//}
//
//
//// =============================================================================
//// MARK: - Convenience value unwrapping
//
//extension Box {
//
//    public func value() -> MustacheFilter? {
//        return (value() as MustacheCluster?)?.mustacheFilter
//    }
//    
//    public func value() -> MustacheInspectable? {
//        return (value() as MustacheCluster?)?.mustacheInspectable
//    }
//    
//    public func value() -> MustacheRenderable? {
//        return (value() as MustacheCluster?)?.mustacheRenderable
//    }
//    
//    public func value() -> MustacheTagObserver? {
//        return (value() as MustacheCluster?)?.mustacheTagObserver
//    }
//    
//    public func value<T: MustacheWrappable>() -> T? {
//        return Box.wrappableFromCluster(value() as MustacheCluster?) as? T
//    }
//    
//    public func value<T: NSObjectProtocol>() -> T? {
//        return (value() as AnyObject?) as? T
//    }
//    
//}
//
//
//// =============================================================================
//// MARK: - DebugPrintable
//
//extension Box: DebugPrintable {
//    
//    public var debugDescription: String {
//        switch type {
//        case .None:
//            return "Box.None"
//        case .AnyObjectValue(let object):
//            return "Box.AnyObjectValue(\(object))"
//        case .DictionaryValue(let dictionary):
//            return "Box.DictionaryValue(\(dictionary.debugDescription))"
//        case .ArrayValue(let array):
//            return "Box.ArrayValue(\(array.debugDescription))"
//        case .SetValue(let set):
//            return "Box.SetValue(\(set))"
//        case .ClusterValue(let cluster):
//            return "Box.ClusterValue(\(cluster))"
//        }
//    }
//}


// =============================================================================
// MARK: - Key extraction

extension Box {
    
    subscript(identifier: String) -> Box {
        if let inspector = inspector {
            if let box = inspector(identifier: identifier) {
                return box
            }
        }
        return Box()
    }
    
//    subscript(identifier: String) -> Box {
//        return Box()
//        switch type {
//        case .None:
//            return Box()
//        case .AnyObjectValue(let object):
//            return Box(object.valueForKey?(identifier))
//        case .DictionaryValue(let dictionary):
//            if let mustacheValue = dictionary[identifier] {
//                return mustacheValue
//            } else {
//                return Box()
//            }
//        case .ArrayValue(let array):
//            switch identifier {
//            case "count":
//                return Box(countElements(array))
//            case "firstObject":
//                if let first = array.first {
//                    return first
//                } else {
//                    return Box()
//                }
//            case "lastObject":
//                if let last = array.last {
//                    return last
//                } else {
//                    return Box()
//                }
//            default:
//                return Box()
//            }
//        case .SetValue(let set):
//            switch identifier {
//            case "count":
//                return Box(set.count)
//            case "anyObject":
//                return Box(set.anyObject())
//            default:
//                return Box()
//            }
//        case .ClusterValue(let cluster):
//            if let value = cluster.mustacheInspectable?.valueForMustacheKey(identifier) {
//                return value
//            } else {
//                return Box()
//            }
//        }
//    }
}


//// =============================================================================
//// MARK: - Rendering
//
//extension Box {
//
//    var mustacheBool: Bool {
//        switch type {
//        case .None:
//            return false
//        case .DictionaryValue:
//            return true
//        case .ArrayValue(let array):
//            return countElements(array) > 0
//        case .SetValue(let set):
//            return set.count > 0
//        case .AnyObjectValue(let object):
//            return true
//        case .ClusterValue(let cluster):
//            return cluster.mustacheBool
//        }
//    }
//    
//    public func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
//        let tag = info.tag
//        switch type {
//        case .None:
//            switch tag.type {
//            case .Variable:
//                return Rendering("")
//            case .Section:
//                return info.tag.render(info.context, error: error)
//            }
//        case .DictionaryValue(let dictionary):
//            switch tag.type {
//            case .Variable:
//                return Rendering("\(dictionary)")
//            case .Section:
//                return info.tag.render(info.context.extendedContext(self), error: error)
//            }
//        case .ArrayValue(let array):
//            if info.enumerationItem {
//                return info.tag.render(info.context.extendedContext(self), error: error)
//            } else {
//                var buffer = ""
//                var contentType: ContentType?
//                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
//                for item in array {
//                    if let itemRendering = item.render(enumerationRenderingInfo, error: error) {
//                        if contentType == nil {
//                            contentType = itemRendering.contentType
//                            buffer += itemRendering.string
//                        } else if contentType == itemRendering.contentType {
//                            buffer += itemRendering.string
//                        } else {
//                            if error != nil {
//                                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Content type mismatch"])
//                            }
//                            return nil
//                        }
//                    } else {
//                        return nil
//                    }
//                }
//                
//                if let contentType = contentType {
//                    return Rendering(buffer, contentType)
//                } else {
//                    switch tag.type {
//                    case .Variable:
//                        return Rendering("")
//                    case .Section:
//                        return info.tag.render(info.context, error: error)
//                    }
//                }
//            }
//        case .SetValue(let set):
//            if info.enumerationItem {
//                return info.tag.render(info.context.extendedContext(self), error: error)
//            } else {
//                var buffer = ""
//                var contentType: ContentType?
//                let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
//                for item in set {
//                    if let itemRendering = Box(item).render(enumerationRenderingInfo, error: error) {
//                        if contentType == nil {
//                            contentType = itemRendering.contentType
//                            buffer += itemRendering.string
//                        } else if contentType == itemRendering.contentType {
//                            buffer += itemRendering.string
//                        } else {
//                            if error != nil {
//                                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Content type mismatch"])
//                            }
//                            return nil
//                        }
//                    } else {
//                        return nil
//                    }
//                }
//
//                if let contentType = contentType {
//                    return Rendering(buffer, contentType)
//                } else {
//                    switch tag.type {
//                    case .Variable:
//                        return Rendering("")
//                    case .Section:
//                        return info.tag.render(info.context, error: error)
//                    }
//                }
//            }
//        case .AnyObjectValue(let object):
//            switch tag.type {
//            case .Variable:
//                return Rendering("\(object)")
//            case .Section:
//                return info.tag.render(info.context.extendedContext(self), error: error)
//            }
//        case .ClusterValue(let cluster):
//            if let renderable = cluster.mustacheRenderable {
//                return renderable.render(info, error: error)
//            } else {
//                return info.tag.render(info.context.extendedContext(self), error: error)
//            }
//        }
//    }
//}


extension Bool: MustacheBoxable {
    public func toBox() -> Box {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.toBox()), error: error)
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
    public func toBox() -> Box {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.toBox()), error: error)
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
    public func toBox() -> Box {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("\(self)")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.toBox()), error: error)
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
    public func toBox() -> Box {
        let inspector = { (identifier: String) -> Box? in
            switch identifier {
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
                return info.tag.render(info.context.extendedContext(self.toBox()), error: error)
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
    public func toBox() -> Box {
        let renderer = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            switch info.tag.type {
            case .Variable:
                return Rendering("")
            case .Section:
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(self.toBox()), error: error)
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
    public func toBox() -> Box {
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
    public func toBox() -> Box {
        let inspector = { (identifier: String) -> Box? in
            switch identifier {
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
                return info.tag.render(info.context.extendedContext(self.toBox()), error: error)
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