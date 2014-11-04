//
//  MustacheCluster.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

struct MustacheValue: DebugPrintable {
    let type: Type

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
            return "Set(\(set.description))"
        case .ObjCValue(let object):
            return "ObjC(\(object.description))"
        case .ClusterValue(let cluster):
            return "Cluster(\(cluster))"
        }
    }
    
    init() {
        type = .None
    }
    
    init(_ bool: Bool) {
        type = .BoolValue(bool)
    }
    
    init(_ int: Int) {
        type = .IntValue(int)
    }
    
    init(_ double: Double) {
        type = .DoubleValue(double)
    }
    
    init(_ string: String) {
        type = .StringValue(string)
    }
    
    init(_ dictionary: [String: MustacheValue]) {
        type = .DictionaryValue(dictionary)
    }
    
    init(_ array: [MustacheValue]) {
        type = .ArrayValue(array)
    }
    
    init(_ filter: MustacheFilter) {
        type = .ClusterValue(MustacheFilterCluster(filter: filter))
    }
    
    init(_ traversable: MustacheTraversable) {
        type = .ClusterValue(MustacheTraversableCluster(traversable: traversable))
    }
    
    init(_ tagObserver: MustacheTagObserver) {
        type = .ClusterValue(MustacheTagObserverCluster(tagObserver: tagObserver))
    }
    
    init(_ object: MustacheCluster) {
        type = .ClusterValue(object)
    }
    
    init(_ object: protocol<MustacheFilter, MustacheTraversable>) {
        type = .ClusterValue(MustacheTraversableFilterCluster(object: object))
    }
    
    init(_ object: protocol<MustacheFilter, MustacheTagObserver>) {
        type = .ClusterValue(MustacheTagObserverFilterCluster(object: object))
    }
    
    init(_ object: protocol<MustacheTraversable, MustacheTagObserver>) {
        type = .ClusterValue(MustacheTraversableTagObserverCluster(object: object))
    }
    
    init(_ object: protocol<MustacheFilter, MustacheTraversable, MustacheTagObserver>) {
        type = .ClusterValue(MustacheFilterTraversableTagObserverCluster(object: object))
    }
    
    init(_ object: protocol<MustacheCluster, MustacheFilter>) {
        type = .ClusterValue(object)
    }
    
    init(_ object: protocol<MustacheCluster, MustacheTraversable>) {
        type = .ClusterValue(object)
    }
    
    init(_ object: protocol<MustacheCluster, MustacheTagObserver>) {
        type = .ClusterValue(object)
    }
    
    init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheTraversable>) {
        type = .ClusterValue(object)
    }
    
    init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheTagObserver>) {
        type = .ClusterValue(object)
    }
    
    init(_ object: protocol<MustacheCluster, MustacheTraversable, MustacheTagObserver>) {
        type = .ClusterValue(object)
    }
    
    init(_ object: protocol<MustacheCluster, MustacheFilter, MustacheTraversable, MustacheTagObserver>) {
        type = .ClusterValue(object)
    }
    
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
            if let _ = object as? NSNull {
                return false
            } else if let number = object as? NSNumber {
                return number.boolValue
            } else if let string = object as? NSString {
                return string.length > 0
            } else if let enumerable = object as? NSFastEnumeration {
                return NSFastGenerator(enumerable).next() != nil
            } else {
                return true
            }
        case .ClusterValue(let cluster):
            return cluster.mustacheBoolValue
        }
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue {
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
            return MustacheValue(object.valueForKey(identifier))
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
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        let tag = renderingInfo.tag
        switch type {
        case .None:
            switch tag.type {
            case .Variable:
                return ""
            case .Section, .InvertedSection:
                return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
        case .BoolValue(let bool):
            switch tag.type {
            case .Variable:
                return "\(bool)"
            case .Section, .InvertedSection:
                if renderingInfo.enumerationItem {
                    let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                    return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
                } else {
                    return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
                }
            }
        case .IntValue(let int):
            switch tag.type {
            case .Variable:
                return "\(int)"
            case .Section, .InvertedSection:
                if renderingInfo.enumerationItem {
                    let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                    return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
                } else {
                    return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
                }
            }
        case .DoubleValue(let double):
            switch tag.type {
            case .Variable:
                return "\(double)"
            case .Section, .InvertedSection:
                if renderingInfo.enumerationItem {
                    let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                    return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
                } else {
                    return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
                }
            }
        case .StringValue(let string):
            switch tag.type {
            case .Variable:
                return string
                
            case .Section:
                // TODO: why isn't it the same rendering code as Number?
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
                
            case .InvertedSection:
                // TODO: why isn't it the same rendering code as Number?
                return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
        case .DictionaryValue(let dictionary):
            switch tag.type {
            case .Variable:
                return "\(dictionary)"
                
            case .Section, .InvertedSection:
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
        case .ArrayValue(let array):
            if renderingInfo.enumerationItem {
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                let enumerationRenderingInfo = renderingInfo.renderingInfoBySettingEnumerationItem()
                for item in array {
                    empty = false
                    var itemContentType: ContentType = .Text
                    if let itemRendering = item.mustacheRendering(enumerationRenderingInfo, contentType: &itemContentType, error: outError) {
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
                    case .Section, .InvertedSection:
                        return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
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
                return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                let enumerationRenderingInfo = renderingInfo.renderingInfoBySettingEnumerationItem()
                for item in set {
                    empty = false
                    var itemContentType: ContentType = .Text
                    if let itemRendering = MustacheValue(item).mustacheRendering(enumerationRenderingInfo, contentType: &itemContentType, error: outError) {
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
                    case .Section, .InvertedSection:
                        return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
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
            case .Section, .InvertedSection:
                let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(self)
                return tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
            }
        case .ClusterValue(let cluster):
            return cluster.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
    
    func asString() -> String? {
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
}

struct MustacheFilterCluster: MustacheCluster {
    let filter: MustacheFilter
    
    init(filter: MustacheFilter) {
        self.filter = filter
    }
    
    let mustacheBoolValue = true
    var mustacheFilter: MustacheFilter? { return filter }
    let mustacheTagObserver: MustacheTagObserver? = nil
    var mustacheTraversable: MustacheTraversable? = nil
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(filter)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(self))
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}

struct MustacheTraversableCluster: MustacheCluster {
    let traversable: MustacheTraversable
    
    init(traversable: MustacheTraversable) {
        self.traversable = traversable
    }
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    let mustacheTagObserver: MustacheTagObserver? = nil
    var mustacheTraversable: MustacheTraversable? { return traversable }
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(traversable)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(self))
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}

struct MustacheTagObserverCluster: MustacheCluster {
    let tagObserver: MustacheTagObserver
    
    init(tagObserver: MustacheTagObserver) {
        self.tagObserver = tagObserver
    }
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    var mustacheTagObserver: MustacheTagObserver? { return tagObserver }
    var mustacheTraversable: MustacheTraversable? = nil
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(tagObserver)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(tagObserver)
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}

struct MustacheTraversableFilterCluster: MustacheCluster {
    let object: protocol<MustacheFilter, MustacheTraversable>
    
    init(object: protocol<MustacheFilter, MustacheTraversable>) {
        self.object = object
    }
    
    let mustacheBoolValue = true
    var mustacheFilter: MustacheFilter? { return object }
    let mustacheTagObserver: MustacheTagObserver? = nil
    var mustacheTraversable: MustacheTraversable? { return object }
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(object)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(self))
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}

struct MustacheTagObserverFilterCluster: MustacheCluster {
    let object: protocol<MustacheFilter, MustacheTagObserver>
    
    init(object: protocol<MustacheFilter, MustacheTagObserver>) {
        self.object = object
    }
    
    let mustacheBoolValue = true
    var mustacheFilter: MustacheFilter? { return object }
    var mustacheTagObserver: MustacheTagObserver? { return object }
    let mustacheTraversable: MustacheTraversable? = nil
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(object)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(self))
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}

struct MustacheTraversableTagObserverCluster: MustacheCluster {
    let object: protocol<MustacheTraversable, MustacheTagObserver>
    
    init(object: protocol<MustacheTraversable, MustacheTagObserver>) {
        self.object = object
    }
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    var mustacheTagObserver: MustacheTagObserver? { return object }
    var mustacheTraversable: MustacheTraversable? { return object }
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(object)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(self))
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}

struct MustacheFilterTraversableTagObserverCluster: MustacheCluster {
    let object: protocol<MustacheFilter, MustacheTraversable, MustacheTagObserver>
    
    init(object: protocol<MustacheFilter, MustacheTraversable, MustacheTagObserver>) {
        self.object = object
    }
    
    let mustacheBoolValue = true
    var mustacheFilter: MustacheFilter? { return object }
    var mustacheTagObserver: MustacheTagObserver? { return object }
    var mustacheTraversable: MustacheTraversable? { return object }
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(object)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(self))
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}
