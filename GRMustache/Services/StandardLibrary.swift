//
//  StandardLibrary.swift
//  GRMustache
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public class StandardLibrary {
    
    private let items: [String: Box]
    
    public init() {
        var items: [String: Box] = [:]
        
        items["capitalized"] = Box(filter: Filter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.capitalizedString)
        }))
        
        items["lowercase"] = Box(filter: Filter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.lowercaseString)
        }))
        
        items["uppercase"] = Box(filter: Filter({ (string: String?, error: NSErrorPointer) -> Box? in
            return Box(string?.uppercaseString)
        }))
        
        items["localize"] = Box(Localizer(bundle: nil, table: nil))
        
        items["each"] = Box(filter: Filter(EachFilter))
        
        items["isBlank"] = Box(filter: Filter({ (box: Box, error: NSErrorPointer) -> Box? in
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
        
        items["isEmpty"] = Box(filter: Filter({ (box: Box, error: NSErrorPointer) -> Box? in
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
}

extension Box {
    public init(_ standardLibrary: StandardLibrary) {
        self.init(standardLibrary.items)
    }
}
