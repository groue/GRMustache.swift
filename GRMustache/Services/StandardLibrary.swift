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
        
        items["capitalized"] = boxValue(Filter({ (string: String?, error: NSErrorPointer) -> Box? in
            return boxValue(string?.capitalizedString)
        }))
        
        items["lowercase"] = boxValue(Filter({ (string: String?, error: NSErrorPointer) -> Box? in
            return boxValue(string?.lowercaseString)
        }))
        
        items["uppercase"] = boxValue(Filter({ (string: String?, error: NSErrorPointer) -> Box? in
            return boxValue(string?.uppercaseString)
        }))
        
        items["localize"] = boxValue(Localizer(bundle: nil, table: nil))
        
        items["each"] = boxValue(Filter(EachFilter))
        
        items["isBlank"] = boxValue(Filter({ (box: Box, error: NSErrorPointer) -> Box? in
            if let int = box.value as? Int {
                return boxValue(false)
            } else if let double = box.value as? Double {
                return boxValue(false)
            } else if let string = box.value as? String {
                return boxValue(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty)
            } else {
                return boxValue(!box.mustacheBool)
            }
        }))
        
        items["isEmpty"] = boxValue(Filter({ (box: Box, error: NSErrorPointer) -> Box? in
            if let int = box.value as? Int {
                return boxValue(false)
            } else if let double = box.value as? Double {
                return boxValue(false)
            } else {
                return boxValue(!box.mustacheBool)
            }
        }))
        
        items["HTML"] = boxValue(["escape": HTMLEscape()])
        
        items["URL"] = boxValue(["escape": URLEscape()])
        
        items["javascript"] = boxValue(["escape": JavascriptEscape()])
        
        self.items = items
    }
    
    public var mustacheBox: Box {
        return boxValue(items)
    }
}
