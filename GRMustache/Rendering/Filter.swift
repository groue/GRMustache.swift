//
//  Filter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public protocol Filter {
    func mustacheFilterByApplyingArgument(argument: Value) -> Filter?
    func transformedMustacheValue(value: Value, error outError: NSErrorPointer) -> Value?
}
