//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class StandardLibrary: MustacheTraversable {
    let items: [String: MustacheValue]
    init() {
        var items: [String: MustacheValue] = [:]
        
        items["capitalized"] = MustacheValue({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.capitalizedString)
        })
        
        items["lowercase"] = MustacheValue({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.lowercaseString)
        })
        
        items["uppercase"] = MustacheValue({ (string: String?) -> (MustacheValue) in
            return MustacheValue(string?.uppercaseString)
        })
        
        items["localize"] = MustacheValue(Localizer(bundle: nil, table: nil))
        
        items["each"] = MustacheValue(EachFilter())
        
        items["isBlank"] = MustacheValue({ (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?) in
            if let int: Int = value.object() {
                return MustacheValue(false)
            } else if let double: Double = value.double() {
                return MustacheValue(false)
            } else if let string: String = value.object() {
                return MustacheValue(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty)
            } else {
                return MustacheValue(!value.mustacheBool)
            }
        })
        
        items["isEmpty"] = MustacheValue({ (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue?) in
            if let int: Int = value.object() {
                return MustacheValue(false)
            } else if let double: Double = value.double() {
                return MustacheValue(false)
            } else {
                return MustacheValue(!value.mustacheBool)
            }
        })
        
        items["HTML"] = MustacheValue(["escape": MustacheValue(HTMLEscape())])
        
        items["URL"] = MustacheValue(["escape": MustacheValue(URLEscape())])
        
        items["javascript"] = MustacheValue(["escape": MustacheValue(JavascriptEscape())])
        
        self.items = items
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return items[identifier]
    }
}