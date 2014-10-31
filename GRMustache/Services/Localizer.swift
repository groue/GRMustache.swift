//
//  Localizer.swift
//  GRMustache
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class Localizer: CustomMustacheValue {
    let bundle: NSBundle?
    let table: String?
    
    init(bundle: NSBundle?, table: String?) {
        self.bundle = bundle
        self.table = table
    }
    
    func asFilter() -> Filter? {
        return FilterWithBlock({ (value: MustacheValue) -> (MustacheValue) in
            return value
        })
    }
    
    
    // MARK: - CustomMustacheValue
    
    let mustacheBoolValue = true
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return nil
    }
    
    func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        return nil
    }
    
    
    // MARK: - Private
    
    private func localizedStringForKey(key: String) -> String? {
        return bundle?.localizedStringForKey(key, value:"", table:table)
    }
}
