//
//  Localizer.swift
//  GRMustache
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class Localizer: MustacheFilter, MustacheTagObserver {
    let bundle: NSBundle?
    let table: String?
    
    init(bundle: NSBundle?, table: String?) {
        self.bundle = bundle
        self.table = table
    }
    
    
    // MARK: - MustacheFilter
    
    func filterByCurryingArgument(argument: MustacheValue) -> MustacheFilter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
        if let string = value.stringValue() {
            if let localizedString = localizedStringForKey(string) {
                return MustacheValue(localizedString)
            } else {
                return MustacheValue()
            }
        } else {
            return MustacheValue()
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    func mustacheTag(tag: MustacheTag, willRenderValue value: MustacheValue) -> MustacheValue {
        return value
    }
    
    func mustacheTag(tag: MustacheTag, didRender rendering: String?, forValue: MustacheValue) {
    }
    
    
    // MARK: - Private
    
    private func localizedStringForKey(key: String) -> String? {
        return bundle?.localizedStringForKey(key, value:"", table:table)
    }
}
