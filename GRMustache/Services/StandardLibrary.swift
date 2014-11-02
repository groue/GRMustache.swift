//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class StandardLibrary: MustacheRenderable {
    let items: [String: MustacheValue]
    init() {
        var items: [String: MustacheValue] = [:]
        
        items["capitalized"] = MustacheValue(MustacheFilterWithBlock({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.capitalizedString)
        }))
        
        items["lowercase"] = MustacheValue(MustacheFilterWithBlock({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.lowercaseString)
        }))
        
        items["uppercase"] = MustacheValue(MustacheFilterWithBlock({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.uppercaseString)
        }))
        
        items["localize"] = MustacheValue(Localizer(bundle: nil, table: nil))
        
        items["each"] = MustacheValue(EachFilter())
        
        items["isBlank"] = MustacheValue(MustacheFilterWithBlock { (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?) in
            switch value.type {
            case .None:
                return MustacheValue(true)
            case .BoolValue(let bool):
                return MustacheValue(bool)
            case .IntValue(let int):
                return MustacheValue(false)
            case .DoubleValue(let double):
                return MustacheValue(false)
            case .StringValue(let string):
                return MustacheValue(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty)
            case .DictionaryValue(let dictionary):
                return MustacheValue(false)
            case .ArrayValue(let array):
                return MustacheValue(array.isEmpty)
            case .ObjCValue(let object):
                return MustacheValue(false)
            case .RenderableValue(let object):
                return MustacheValue(false)
            }
            })
        
        items["isEmpty"] = MustacheValue(MustacheFilterWithBlock { (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?) in
            switch value.type {
            case .None:
                return MustacheValue(true)
            case .BoolValue(let bool):
                return MustacheValue(bool)
            case .IntValue(let int):
                return MustacheValue(false)
            case .DoubleValue(let double):
                return MustacheValue(false)
            case .StringValue(let string):
                return MustacheValue(string.isEmpty)
            case .DictionaryValue(let dictionary):
                return MustacheValue(false)
            case .ArrayValue(let array):
                return MustacheValue(array.isEmpty)
            case .ObjCValue(let object):
                return MustacheValue(false)
            case .RenderableValue(let object):
                return MustacheValue(false)
            }
            })
        
        items["HTML"] = MustacheValue(["escape": MustacheValue(HTMLEscape())])
        
        items["URL"] = MustacheValue(["escape": MustacheValue(URLEscape())])
        
        items["javascript"] = MustacheValue(["escape": MustacheValue(JavascriptEscape())])
        
        self.items = items
    }
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    let mustacheTagObserver: MustacheTagObserver? = nil
    
    func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> MustacheRendering? {
        return nil
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return items[identifier]
    }
}