//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public class StandardLibrary: MustacheBoxable {
    
    private let items: [String: Box]
    
    public init() {
        var items: [String: Box] = [:]
        
        items["capitalized"] = Box(MakeFilter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.capitalizedString)
        }))
        
        items["lowercase"] = Box(MakeFilter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.lowercaseString)
        }))
        
        items["uppercase"] = Box(MakeFilter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.uppercaseString)
        }))
        
        // TODO: test that Box contains the correct object type
        items["localize"] = Box(Localizer(bundle: nil, table: nil))
        
        items["each"] = Box(MakeFilter(EachFilter))
        
        items["isBlank"] = Box(MakeFilter({ (box: Box, error: NSErrorPointer) -> Box? in
            if let int = box.value as? Int {
                return Box(false)
            } else if let double = box.value as? Double {
                return Box(false)
            } else if let string = box.value as? String {
                return Box(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty)
            } else {
                return Box(!box.mustacheBool)
            }
        }))
        
        items["isEmpty"] = Box(MakeFilter({ (box: Box, error: NSErrorPointer) -> Box? in
            if let int = box.value as? Int {
                return Box(false)
            } else if let double = box.value as? Double {
                return Box(false)
            } else {
                return Box(!box.mustacheBool)
            }
        }))
        
        items["HTML"] = Box(["escape": Box(HTMLEscape())])
        
        items["URL"] = Box(["escape": Box(URLEscape())])
        
        items["javascript"] = Box(["escape": Box(JavascriptEscape())])
        
        self.items = items
    }
    
    public func mustacheBox() -> Box {
        return Box(items)
    }
}