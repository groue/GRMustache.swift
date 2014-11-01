//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class StandardLibrary: MustacheRenderable {
    let items: [String: MustacheValue] = [
        "capitalized": MustacheValue(MustacheFilterWithBlock({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.capitalizedString)
        })),
        "lowercase": MustacheValue(MustacheFilterWithBlock({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.lowercaseString)
        })),
        "uppercase": MustacheValue(MustacheFilterWithBlock({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.uppercaseString)
        })),
        "localize": MustacheValue(Localizer(bundle: nil, table: nil)),
        "each": MustacheValue(EachFilter()),
        "isBlank": MustacheValue(MustacheFilterWithBlock { (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?) in
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
            case .FilterValue(let filter):
                return MustacheValue(false)
            case .ObjCValue(let object):
                return MustacheValue(false)
            case .RenderableValue(let object):
                return MustacheValue(false)
            }
            }),
        "isEmpty": MustacheValue(MustacheFilterWithBlock { (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?) in
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
            case .FilterValue(let filter):
                return MustacheValue(false)
            case .ObjCValue(let object):
                return MustacheValue(false)
            case .RenderableValue(let object):
                return MustacheValue(false)
            }
            }),
        "HTML": MustacheValue([
            // TODO: make this cast avoidable (Swift does not know if it should use the filter or renderable-based MustacheValue initializer)
            "escape": MustacheValue(HTMLEscapeRenderable() as MustacheRenderable)
            ]),
    ]
    
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