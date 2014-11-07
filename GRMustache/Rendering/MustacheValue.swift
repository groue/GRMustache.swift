//
//  MustacheCluster.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation


// =============================================================================
// MARK: - Initialization

class MustacheValue {
    
    enum Type {
        case None
        case BoolValue(Bool)
        case IntValue(Int)
        case DoubleValue(Double)
        case StringValue(String)
        case DictionaryValue([String: MustacheValue])
        case ArrayValue([MustacheValue])
        case SetValue(NSSet)
        case ObjCValue(AnyObject)
        case ClusterValue(MustacheCluster)
    }
    
    let type: Type
    
    init() {
        type = .None
    }
    
    // MARK: Bool
    
    init(_ bool: Bool) {
        type = .BoolValue(bool)
    }
    
    // MARK: Int
    
    init(_ int: Int) {
        type = .IntValue(int)
    }
    
    // MARK: Double
    
    init(_ double: Double) {
        type = .DoubleValue(double)
    }
    
    // MARK: String
    
    init(_ string: String) {
        type = .StringValue(string)
    }
    
    // MARK: Dictionary
    
    init(_ dictionary: [String: MustacheValue]) {
        type = .DictionaryValue(dictionary)
    }
    
    convenience init(_ dictionary: [String: AnyObject]) {
        var mustacheDictionary: [String: MustacheValue] = [:]
        for (key, value) in dictionary {
            mustacheDictionary[key] = MustacheValue(value)
        }
        self.init(mustacheDictionary)
    }
    
    // MARK: Array
    
    init(_ array: [MustacheValue]) {
        type = .ArrayValue(array)
    }
    
    // MARK: MustacheFilter
    
    init(_ filter: MustacheFilter) {
        type = .ClusterValue(MustacheFilterCluster(filter: filter))
    }
    
    convenience init(_ filter: (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?)) {
        self.init(MustacheBlockFilter(filter))
    }
    
    convenience init(_ filter: (values: [MustacheValue], error: NSErrorPointer) -> (MustacheValue?)) {
        self.init(MustacheBlockVariadicFilter(filter, arguments: []))
    }
    
    convenience init(_ filter: (Int?) -> (MustacheValue?)) {
        self.init(filter, compute: MustacheValue.intValue)
    }
    
    convenience init(_ filter: (Double?) -> (MustacheValue?)) {
        self.init(filter, compute: MustacheValue.doubleValue)
    }
    
    convenience init(_ filter: (String?) -> (MustacheValue?)) {
        self.init(filter, compute: MustacheValue.stringValue)
    }
    
    private convenience init<T>(_ filter: (T?) -> (MustacheValue?), compute: MustacheValue -> () -> (T?)) {
        self.init(MustacheBlockFilter({ (value: MustacheValue, outError: NSErrorPointer) -> (MustacheValue?) in
            switch value.type {
            case .None:
                return filter(nil)
            default:
                if let value = compute(value)() {
                    return filter(value)
                } else {
                    if outError != nil {
                        outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: \(T.self) expected"])
                    }
                    return nil
                }
            }
        }))
    }
    
    // MARK: MustacheRenderable
    
    init(_ renderable: MustacheRenderable) {
        type = .ClusterValue(MustacheRenderableCluster(renderable: renderable))
    }
    
    convenience init(_ block: (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?)) {
        self.init(MustacheBlockRenderable(block))
    }
    
    // MARK: MustacheTagObserver
    
    init(_ tagObserver: MustacheTagObserver) {
        type = .ClusterValue(MustacheTagObserverCluster(tagObserver: tagObserver))
    }
    
    // MARK: MustacheTraversable
    
    init(_ traversable: MustacheTraversable) {
        type = .ClusterValue(MustacheTraversableCluster(traversable: traversable))
    }
    
    // MARK: MustacheCluster
    
    init(_ object: MustacheCluster) {
        type = .ClusterValue(object)
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable>) {
        self.init(MustacheFilterRenderableCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheTagObserver>) {
        self.init(MustacheFilterTagObserverCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheTraversable>) {
        self.init(MustacheFilterTraversableCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheRenderable, MustacheTagObserver>) {
        self.init(MustacheRenderableTagObserverCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheRenderable, MustacheTraversable>) {
        self.init(MustacheRenderableTraversableCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheTagObserverTraversableCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>) {
        self.init(MustacheFilterRenderableTagObserverCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>) {
        self.init(MustacheFilterRenderableTraversableCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheFilterTagObserverTraversableCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheRenderableTagObserverTraversableCluster(object: object))
    }
    
    convenience init(_ object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
        self.init(MustacheFilterRenderableTagObserverTraversableCluster(object: object))
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
    
    // MARK: AnyObject?
    
    init(_ object: AnyObject?) {
        if let object: AnyObject = object {
            if object is NSNull {
                type = .None
            } else if let number = object as? NSNumber {
                let objCType = number.objCType
                let str = String.fromCString(objCType)
                switch str! {
                case "c", "i", "s", "l", "q", "C", "I", "S", "L", "Q":
                    type = .IntValue(Int(number.longLongValue))
                case "f", "d":
                    type = .DoubleValue(number.doubleValue)
                case "B":
                    type = .BoolValue(number.boolValue)
                default:
                    fatalError("Not implemented yet")
                }
            } else if let string = object as? NSString {
                type = .StringValue(string)
            } else if let dictionary = object as? NSDictionary {
                var canonicalDictionary: [String: MustacheValue] = [:]
                dictionary.enumerateKeysAndObjectsUsingBlock({ (key, value, _) -> Void in
                    canonicalDictionary["\(key)"] = MustacheValue(value)
                })
                type = .DictionaryValue(canonicalDictionary)
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
                        type = .ArrayValue(array)
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
                        type = .SetValue(set)
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
                    type = .ArrayValue(array)
                }
            } else {
                type = .ObjCValue(object)
            }
        } else {
            type = .None
        }
    }
}


// =============================================================================
// MARK: - DebugPrintable

extension MustacheValue: DebugPrintable {
    
    var debugDescription: String {
        switch type {
        case .None:
            return "None"
        case .BoolValue(let bool):
            return "Bool(\(bool))"
        case .IntValue(let int):
            return "Int(\(int))"
        case .DoubleValue(let double):
            return "Int(\(double))"
        case .StringValue(let string):
            return "String(\"\(string)\")"
        case .DictionaryValue(let dictionary):
            return "Dictionary(\(dictionary.debugDescription))"
        case .ArrayValue(let array):
            return "Array(\(array.debugDescription))"
        case .SetValue(let set):
            return "Set(\(set))"
        case .ObjCValue(let object):
            return "ObjC(\(object))"
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
        case .BoolValue:
            return MustacheValue()
        case .IntValue:
            return MustacheValue()
        case .DoubleValue:
            return MustacheValue()
        case .StringValue:
            return MustacheValue()
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
        case .ObjCValue(let object):
            return MustacheValue(object.valueForKey?(identifier))
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
// MARK: - Value unwrapping

extension MustacheValue {
    
    func boolValue() -> Bool? {
        switch type {
        case .BoolValue(let bool):
            return bool
        default:
            return nil
        }
    }
    
    func intValue() -> Int? {
        switch type {
        case .IntValue(let int):
            return int
        case .DoubleValue(let double):
            return Int(double)
        default:
            return nil
        }
    }
    
    func doubleValue() -> Double? {
        switch type {
        case .IntValue(let int):
            return Double(int)
        case .DoubleValue(let double):
            return double
        default:
            return nil
        }
    }
    
    func stringValue() -> String? {
        switch type {
        case .None:
            return nil
        case .BoolValue(let bool):
            return "\(bool)"
        case .IntValue(let int):
            return "\(int)"
        case .DoubleValue(let double):
            return "\(double)"
        case .StringValue(let string):
            return string
        case .DictionaryValue(let dictionary):
            return "\(dictionary)"
        case .ArrayValue(let array):
            return "\(array)"
        case .SetValue(let set):
            return "\(set)"
        case .ObjCValue(let object):
            return "\(object)"
        case .ClusterValue(let cluster):
            return "\(cluster)"
        }
    }
    
    func dictionaryValue() -> [String: MustacheValue]? {
        switch type {
        case .DictionaryValue(let dictionary):
            return dictionary
        default:
            return nil
        }
    }
    
    func dictionaryValue() -> [String: AnyObject]? {
        switch type {
        case .DictionaryValue(let dictionary):
            var result: [String: AnyObject] = [:]
            for (key, value) in dictionary {
                if let object: AnyObject = value.anyObjectValue() {
                    result[key] = object
                }
            }
            return result
        default:
            return nil
        }
    }
    
    func arrayValue() -> [MustacheValue]? {
        switch type {
        case .ArrayValue(let array):
            return array
        default:
            return nil
        }
    }
    
    func arrayValue() -> [AnyObject]? {
        switch type {
        case .ArrayValue(let array):
            var result: [AnyObject] = []
            for item in array {
                if let object: AnyObject = item.anyObjectValue() {
                    result.append(object)
                }
            }
            return result
        default:
            return nil
        }
    }
    
    func setValue() -> NSSet? {
        switch type {
        case .SetValue(let set):
            return set
        default:
            return nil
        }
    }
    
    func anyObjectValue() -> AnyObject? {
        switch type {
        case .None:
            return nil
        case .BoolValue(let bool):
            return bool
        case .IntValue(let int):
            return int
        case .DoubleValue(let double):
            return double
        case .StringValue(let string):
            return string
        case .DictionaryValue:
            return dictionaryValue() as [String: AnyObject]?
        case .ArrayValue(let array):
            return arrayValue() as [AnyObject]?
        case .SetValue(let set):
            return set
        case .ObjCValue(let object):
            return object
        case .ClusterValue(let cluster):
            return nil
        }
    }
    
    func filterValue() -> MustacheFilter? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster.mustacheFilter
        default:
            return nil
        }
    }
    
    func renderableValue() -> MustacheRenderable? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster.mustacheRenderable
        default:
            return nil
        }
    }
    
    func tagObserverValue() -> MustacheTagObserver? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster.mustacheTagObserver
        default:
            return nil
        }
    }
    
    func traversableValue() -> MustacheTraversable? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster.mustacheTraversable
        default:
            return nil
        }
    }
    
    func clusterValue() -> MustacheCluster? {
        switch type {
        case .ClusterValue(let cluster):
            return cluster
        default:
            return nil
        }
    }
    
    func value() -> Bool? {
        return boolValue()
    }
    
    func value() -> Int? {
        return intValue()
    }
    
    func value() -> Double? {
        return doubleValue()
    }
    
    func value() -> String? {
        return stringValue()
    }
    
    func value() -> [String: MustacheValue]? {
        return dictionaryValue()
    }
    
    func value() -> [String: AnyObject]? {
        return dictionaryValue()
    }
    
    func value() -> [MustacheValue]? {
        return arrayValue()
    }
    
    func value() -> [AnyObject]? {
        return arrayValue()
    }
    
    func value() -> NSSet? {
        return setValue()
    }
    
    func value() -> AnyObject? {
        return anyObjectValue()
    }
    
    func value() -> MustacheFilter? {
        return filterValue()
    }
    
    func value() -> MustacheRenderable? {
        return renderableValue()
    }
    
    func value() -> MustacheTagObserver? {
        return tagObserverValue()
    }
    
    func value() -> MustacheTraversable? {
        return traversableValue()
    }
    
    func value() -> MustacheCluster? {
        return clusterValue()
    }
    
    func value<T: MustacheFilter>() -> T? {
        return filterValue() as? T
    }
    
    func value<T: MustacheRenderable>() -> T? {
        return renderableValue() as? T
    }
    
    func value<T: MustacheTagObserver>() -> T? {
        return tagObserverValue() as? T
    }
    
    func value<T: MustacheTraversable>() -> T? {
        return traversableValue() as? T
    }
    
    func value<T: MustacheCluster>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheFilter, MustacheRenderable>>() -> T? {
        return filterValue() as? T
    }
    
    func value<T: protocol<MustacheFilter, MustacheTagObserver>>() -> T? {
        return filterValue() as? T
    }
    
    func value<T: protocol<MustacheFilter, MustacheTraversable>>() -> T? {
        return filterValue() as? T
    }
    
    func value<T: protocol<MustacheRenderable, MustacheTagObserver>>() -> T? {
        return renderableValue() as? T
    }
    
    func value<T: protocol<MustacheRenderable, MustacheTraversable>>() -> T? {
        return renderableValue() as? T
    }
    
    func value<T: protocol<MustacheTagObserver, MustacheTraversable>>() -> T? {
        return tagObserverValue() as? T
    }
    
    func value<T: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>>() -> T? {
        return filterValue() as? T
    }
    
    func value<T: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>>() -> T? {
        return filterValue() as? T
    }
    
    func value<T: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return renderableValue() as? T
    }
    
    func value<T: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return filterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheFilter>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheRenderable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheTagObserver>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheTraversable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheFilter, MustacheTraversable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheRenderable, MustacheTraversable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTraversable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return clusterValue() as? T
    }
    
    func value<T: protocol<MustacheCluster, MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>>() -> T? {
        return clusterValue() as? T
    }
    
}


// =============================================================================
// MARK: - Rendering

extension MustacheValue {
    
    var mustacheBoolValue: Bool {
        switch type {
        case .None:
            return false
        case .BoolValue(let bool):
            return bool
        case .IntValue(let int):
            return int != 0
        case .DoubleValue(let double):
            return double != 0.0
        case .StringValue(let string):
            return countElements(string) > 0
        case .DictionaryValue:
            return true
        case .ArrayValue(let array):
            return countElements(array) > 0
        case .SetValue(let set):
            return set.count > 0
        case .ObjCValue(let object):
            return true
        case .ClusterValue(let cluster):
            return cluster.mustacheBoolValue
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
        case .BoolValue(let bool):
            switch tag.type {
            case .Variable:
                return "\(bool)"
            case .Section:
                if renderingInfo.enumerationItem {
                    let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                    return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                } else {
                    return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                }
            }
        case .IntValue(let int):
            switch tag.type {
            case .Variable:
                return "\(int)"
            case .Section:
                if renderingInfo.enumerationItem {
                    let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                    return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                } else {
                    return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                }
            }
        case .DoubleValue(let double):
            switch tag.type {
            case .Variable:
                return "\(double)"
            case .Section:
                if renderingInfo.enumerationItem {
                    let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                    return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                } else {
                    return tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
                }
            }
        case .StringValue(let string):
            switch tag.type {
            case .Variable:
                return string
            case .Section:
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
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
        case .ObjCValue(let object):
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


// =============================================================================
// MARK: - Support types

extension MustacheValue {
    struct MustacheFilterCluster: MustacheCluster {
        let filter: MustacheFilter
        
        init(filter: MustacheFilter) {
            self.filter = filter
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return filter }
        let mustacheRenderable: MustacheRenderable? = nil
        let mustacheTagObserver: MustacheTagObserver? = nil
        let mustacheTraversable: MustacheTraversable? = nil
    }
    
    struct MustacheRenderableCluster: MustacheCluster {
        let renderable: MustacheRenderable
        
        init(renderable: MustacheRenderable) {
            self.renderable = renderable
        }
        
        let mustacheBoolValue = true
        let mustacheFilter: MustacheFilter? = nil
        var mustacheRenderable: MustacheRenderable? { return renderable }
        let mustacheTagObserver: MustacheTagObserver? = nil
        let mustacheTraversable: MustacheTraversable? = nil
    }
    
    struct MustacheTagObserverCluster: MustacheCluster {
        let tagObserver: MustacheTagObserver
        
        init(tagObserver: MustacheTagObserver) {
            self.tagObserver = tagObserver
        }
        
        let mustacheBoolValue = true
        let mustacheFilter: MustacheFilter? = nil
        let mustacheRenderable: MustacheRenderable? = nil
        var mustacheTagObserver: MustacheTagObserver? { return tagObserver }
        let mustacheTraversable: MustacheTraversable? = nil
    }
    
    struct MustacheTraversableCluster: MustacheCluster {
        let traversable: MustacheTraversable
        
        init(traversable: MustacheTraversable) {
            self.traversable = traversable
        }
        
        let mustacheBoolValue = true
        let mustacheFilter: MustacheFilter? = nil
        let mustacheRenderable: MustacheRenderable? = nil
        let mustacheTagObserver: MustacheTagObserver? = nil
        var mustacheTraversable: MustacheTraversable? { return traversable }
    }
    
    struct MustacheFilterRenderableCluster: MustacheCluster {
        let object: protocol<MustacheFilter, MustacheRenderable>
        
        init(object: protocol<MustacheFilter, MustacheRenderable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return object }
        var mustacheRenderable: MustacheRenderable? { return object }
        let mustacheTagObserver: MustacheTagObserver? = nil
        let mustacheTraversable: MustacheTraversable? = nil
    }
    
    struct MustacheFilterTagObserverCluster: MustacheCluster {
        let object: protocol<MustacheFilter, MustacheTagObserver>
        
        init(object: protocol<MustacheFilter, MustacheTagObserver>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return object }
        let mustacheRenderable: MustacheRenderable? = nil
        var mustacheTagObserver: MustacheTagObserver? { return object }
        let mustacheTraversable: MustacheTraversable? = nil
    }
    
    struct MustacheFilterTraversableCluster: MustacheCluster {
        let object: protocol<MustacheFilter, MustacheTraversable>
        
        init(object: protocol<MustacheFilter, MustacheTraversable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return object }
        let mustacheRenderable: MustacheRenderable? = nil
        let mustacheTagObserver: MustacheTagObserver? = nil
        var mustacheTraversable: MustacheTraversable? { return object }
    }
    
    struct MustacheRenderableTagObserverCluster: MustacheCluster {
        let object: protocol<MustacheRenderable, MustacheTagObserver>
        
        init(object: protocol<MustacheRenderable, MustacheTagObserver>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        let mustacheFilter: MustacheFilter? = nil
        var mustacheRenderable: MustacheRenderable? { return object }
        var mustacheTagObserver: MustacheTagObserver? { return object }
        let mustacheTraversable: MustacheTraversable? = nil
    }
    
    struct MustacheRenderableTraversableCluster: MustacheCluster {
        let object: protocol<MustacheRenderable, MustacheTraversable>
        
        init(object: protocol<MustacheRenderable, MustacheTraversable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        let mustacheFilter: MustacheFilter? = nil
        var mustacheRenderable: MustacheRenderable? { return object }
        let mustacheTagObserver: MustacheTagObserver? = nil
        var mustacheTraversable: MustacheTraversable? { return object }
    }
    
    struct MustacheTagObserverTraversableCluster: MustacheCluster {
        let object: protocol<MustacheTagObserver, MustacheTraversable>
        
        init(object: protocol<MustacheTagObserver, MustacheTraversable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        let mustacheFilter: MustacheFilter? = nil
        let mustacheRenderable: MustacheRenderable? = nil
        var mustacheTagObserver: MustacheTagObserver? { return object }
        var mustacheTraversable: MustacheTraversable? { return object }
    }
    
    struct MustacheFilterRenderableTagObserverCluster: MustacheCluster {
        let object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>
        
        init(object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return object }
        var mustacheRenderable: MustacheRenderable? { return object }
        var mustacheTagObserver: MustacheTagObserver? { return object }
        let mustacheTraversable: MustacheTraversable? = nil
    }
    
    struct MustacheFilterRenderableTraversableCluster: MustacheCluster {
        let object: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>
        
        init(object: protocol<MustacheFilter, MustacheRenderable, MustacheTraversable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return object }
        var mustacheRenderable: MustacheRenderable? { return object }
        let mustacheTagObserver: MustacheTagObserver? = nil
        var mustacheTraversable: MustacheTraversable? { return object }
    }
    
    struct MustacheFilterTagObserverTraversableCluster: MustacheCluster {
        let object: protocol<MustacheFilter, MustacheTagObserver, MustacheTraversable>
        
        init(object: protocol<MustacheFilter, MustacheTagObserver, MustacheTraversable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return object }
        let mustacheRenderable: MustacheRenderable? = nil
        var mustacheTagObserver: MustacheTagObserver? { return object }
        var mustacheTraversable: MustacheTraversable? { return object }
    }
    
    struct MustacheRenderableTagObserverTraversableCluster: MustacheCluster {
        let object: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>
        
        init(object: protocol<MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        let mustacheFilter: MustacheFilter? = nil
        var mustacheRenderable: MustacheRenderable? { return object }
        var mustacheTagObserver: MustacheTagObserver? { return object }
        var mustacheTraversable: MustacheTraversable? { return object }
    }
    
    struct MustacheFilterRenderableTagObserverTraversableCluster: MustacheCluster {
        let object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>
        
        init(object: protocol<MustacheFilter, MustacheRenderable, MustacheTagObserver, MustacheTraversable>) {
            self.object = object
        }
        
        let mustacheBoolValue = true
        var mustacheFilter: MustacheFilter? { return object }
        var mustacheRenderable: MustacheRenderable? { return object }
        var mustacheTagObserver: MustacheTagObserver? { return object }
        var mustacheTraversable: MustacheTraversable? { return object }
    }
    
    private class MustacheBlockFilter: MustacheFilter {
        let block: (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?)
        
        init(_ block: (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?)) {
            self.block = block
        }
        
        func filterWithAppliedArgument(argument: MustacheValue) -> MustacheFilter? {
            return nil
        }
        
        func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
            return block(value: value, error: outError)
        }
    }
    
    private class MustacheBlockVariadicFilter: MustacheFilter {
        let arguments: [MustacheValue]
        let block: (values: [MustacheValue], error: NSErrorPointer) -> (MustacheValue?)
        
        init(_ block: (values: [MustacheValue], error: NSErrorPointer) -> (MustacheValue?), arguments: [MustacheValue]) {
            self.block = block
            self.arguments = arguments
        }
        
        func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
            return block(values: arguments + [value], error: outError)
        }
        
        func filterWithAppliedArgument(argument: MustacheValue) -> MustacheFilter? {
            return MustacheBlockVariadicFilter(block, arguments: arguments + [argument])
        }
    }
    
    class MustacheBlockRenderable: MustacheRenderable {
        let block: (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?)
        
        init(_ block: (tag: MustacheTag, renderingInfo: RenderingInfo, outContentType: ContentTypePointer, outError: NSErrorPointer) -> (String?)) {
            self.block = block
        }
        
        func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
            return block(tag: tag, renderingInfo: renderingInfo, outContentType: outContentType, outError: outError)
        }
    }
}