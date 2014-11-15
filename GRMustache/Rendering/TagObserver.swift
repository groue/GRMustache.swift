//
//  TagObserver.swift
//  GRMustache
//
//  Created by Gwendal Roué on 04/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public protocol TagObserver {
    func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value
    
    // If rendering is nil then an error has occurred.
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value)
}