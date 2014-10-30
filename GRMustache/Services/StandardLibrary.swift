//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class StandardLibrary: CustomMustacheValue {
    let uppercase = MustacheValue(FilterWithBlock { (value) -> (MustacheValue) in
        switch value.type {
        case .None:
            return MustacheValue("")
        case .BoolValue(let bool):
            return MustacheValue("\(bool)")
        case .IntValue(let int):
            return MustacheValue("\(int)")
        case .DoubleValue(let double):
            return MustacheValue("\(double)")
        case .StringValue(let string):
            return MustacheValue(string.uppercaseString)
        case .DictionaryValue(let dictionary):
            return MustacheValue("\(dictionary)".uppercaseString)
        case .ArrayValue(let array):
            return MustacheValue("\(array)".uppercaseString)
        case .FilterValue(let filter):
            return MustacheValue("\(filter)".uppercaseString)
        case .ObjCValue(let object):
            return MustacheValue("\(object)".uppercaseString)
        case .CustomValue(let object):
            return MustacheValue("\(object)".uppercaseString)
        }
        })
    let capitalized = MustacheValue(FilterWithBlock { (value) -> (MustacheValue) in
        switch value.type {
        case .None:
            return MustacheValue("")
        case .BoolValue(let bool):
            return MustacheValue("\(bool)")
        case .IntValue(let int):
            return MustacheValue("\(int)")
        case .DoubleValue(let double):
            return MustacheValue("\(double)")
        case .StringValue(let string):
            return MustacheValue(string.capitalizedString)
        case .DictionaryValue(let dictionary):
            return MustacheValue("\(dictionary)".capitalizedString)
        case .ArrayValue(let array):
            return MustacheValue("\(array)".capitalizedString)
        case .FilterValue(let filter):
            return MustacheValue("\(filter)".capitalizedString)
        case .ObjCValue(let object):
            return MustacheValue("\(object)".capitalizedString)
        case .CustomValue(let object):
            return MustacheValue("\(object)".capitalizedString)
        }
        })
    
    let mustacheBoolValue = true
    
    func renderForMustacheTag(tag: Tag, options: RenderingOptions, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        return nil
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        switch (identifier) {
        case "uppercase":
            return uppercase
        case "capitalized":
            return capitalized
        default:
            return nil
        }
    }
}