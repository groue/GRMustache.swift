//
//  StandardLibrary.swift
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public class StandardLibrary: MustacheBoxable {
    
    private let items: [String: MustacheBox]
    
    public init() {
        var items: [String: MustacheBox] = [:]
        
        items["capitalized"] = Box(Filter({ (string: String?, error: NSErrorPointer) -> MustacheBox? in
            return Box(string?.capitalizedString)
        }))
        
        items["lowercase"] = Box(Filter({ (string: String?, error: NSErrorPointer) -> MustacheBox? in
            return Box(string?.lowercaseString)
        }))
        
        items["uppercase"] = Box(Filter({ (string: String?, error: NSErrorPointer) -> MustacheBox? in
            return Box(string?.uppercaseString)
        }))
        
        items["localize"] = Box(Localizer(bundle: nil, table: nil))
        
        items["each"] = Box(Filter(EachFilter))
        
        items["isBlank"] = Box(Filter({ (box: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
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
        
        items["isEmpty"] = Box(Filter({ (box: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
            if let int = box.value as? Int {
                return Box(false)
            } else if let double = box.value as? Double {
                return Box(false)
            } else {
                return Box(!box.mustacheBool)
            }
        }))
        
        items["HTML"] = Box(["escape": HTMLEscape()])
        
        items["URL"] = Box(["escape": URLEscape()])
        
        items["javascript"] = Box(["escape": JavascriptEscape()])
        
        self.items = items
    }
    
    public var mustacheBox: MustacheBox {
        return Box(items)
    }
}
