//
//  MustacheRenderable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

struct RenderingOptions {
    let context: Context
    let enumerationItem: Bool
}

enum MustacheValue {
    case None
    case BoolValue(Bool)
    case IntValue(Int)
    case DoubleValue(Double)
    case StringValue(String)
    case DictionaryValue([String: MustacheValue])
    case ArrayValue([MustacheValue])
    case ObjCValue(AnyObject)
    case FilterValue(Filter)
    
    var mustacheBoolValue: Bool {
        switch self {
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
        case .ObjCValue(let object):
            if let _ = object as? NSNull {
                return false
            } else if let number = object as? NSNumber {
                return number.boolValue
            } else if let string = object as? NSString {
                return string.length > 0
            } else if let array = object as? NSArray {
                return array.count > 0
            } else {
                return true
            }
        case .FilterValue(_):
            return true
        }
    }
    
    func renderMustacheTag(tag: Tag, options: RenderingOptions, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        switch self {
        case .None:
            switch tag.type {
            case .Variable:
                return (rendering: "", contentType: .HTML)
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context, error: outError)
            }
        case .BoolValue(let bool):
            switch tag.type {
            case .Variable:
                return (rendering: "\(bool)", contentType: .HTML)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
                } else {
                    return tag.renderContentWithContext(options.context, error: outError)
                }
            }
        case .IntValue(let int):
            switch tag.type {
            case .Variable:
                return (rendering: "\(int)", contentType: .HTML)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
                } else {
                    return tag.renderContentWithContext(options.context, error: outError)
                }
            }
        case .DoubleValue(let double):
            switch tag.type {
            case .Variable:
                return (rendering: "\(double)", contentType: .HTML)
            case .Section, .InvertedSection:
                if options.enumerationItem {
                    return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
                } else {
                    return tag.renderContentWithContext(options.context, error: outError)
                }
            }
        case .StringValue(let string):
            switch tag.type {
            case .Variable:
                return (rendering:string, contentType:.Text)
                
            case .Section:
                return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
                
            case .InvertedSection:
                return tag.renderContentWithContext(options.context, error: outError)
            }
        case .DictionaryValue(let dictionary):
            switch tag.type {
            case .Variable:
                return (rendering:"\(self)", contentType:.Text)
                
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
            }
        case .ArrayValue(let array):
            if options.enumerationItem {
                return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
            } else {
                var buffer = ""
                var contentType: ContentType?
                var empty = true
                for item in array {
                    empty = true
                    let itemOptions = RenderingOptions(context: options.context, enumerationItem: true)
                    if let (itemRendering, itemContentType) = item.renderMustacheTag(tag, options: itemOptions, error: outError) {
                        if contentType == nil {
                            contentType = itemContentType
                            buffer = buffer + itemRendering
                        } else if contentType == itemContentType {
                            buffer = buffer + itemRendering
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
                        return (rendering: "", contentType: .HTML)
                    case .Section, .InvertedSection:
                        return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
                    }
                } else {
                    return (rendering: buffer, contentType: contentType!)
                }
            }
        case .ObjCValue(let object):
            if let _ = object as? NSNull {
                return (rendering:"", contentType:.Text)
            } else {
                return (rendering:"\(object)", contentType:.Text)
            }
        case .FilterValue(_):
            switch tag.type {
            case .Variable:
                return (rendering:"[Filter]", contentType:.Text)
                
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context.contextByAddingValue(self), error: outError)
                
            case .InvertedSection:
                return tag.renderContentWithContext(options.context, error: outError)
            }
        }
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue {
        switch self {
        case .None:
            return .None
        case .BoolValue:
            return .None
        case .IntValue:
            return .None
        case .DoubleValue:
            return .None
        case .StringValue:
            return .None
        case .DictionaryValue(let dictionary):
            if let value = dictionary[identifier] {
                return value
            } else {
                return .None
            }
        case .ArrayValue(let array):
            switch identifier {
            case "count":
                return .IntValue(countElements(array))
            default:
                return .None
            }
        case .ObjCValue(let object):
            if let value: AnyObject = object.valueForKey(identifier) {
                return .ObjCValue(value)
            } else {
                return .None
            }
        case .FilterValue(_):
            return .None
        }
    }
}
