//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public class StandardLibrary: MustacheInspectable {
    
    private let items: [String: Box]
    
    public init() {
        var items: [String: Box] = [:]
        
        items["capitalized"] = BoxedFilter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.capitalizedString)
        })
        
        items["lowercase"] = BoxedFilter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.lowercaseString)
        })
        
        items["uppercase"] = BoxedFilter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.uppercaseString)
        })
        
        // TODO: test that Box contains the correct object type
        items["localize"] = Box(Localizer(bundle: nil, table: nil))
        
        items["each"] = Box(EachFilter())
        
        items["isBlank"] = BoxedFilter({ (box: Box, error: NSErrorPointer) -> Box? in
            if let int: Int = box.value() {
                return Box(false)
            } else if let double: Double = box.value() {
                return Box(false)
            } else if let string: String = box.value() {
                return Box(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty)
            } else {
                return Box(!box.mustacheBool)
            }
        })
        
        items["isEmpty"] = BoxedFilter({ (box: Box, error: NSErrorPointer) -> Box? in
            if let int: Int = box.value() {
                return Box(false)
            } else if let double: Double = box.value() {
                return Box(false)
            } else {
                return Box(!box.mustacheBool)
            }
        })
        
        items["HTML"] = Box(["escape": Box(HTMLEscape())])
        
        items["URL"] = Box(["escape": Box(URLEscape())])
        
        items["javascript"] = Box(["escape": Box(JavascriptEscape())])
        
        self.items = items
    }
    
    public func valueForMustacheKey(key: String) -> Box? {
        return items[key]
    }
}