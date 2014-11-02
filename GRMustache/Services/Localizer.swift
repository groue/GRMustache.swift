//
//  Localizer.swift
//  GRMustache
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class Localizer: MustacheRenderable {
    let bundle: NSBundle?
    let table: String?
    
    init(bundle: NSBundle?, table: String?) {
        self.bundle = bundle
        self.table = table
    }
    
    
    // MARK: - MustacheRenderable
    
    let mustacheBoolValue = true
    let mustacheTagObserver: MustacheTagObserver? = nil
    var mustacheFilter: MustacheFilter? {
        return MustacheFilterWithBlock({ (value: MustacheValue, error: NSErrorPointer) -> (MustacheValue) in
            return value
        })
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
        return nil
    }
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        return nil
    }
    
    
    // MARK: - Private
    
    private func localizedStringForKey(key: String) -> String? {
        return bundle?.localizedStringForKey(key, value:"", table:table)
    }
}
