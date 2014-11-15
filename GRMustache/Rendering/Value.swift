//
//  Value.swift
//  GRMustache
//
//  Created by Gwendal Roué on 08/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public protocol Cluster {
    
    /**
    Controls whether the object should trigger or avoid the rendering
    of Mustache sections.
    
    - true: `{{#object}}...{{/}}` are rendered, `{{^object}}...{{/}}`
    are not.
    - false: `{{^object}}...{{/}}` are rendered, `{{#object}}...{{/}}`
    are not.
    
    Example:
    
    class MyObject: Cluster {
    let mustacheBool = true
    }
    
    :returns: Whether the object should trigger the rendering of
    Mustache sections.
    */
    var mustacheBool: Bool { get }
    
    /**
    TODO
    */
    var mustacheTraversable: Traversable? { get }
    
    /**
    Controls whether the object can be used as a filter.
    
    :returns: An optional filter object that should be applied when the object
    is involved in a filter expression such as `object(...)`.
    */
    var mustacheFilter: Filter? { get }
    
    /**
    TODO
    */
    var mustacheTagObserver: TagObserver? { get }
    
    /**
    TODO
    */
    var mustacheRenderable: Renderable? { get }
}

public protocol Filter {
    func mustacheFilterByApplyingArgument(argument: Value) -> Filter?
    func transformedMustacheValue(value: Value, error outError: NSErrorPointer) -> Value?
}

public struct RenderingInfo {
    public let context: Context
    let enumerationItem: Bool
    
    public func renderingInfoByExtendingContextWithValue(value: Value) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingValue(value), enumerationItem: enumerationItem)
    }
    
    public func renderingInfoByExtendingContextWithTagObserver(tagObserver: TagObserver) -> RenderingInfo {
        return RenderingInfo(context: context.contextByAddingTagObserver(tagObserver), enumerationItem: enumerationItem)
    }
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(context: context, enumerationItem: true)
    }
}

public protocol Renderable {
    func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String?
}

public protocol TagObserver {
    func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value
    
    // If rendering is nil then an error has occurred.
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value)
}

public protocol Traversable {
    func valueForMustacheIdentifier(identifier: String) -> Value?
}

public class Value {
    private enum Type {
        case None
        case AnyObjectValue(AnyObject)
        case DictionaryValue([String: Value])
        case ArrayValue([Value])
        case SetValue(NSSet)
        case ClusterValue(Cluster)
    }
    
    private let type: Type
    
    var isEmpty: Bool {
        switch type {
        case .None:
            return true
        default:
            return false
        }
    }
    
    private init(type: Type) {
        self.type = type
    }
    
    public convenience init() {
        self.init(type: .None)
    }
    
    public convenience init(_ object: AnyObject?) {
        if let object: AnyObject = object {
            if object is NSNull {
                self.init()
            } else if let number = object as? NSNumber {
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
            } else if let string = object as? NSString {
                self.init(string as String)
            } else if let dictionary = object as? NSDictionary {
                var canonicalDictionary: [String: Value] = [:]
                dictionary.enumerateKeysAndObjectsUsingBlock({ (key, value, _) -> Void in
                    canonicalDictionary["\(key)"] = Value(value)
                })
                self.init(canonicalDictionary)
            } else if let enumerable = object as? NSFastEnumeration {
                if let enumerableObject = object as? NSObjectProtocol {
                    if enumerableObject.respondsToSelector("objectAtIndexedSubscript:") {
                        // Array
                        var array: [Value] = []
                        let generator = NSFastGenerator(enumerable)
                        while true {
                            if let item: AnyObject = generator.next() {
                                array.append(Value(item))
                            } else {
                                break
                            }
                        }
                        self.init(array)
                    } else {
                        // Set
                        var set = NSMutableSet()
                        let generator = NSFastGenerator(enumerable)
                        while true {
                            if let item: AnyObject = generator.next() {
                                set.addObject(item)
                            } else {
                                break
                            }
                        }
                        self.init(type: .SetValue(set))
                    }
                } else {
                    // Assume Array
                    var array: [Value] = []
                    let generator = NSFastGenerator(enumerable)
                    while true {
                        if let item: AnyObject = generator.next() {
                            array.append(Value(item))
                        } else {
                            break
                        }
                    }
                    self.init(array)
                }
            } else {
                self.init(type: .AnyObjectValue(object))
            }
        } else {
            self.init()
        }
    }

    public convenience init(_ cluster: Cluster) {
        self.init(type: .ClusterValue(cluster))
    }

    public convenience init(_ dictionary: [String: Value]) {
        self.init(type: .DictionaryValue(dictionary))
    }
    
    public convenience init(_ array: [Value]) {
        self.init(type: .ArrayValue(array))
    }

}


// =============================================================================
// MARK: - Dictionary Convenience Initializers

extension Value {
    
    public convenience init(_ dictionary: [String: AnyObject]) {
        var mustacheDictionary: [String: Value] = [:]
        for (key, value) in dictionary {
            mustacheDictionary[key] = Value(value)
        }
        self.init(mustacheDictionary)
    }
}


// =============================================================================
// MARK: - Filter Convenience Initializers

extension Value {
    
    public convenience init(_ block: (Value, NSErrorPointer) -> (Value?)) {
        self.init(MustacheBlockFilter(block: block))
    }
    
    public convenience init(_ block: (AnyObject?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object:AnyObject = value.object() {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: Cluster>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Renderable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheTagObserver) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheTraversable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter, Renderable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter, TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Renderable, TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Renderable, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheTagObserver) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter, Renderable, TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter, Renderable, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter, TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Renderable, TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Filter, Renderable, TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = ((value.object() as Cluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Renderable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter, Renderable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter, TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Renderable, TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Renderable, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter, Renderable, TagObserver>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter, Renderable, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter, TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Renderable, TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init<T: protocol<Cluster, Filter, Renderable, TagObserver, Traversable>>(_ block: (T?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let object = (value.object() as Cluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init(_ block: (Int?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let int = value.int() {
                return block(int)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init(_ block: (Double?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let double = value.double() {
                return block(double)
            } else {
                return block(nil)
            }
        }))
    }
    
    public convenience init(_ block: (String?) -> (Value?)) {
        self.init(MustacheBlockFilter(block: { (value: Value, outError: NSErrorPointer) -> (Value?) in
            if let string = value.string() {
                return block(string)
            } else {
                return block(nil)
            }
        }))
    }
    
    private struct MustacheBlockFilter: Filter {
        let block: (Value, NSErrorPointer) -> (Value?)
        
        func mustacheFilterByApplyingArgument(argument: Value) -> Filter? {
            return nil
        }
        
        func transformedMustacheValue(value: Value, error outError: NSErrorPointer) -> Value? {
            return block(value, outError)
        }
    }
}


// =============================================================================
// MARK: - Renderable Convenience Initializers

extension Value {
    
    public convenience init(_ block: (tag: Tag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?)) {
        self.init(MustacheBlockRenderable(block: block))
    }
    
    private struct MustacheBlockRenderable: Renderable {
        let block: (tag: Tag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?)
        
        func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
            return block(tag: tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
    }
}


// =============================================================================
// MARK: - Cluster Convenience Initializers

extension Value {
    
    public convenience init(_ object: protocol<Filter>) {
        self.init(ClusterWrapper(object))
    }

    public convenience init(_ object: protocol<Renderable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<TagObserver>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Traversable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Filter, Renderable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Filter, TagObserver>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Filter, Traversable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Renderable, TagObserver>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Renderable, Traversable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<TagObserver, Traversable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Filter, Renderable, TagObserver>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Filter, Renderable, Traversable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Filter, TagObserver, Traversable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Renderable, TagObserver, Traversable>) {
        self.init(ClusterWrapper(object))
    }
    
    public convenience init(_ object: protocol<Filter, Renderable, TagObserver, Traversable>) {
        self.init(ClusterWrapper(object))
    }

    public convenience init(_ object: protocol<Cluster, Filter>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Renderable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, TagObserver>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Traversable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Filter, Renderable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Filter, TagObserver>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Filter, Traversable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Renderable, TagObserver>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Renderable, Traversable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, TagObserver, Traversable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Filter, Renderable, TagObserver>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Filter, Renderable, Traversable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Filter, TagObserver, Traversable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Renderable, TagObserver, Traversable>) {
        self.init(object as Cluster)
    }
    
    public convenience init(_ object: protocol<Cluster, Filter, Renderable, TagObserver, Traversable>) {
        self.init(object as Cluster)
    }
    
    private struct ClusterWrapper: Cluster, DebugPrintable {
        let mustacheBool = true
        let mustacheFilter: Filter?
        let mustacheRenderable: Renderable?
        let mustacheTagObserver: TagObserver?
        let mustacheTraversable: Traversable?
        
        init(_ object: protocol<Filter>) {
            mustacheFilter = object
        }
        
        init(_ object: protocol<Renderable>) {
            mustacheRenderable = object
        }
        
        init(_ object: protocol<TagObserver>) {
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<Traversable>) {
            mustacheTraversable = object
        }

        init(_ object: protocol<Filter, Renderable>) {
            mustacheFilter = object
            mustacheRenderable = object
        }
        
        init(_ object: protocol<Filter, TagObserver>) {
            mustacheFilter = object
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<Filter, Traversable>) {
            mustacheFilter = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<Renderable, TagObserver>) {
            mustacheRenderable = object
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<Renderable, Traversable>) {
            mustacheRenderable = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<TagObserver, Traversable>) {
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<Filter, Renderable, TagObserver>) {
            mustacheFilter = object
            mustacheRenderable = object
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<Filter, Renderable, Traversable>) {
            mustacheFilter = object
            mustacheRenderable = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<Filter, TagObserver, Traversable>) {
            mustacheFilter = object
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<Renderable, TagObserver, Traversable>) {
            mustacheRenderable = object
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<Filter, Renderable, TagObserver, Traversable>) {
            mustacheFilter = object
            mustacheRenderable = object
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
        var debugDescription: String {
            let object: Any = mustacheFilter ?? mustacheRenderable ?? mustacheTagObserver ?? mustacheTraversable ?? "null"
            return "\(object)"
        }
    }
}


// =============================================================================
// MARK: - Value unwrapping

extension Value {
    
    public func object() -> AnyObject? {
        switch type {
        case .AnyObjectValue(let object):
            return object
        case .DictionaryValue(let dictionary):
            var result = NSMutableDictionary()
            for (key, item) in dictionary {
                if let object:AnyObject = item.object() {
                    result[key] = object
                }
            }
            return result
        case .ArrayValue(let array):
            var result = NSMutableArray()
            for item in array {
                if let object:AnyObject = item.object() {
                    result.addObject(object)
                }
            }
            return result
        case .SetValue(let set):
            return set
        default:
            return nil
        }
    }
    
    public func object() -> Cluster? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster
        default:
            return nil
        }
    }
    
    public func object<T: Cluster>() -> T? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster as? T
        default:
            return nil
        }
    }
    
    public func object() -> [String: Value]? {
        switch type {
        case .DictionaryValue(let dictionary):
            return dictionary
        default:
            return nil
        }
    }
    
    public func object() -> [Value]? {
        switch type {
        case .ArrayValue(let array):
            return array
        default:
            return nil
        }
    }
    
    public func int() -> Int? {
        if let int: Int = object() {
            return int
        } else if let double: Double = object() {
            return Int(double)
        } else {
            return nil
        }
    }
    
    public func double() -> Double? {
        if let int: Int = object() {
            return Double(int)
        } else if let double: Double = object() {
            return double
        } else {
            return nil
        }
    }
    
    public func string() -> String? {
        switch type {
        case .None:
            return nil
        case .AnyObjectValue(let object):
            return "\(object)"
        case .DictionaryValue(let dictionary):
            return "\(dictionary)"
        case .ArrayValue(let array):
            return "\(array)"
        case .SetValue(let set):
            return "\(set)"
        case .ClusterValue(let cluster):
            return "\(cluster)"
        }
    }
    
}


// =============================================================================
// MARK: - Convenience value unwrapping

extension Value {

    public func object() -> Filter? {
        return (object() as Cluster?)?.mustacheFilter
    }
    
    public func object() -> Renderable? {
        return (object() as Cluster?)?.mustacheRenderable
    }
    
    public func object() -> TagObserver? {
        return (object() as Cluster?)?.mustacheTagObserver
    }
    
    public func object() -> Traversable? {
        return (object() as Cluster?)?.mustacheTraversable
    }
    
    public func object<T: protocol<Filter>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Renderable>>() -> T? {
        return (object() as Cluster?)?.mustacheRenderable as? T
    }
    
    public func object<T: protocol<TagObserver>>() -> T? {
        return (object() as Cluster?)?.mustacheTagObserver as? T
    }
    
    public func object<T: protocol<Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheTraversable as? T
    }
    
    public func object<T: protocol<Filter, Renderable>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Filter, TagObserver>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Filter, Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Renderable, TagObserver>>() -> T? {
        return (object() as Cluster?)?.mustacheRenderable as? T
    }
    
    public func object<T: protocol<Renderable, Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheRenderable as? T
    }
    
    public func object<T: protocol<TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheTagObserver as? T
    }
    
    public func object<T: protocol<Filter, Renderable, TagObserver>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Filter, Renderable, Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Filter, TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Renderable, TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheRenderable as? T
    }
    
    public func object<T: protocol<Filter, Renderable, TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?)?.mustacheFilter as? T
    }
    
    public func object<T: protocol<Cluster, Filter>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Renderable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, TagObserver>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Filter, Renderable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Filter, TagObserver>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Filter, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Renderable, TagObserver>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Renderable, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Filter, Renderable, TagObserver>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Filter, Renderable, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Filter, TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Renderable, TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
    public func object<T: protocol<Cluster, Filter, Renderable, TagObserver, Traversable>>() -> T? {
        return (object() as Cluster?) as? T
    }
    
}


// =============================================================================
// MARK: - DebugPrintable

extension Value: DebugPrintable {
    
    public var debugDescription: String {
        switch type {
        case .None:
            return "None"
        case .AnyObjectValue(let object):
            return "AnyObject(\(object))"
        case .DictionaryValue(let dictionary):
            return "Dictionary(\(dictionary.debugDescription))"
        case .ArrayValue(let array):
            return "Array(\(array.debugDescription))"
        case .SetValue(let set):
            return "Set(\(set))"
        case .ClusterValue(let cluster):
            return "Cluster(\(cluster))"
        }
    }
}


// =============================================================================
// MARK: - Key extraction

extension Value {
    
    subscript(identifier: String) -> Value {
        switch type {
        case .None:
            return Value()
        case .AnyObjectValue(let object):
            return Value(object.valueForKey?(identifier))
        case .DictionaryValue(let dictionary):
            if let mustacheValue = dictionary[identifier] {
                return mustacheValue
            } else {
                return Value()
            }
        case .ArrayValue(let array):
            switch identifier {
            case "count":
                return Value(countElements(array))
            case "firstObject":
                if array.isEmpty {
                    return Value()
                } else {
                    return array[array.startIndex]
                }
            case "lastObject":
                if array.isEmpty {
                    return Value()
                } else {
                    return array[array.endIndex.predecessor()]
                }
            default:
                return Value()
            }
        case .SetValue(let set):
            switch identifier {
            case "count":
                return Value(set.count)
            case "anyObject":
                return Value(set.anyObject())
            default:
                return Value()
            }
        case .ClusterValue(let cluster):
            if let traversable = cluster.mustacheTraversable {
                if let value = traversable.valueForMustacheIdentifier(identifier) {
                    return value
                } else {
                    return Value()
                }
            } else {
                return Value()
            }
        }
    }
}


// =============================================================================
// MARK: - Rendering

extension Value {

    var mustacheBool: Bool {
        switch type {
        case .None:
            return false
        case .DictionaryValue:
            return true
        case .ArrayValue(let array):
            return countElements(array) > 0
        case .SetValue(let set):
            return set.count > 0
        case .AnyObjectValue(let object):
            return true
        case .ClusterValue(let cluster):
            return cluster.mustacheBool
        }
    }

    public func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        let tag = tag
        switch type {
        case .None:
            switch tag.type {
            case .Variable:
                return ""
            case .Section:
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        case .DictionaryValue(let dictionary):
            switch tag.type {
            case .Variable:
                return "\(dictionary)"

            case .Section:
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        case .ArrayValue(let array):
            if renderingInfo.enumerationItem {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                let enumerationRenderingInfo = renderingInfo.renderingInfoBySettingEnumerationItem()
                for item in array {
                    empty = false
                    var itemContentType: ContentType = .Text
                    if let itemRendering = item.renderForMustacheTag(tag, renderingInfo: enumerationRenderingInfo, contentType: &itemContentType, error: outError) {
                        if contentType == nil {
                            contentType = itemContentType
                            buffer = buffer + itemRendering
                        } else if contentType == itemContentType {
                            buffer = buffer + itemRendering
                        } else {
                            if outError != nil {
                                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Content type mismatch"])
                            }
                            return nil
                        }
                    } else {
                        return nil
                    }
                }

                if empty {
                    switch tag.type {
                    case .Variable:
                        if outContentType != nil {
                            outContentType.memory = .Text
                        }
                        return ""
                    case .Section:
                        return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                    }
                } else {
                    if outContentType != nil {
                        outContentType.memory = contentType!
                    }
                    return buffer
                }
            }
        case .SetValue(let set):
            if renderingInfo.enumerationItem {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                let enumerationRenderingInfo = renderingInfo.renderingInfoBySettingEnumerationItem()
                for item in set {
                    empty = false
                    var itemContentType: ContentType = .Text
                    if let itemRendering = Value(item).renderForMustacheTag(tag, renderingInfo: enumerationRenderingInfo, contentType: &itemContentType, error: outError) {
                        if contentType == nil {
                            contentType = itemContentType
                            buffer = buffer + itemRendering
                        } else if contentType == itemContentType {
                            buffer = buffer + itemRendering
                        } else {
                            if outError != nil {
                                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Content type mismatch"])
                            }
                            return nil
                        }
                    } else {
                        return nil
                    }
                }

                if empty {
                    switch tag.type {
                    case .Variable:
                        if outContentType != nil {
                            outContentType.memory = .Text
                        }
                        return ""
                    case .Section:
                        return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                    }
                } else {
                    if outContentType != nil {
                        outContentType.memory = contentType!
                    }
                    return buffer
                }
            }
        case .AnyObjectValue(let object):
            switch tag.type {
            case .Variable:
                return "\(object)"
            case .Section:
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        case .ClusterValue(let cluster):
            if let renderable = cluster.mustacheRenderable {
                return renderable.renderForMustacheTag(tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
            } else {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            }
        }
    }
}
