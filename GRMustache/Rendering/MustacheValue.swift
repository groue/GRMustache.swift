//
//  MustacheValue.swift
//  GRMustache
//
//  Created by Gwendal Roué on 08/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class MustacheValue {
    enum Type {
        case None
        case AnyObjectValue(AnyObject)
        case DictionaryValue([String: MustacheValue])
        case ArrayValue([MustacheValue])
        case SetValue(NSSet)

        case ObjectValue(MustacheObject)
        case ClusterValue(MustacheCluster)
    }
    
    let type: Type
    
    init(type: Type) {
        self.type = type
    }
    
    convenience init() {
        self.init(type: .None)
    }
    
    convenience init(_ object: AnyObject?) {
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
                var canonicalDictionary: [String: MustacheValue] = [:]
                dictionary.enumerateKeysAndObjectsUsingBlock({ (key, value, _) -> Void in
                    canonicalDictionary["\(key)"] = MustacheValue(value)
                })
                self.init(canonicalDictionary)
            } else if let enumerable = object as? NSFastEnumeration {
                if let enumerableObject = object as? NSObjectProtocol {
                    if enumerableObject.respondsToSelector("objectAtIndexedSubscript:") {
                        // Array
                        var array: [MustacheValue] = []
                        let generator = NSFastGenerator(enumerable)
                        while true {
                            if let item: AnyObject = generator.next() {
                                array.append(MustacheValue(item))
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
                    var array: [MustacheValue] = []
                    let generator = NSFastGenerator(enumerable)
                    while true {
                        if let item: AnyObject = generator.next() {
                            array.append(MustacheValue(item))
                        } else {
                            break
                        }
                    }
                    self.init(array)
                }
            } else {
                self.init(object)
            }
        } else {
            self.init()
        }
    }

    convenience init(_ object: MustacheObject) {
        self.init(type: .ObjectValue(object))
    }

    convenience init(_ cluster: MustacheCluster) {
        self.init(type: .ClusterValue(cluster))
    }

    convenience init(_ dictionary: [String: MustacheValue]) {
        self.init(type: .DictionaryValue(dictionary))
    }
    
    convenience init(_ array: [MustacheValue]) {
        self.init(type: .ArrayValue(array))
    }

}


// =============================================================================
// MARK: - Dictionary Convenience Initializers

extension MustacheValue {
    
    convenience init(_ dictionary: [String: AnyObject]) {
        var mustacheDictionary: [String: MustacheValue] = [:]
        for (key, value) in dictionary {
            mustacheDictionary[key] = MustacheValue(value)
        }
        self.init(mustacheDictionary)
    }
}


// =============================================================================
// MARK: - MustacheFilter Convenience Initializers

extension MustacheValue {
    
    convenience init(_ block: (MustacheValue, NSErrorPointer) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: block))
    }
    
    convenience init(_ block: (AnyObject?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object:AnyObject = value.object() {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: MustacheObject>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object: T = value.object() {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: MustacheCluster>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheRenderable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheTagObserver) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheTraversable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter, MustacheRenderable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter, MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheRenderable, MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheRenderable, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheTagObserver) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter, MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheRenderable) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = ((value.object() as MustacheCluster?)?.mustacheFilter) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheRenderable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheRenderable, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>(_ block: (T?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let object = (value.object() as MustacheCluster?) as? T {
                return block(object)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init(_ block: (Int?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let int = value.int() {
                return block(int)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init(_ block: (Double?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let double = value.double() {
                return block(double)
            } else {
                return block(nil)
            }
        }))
    }
    
    convenience init(_ block: (String?) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(block: { (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            if let string = value.string() {
                return block(string)
            } else {
                return block(nil)
            }
        }))
    }
    
    struct MustacheBlockFilter: MustacheFilter {
        let block: (MustacheValue, NSErrorPointer) -> (MustacheValue?)
        
        func filterWithAppliedArgument(argument: MustacheValue) -> MustacheFilter? {
            return nil
        }
        
        func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
            return block(value, outError)
        }
    }
}


// =============================================================================
// MARK: - MustacheRenderable Convenience Initializers

extension MustacheValue {
    
    convenience init(_ block: (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?)) {
        self.init(MustacheBlockRenderable(block: block))
    }
    
    struct MustacheBlockRenderable: MustacheRenderable {
        let block: (tag: MustacheTag, renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?)
        
        func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
            return block(tag: tag, renderingInfo: renderingInfo, contentType: outContentType, error: outError)
        }
    }
}


// =============================================================================
// MARK: - MustacheCluster Convenience Initializers

extension MustacheValue {
    
    convenience init(_ object: protocol<MustacheFilter>) {
        self.init(MustacheClusterWrapper(object))
    }

    convenience init(_ object: protocol<MustacheRenderable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheTagObserver>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheTagObserver>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheRenderable, MustacheTagObserver>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheRenderable, MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheClusterWrapper(object))
    }

    convenience init(_ object: protocol<MustacheCluster, MustacheFilter>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheRenderable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheTagObserver>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheRenderable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheRenderable, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheTagObserver, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    convenience init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
        self.init(object as MustacheCluster)
    }
    
    struct MustacheClusterWrapper: MustacheCluster {
        let mustacheBool = true
        let mustacheFilter: MustacheFilter?
        let mustacheRenderable: MustacheRenderable?
        let mustacheTagObserver: MustacheTagObserver?
        let mustacheTraversable: MustacheTraversable?
        
        init(_ object: protocol<MustacheFilter>) {
            mustacheFilter = object
        }
        
        init(_ object: protocol<MustacheRenderable>) {
            mustacheRenderable = object
        }
        
        init(_ object: protocol<MustacheTagObserver>) {
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<MustacheTraversable>) {
            mustacheTraversable = object
        }

        init(_ object: protocol<MustacheFilter, MustacheRenderable>) {
            mustacheFilter = object
            mustacheRenderable = object
        }
        
        init(_ object: protocol<MustacheFilter, MustacheTagObserver>) {
            mustacheFilter = object
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<MustacheFilter, MustacheTraversable>) {
            mustacheFilter = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<MustacheRenderable, MustacheTagObserver>) {
            mustacheRenderable = object
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<MustacheRenderable, MustacheTraversable>) {
            mustacheRenderable = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<MustacheTagObserver, MustacheTraversable>) {
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>) {
            mustacheFilter = object
            mustacheRenderable = object
            mustacheTagObserver = object
        }
        
        init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>) {
            mustacheFilter = object
            mustacheRenderable = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<MustacheFilter, MustacheTagObserver, MustacheTraversable>) {
            mustacheFilter = object
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
            mustacheRenderable = object
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
        init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
            mustacheFilter = object
            mustacheRenderable = object
            mustacheTagObserver = object
            mustacheTraversable = object
        }
        
    }
    
}


// =============================================================================
// MARK: - Value unwrapping

extension MustacheValue {
    
    func object() -> AnyObject? {
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
    
    func object() -> MustacheObject? {
        switch type {
        case .ObjectValue(let object):
            return object
        case .ClusterValue(let cluster):
            return cluster
        default:
            return nil
        }
    }
    
    func object<T: MustacheObject>() -> T? {
        switch type {
        case .ObjectValue(let object):
            return object as? T
        case .ClusterValue(let cluster):
            return cluster as? T
        default:
            return nil
        }
    }
    
    func object() -> MustacheCluster? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster
        default:
            return nil
        }
    }
    
    func object<T: MustacheCluster>() -> T? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster as? T
        default:
            return nil
        }
    }
    
    func object() -> [String: MustacheValue]? {
        switch type {
        case .DictionaryValue(let dictionary):
            return dictionary
        default:
            return nil
        }
    }
    
    func object() -> [MustacheValue]? {
        switch type {
        case .ArrayValue(let array):
            return array
        default:
            return nil
        }
    }
    
    func int() -> Int? {
        if let int: Int = object() {
            return int
        } else if let double: Double = object() {
            return Int(double)
        } else {
            return nil
        }
    }
    
    func double() -> Double? {
        if let int: Int = object() {
            return Double(int)
        } else if let double: Double = object() {
            return double
        } else {
            return nil
        }
    }
    
    func string() -> String? {
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
        case .ObjectValue(let object):
            return "\(object)"
        case .ClusterValue(let cluster):
            return "\(cluster)"
        }
    }
    
}


// =============================================================================
// MARK: - Convenience value unwrapping

extension MustacheValue {

    func object<T: protocol<MustacheFilter>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheRenderable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheRenderable as? T
    }
    
    func object<T: protocol<MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheTagObserver as? T
    }
    
    func object<T: protocol<MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheTraversable as? T
    }
    
    func object<T: protocol<MustacheFilter, MustacheRenderable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheFilter, MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheFilter, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheRenderable, MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheRenderable as? T
    }
    
    func object<T: protocol<MustacheRenderable, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheRenderable as? T
    }
    
    func object<T: protocol<MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheTagObserver as? T
    }
    
    func object<T: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheFilter, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheRenderable as? T
    }
    
    func object<T: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?)?.mustacheFilter as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheRenderable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheRenderable, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
    func object<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return (object() as MustacheCluster?) as? T
    }
    
}


// =============================================================================
// MARK: - DebugPrintable

extension MustacheValue: DebugPrintable {
    
    var debugDescription: String {
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
        case .ObjectValue(let object):
            return "Object(\(object))"
        case .ClusterValue(let cluster):
            return "Cluster(\(cluster))"
        }
    }
}


// =============================================================================
// MARK: - Key extraction

extension MustacheValue {
    
    subscript(identifier: String) -> MustacheValue {
        switch type {
        case .None:
            return MustacheValue()
        case .AnyObjectValue(let object):
            return MustacheValue(object.valueForKey?(identifier))
        case .DictionaryValue(let dictionary):
            if let mustacheValue = dictionary[identifier] {
                return mustacheValue
            } else {
                return MustacheValue()
            }
        case .ArrayValue(let array):
            switch identifier {
            case "count":
                return MustacheValue(countElements(array))
            case "firstObject":
                if array.isEmpty {
                    return MustacheValue()
                } else {
                    return array[array.startIndex]
                }
            case "lastObject":
                if array.isEmpty {
                    return MustacheValue()
                } else {
                    return array[array.endIndex.predecessor()]
                }
            default:
                return MustacheValue()
            }
        case .SetValue(let set):
            switch identifier {
            case "count":
                return MustacheValue(set.count)
            case "anyObject":
                return MustacheValue(set.anyObject())
            default:
                return MustacheValue()
            }
        case .ObjectValue(let object):
            return MustacheValue()
        case .ClusterValue(let cluster):
            if let traversable = cluster.mustacheTraversable {
                if let value = traversable.valueForMustacheIdentifier(identifier) {
                    return value
                } else {
                    return MustacheValue()
                }
            } else {
                return MustacheValue()
            }
        }
    }
}


// =============================================================================
// MARK: - Rendering

extension MustacheValue {

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
        case .ObjectValue(let object):
            return true
        case .ClusterValue(let cluster):
            return cluster.mustacheBool
        }
    }

    func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
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
                    if let itemRendering = MustacheValue(item).renderForMustacheTag(tag, renderingInfo: enumerationRenderingInfo, contentType: &itemContentType, error: outError) {
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
        case .ObjectValue(let object):
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
