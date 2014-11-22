//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public class StandardLibrary: MustacheInspectable {
    
    private let items: [String: Value]
    
    public init() {
        var items: [String: Value] = [:]
        
        items["capitalized"] = Value({ (string: String?) -> (Value) in
            return Value(string?.capitalizedString)
        })
        
        items["lowercase"] = Value({ (string: String?) -> (Value) in
            return Value(string?.lowercaseString)
        })
        
        items["uppercase"] = Value({ (string: String?) -> (Value) in
            return Value(string?.uppercaseString)
        })
        
        // TODO: test that Value contains the correct object type
        items["localize"] = Value(Localizer(bundle: nil, table: nil))
        
        items["each"] = Value(EachFilter())
        
        items["isBlank"] = Value({ (value: Value, error: NSErrorPointer) -> (Value?) in
            if let int: Int = value.object() {
                return Value(false)
            } else if let double: Double = value.object() {
                return Value(false)
            } else if let string: String = value.object() {
                return Value(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty)
            } else {
                return Value(!value.mustacheBool)
            }
        })
        
        items["isEmpty"] = Value({ (value: Value, error: NSErrorPointer) -> (Value?) in
            if let int: Int = value.object() {
                return Value(false)
            } else if let double: Double = value.object() {
                return Value(false)
            } else {
                return Value(!value.mustacheBool)
            }
        })
        
        items["HTML"] = Value(["escape": Value(HTMLEscape())])
        
        items["URL"] = Value(["escape": Value(URLEscape())])
        
        items["javascript"] = Value(["escape": Value(JavascriptEscape())])
        
        self.items = items
    }
    
    public func valueForMustacheIdentifier(identifier: String) -> Value? {
        return items[identifier]
    }
}