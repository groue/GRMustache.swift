//
//  MustacheRenderable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

struct MustacheRendering {
    let string: String
    let contentType: ContentType
}

struct MustacheValue {
    let type: Type
    
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
        type = .RenderableValue(MustacheFilterRenderable(filter: filter))
    }
    
    init(_ tagObserver: MustacheTagObserver) {
        type = .RenderableValue(MustacheTagObserverRenderable(tagObserver: tagObserver))
    }
    
    init(_ object: MustacheRenderable) {
        type = .RenderableValue(object)
    }
    
    // Extra initializer which avoids ambiguity and does not force the user to
    // perform an explicit cast to MustacheRenderable
    init(_ object: protocol<MustacheRenderable, MustacheFilter>) {
        type = .RenderableValue(object)
    }
    
    // Extra initializer which avoids ambiguity and does not force the user to
    // perform an explicit cast to MustacheRenderable
    init(_ object: protocol<MustacheRenderable, MustacheTagObserver>) {
        type = .RenderableValue(object)
    }
    
    // Extra initializer which avoids ambiguity and does not force the user to
    // perform an explicit cast to MustacheRenderable
    init(_ object: protocol<MustacheRenderable, MustacheFilter, MustacheTagObserver>) {
        type = .RenderableValue(object)
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
        case .RenderableValue(let object):
            return object.mustacheBoolValue
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
        case .RenderableValue(let object):
            if let value = object.valueForMustacheIdentifier(identifier) {
                return value
            } else {
                return MustacheValue()
            }
        }
    }
    
    func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> MustacheRendering? {
        switch type {
        case .None:
            switch tag.type {
            case .Variable:
                return MustacheRendering(string: "", contentType: .Text)
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(context, error: outError)
            }
        case .BoolValue(let bool):
            switch tag.type {
            case .Variable:
                return MustacheRendering(string: "\(bool)", contentType: .Text)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
                } else {
                    return tag.renderContentWithContext(context, error: outError)
                }
            }
        case .IntValue(let int):
            switch tag.type {
            case .Variable:
                return MustacheRendering(string: "\(int)", contentType: .Text)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
                } else {
                    return tag.renderContentWithContext(context, error: outError)
                }
            }
        case .DoubleValue(let double):
            switch tag.type {
            case .Variable:
                return MustacheRendering(string: "\(double)", contentType: .Text)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
                } else {
                    return tag.renderContentWithContext(context, error: outError)
                }
            }
        case .StringValue(let string):
            switch tag.type {
            case .Variable:
                return MustacheRendering(string: string, contentType: .Text)
                
            case .Section:
                // TODO: why isn't it the same rendering code as Number?
                return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
                
            case .InvertedSection:
                // TODO: why isn't it the same rendering code as Number?
                return tag.renderContentWithContext(context, error: outError)
            }
        case .DictionaryValue(let dictionary):
            switch tag.type {
            case .Variable:
                return MustacheRendering(string: "\(dictionary)", contentType: .Text)
                
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
            }
        case .ArrayValue(let array):
            if options.enumerationItem {
                return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                for item in array {
                    empty = false
                    let itemOptions = RenderingOptions(enumerationItem: true)
                    if let itemRendering = item.renderForMustacheTag(tag, context: context, options: itemOptions, error: outError) {
                        if contentType == nil {
                            contentType = itemRendering.contentType
                            buffer = buffer + itemRendering.string
                        } else if contentType == itemRendering.contentType {
                            buffer = buffer + itemRendering.string
                        } else {
                            if outError != nil {
                                outError.memory = NSError(domain: "TODO", code: 0, userInfo: nil)
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
                        return MustacheRendering(string: "", contentType: .Text)
                    case .Section, .InvertedSection:
                        return tag.renderContentWithContext(context, error: outError)
                    }
                } else {
                    return MustacheRendering(string: buffer, contentType: contentType!)
                }
            }
        case .SetValue(let set):
            if options.enumerationItem {
                return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                for item in set {
                    empty = false
                    let itemOptions = RenderingOptions(enumerationItem: true)
                    if let itemRendering = MustacheValue(item).renderForMustacheTag(tag, context: context, options: itemOptions, error: outError) {
                        if contentType == nil {
                            contentType = itemRendering.contentType
                            buffer = buffer + itemRendering.string
                        } else if contentType == itemRendering.contentType {
                            buffer = buffer + itemRendering.string
                        } else {
                            if outError != nil {
                                outError.memory = NSError(domain: "TODO", code: 0, userInfo: nil)
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
                        return MustacheRendering(string: "", contentType: .Text)
                    case .Section, .InvertedSection:
                        return tag.renderContentWithContext(context, error: outError)
                    }
                } else {
                    return MustacheRendering(string: buffer, contentType: contentType!)
                }
            }
        case .ObjCValue(let object):
            switch tag.type {
            case .Variable:
                return MustacheRendering(string: "\(object)", contentType: .Text)
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(context.contextByAddingValue(self), error: outError)
            }
        case .RenderableValue(let object):
            return object.renderForMustacheTag(tag, context: context, options: options, error: outError)
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
        case .RenderableValue(let object):
            return "\(object)"
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
        case RenderableValue(MustacheRenderable)
    }
}

struct MustacheFilterRenderable: MustacheRenderable {
    let filter: MustacheFilter
    
    init(filter: MustacheFilter) {
        self.filter = filter
    }
    
    let mustacheBoolValue = true
    var mustacheFilter: MustacheFilter? { return filter }
    let mustacheTagObserver: MustacheTagObserver? = nil
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return nil
    }
    
    func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> MustacheRendering? {
        switch tag.type {
        case .Variable:
            return MustacheRendering(string: "\(mustacheFilter)", contentType: .Text)
        case .Section, .InvertedSection:
            return tag.renderContentWithContext(context.contextByAddingValue(MustacheValue(self)), error: outError)
        }
    }
}

struct MustacheTagObserverRenderable: MustacheRenderable {
    let tagObserver: MustacheTagObserver
    
    init(tagObserver: MustacheTagObserver) {
        self.tagObserver = tagObserver
    }
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    var mustacheTagObserver: MustacheTagObserver? { return tagObserver }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return nil
    }
    
    func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> MustacheRendering? {
        switch tag.type {
        case .Variable:
            return MustacheRendering(string: "\(tagObserver)", contentType: .Text)
        case .Section, .InvertedSection:
            return tag.renderContentWithContext(context.contextByAddingTagObserver(tagObserver), error: outError)
        }
    }
}
