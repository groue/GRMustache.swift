//
//  Localizer.swift
//  GRMustache
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public class Localizer: Filter, TagObserver {
    public let bundle: NSBundle?
    public let table: String?
    
    public init(bundle: NSBundle?, table: String?) {
        self.bundle = bundle ?? NSBundle.mainBundle()
        self.table = table
    }
    
    
    // MARK: - Filter
    
    public func mustacheFilterByApplyingArgument(argument: Value) -> Filter? {
        return nil
    }
    
    public func transformedMustacheValue(value: Value, error: NSErrorPointer) -> Value? {
        if let localizedString = localizedStringForKey(value.toString()) {
            return Value(localizedString)
        } else {
            return Value()
        }
    }
    
    
    // MARK: - TagObserver
    
    public func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
        return value
    }
    
    public func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
    }
    
    
    // MARK: - Private
    
    private func localizedStringForKey(key: String?) -> String? {
        if let key = key {
            return bundle?.localizedStringForKey(key, value:"", table:table)
        } else {
            return nil
        }
    }
}
