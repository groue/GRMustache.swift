//
//  MustacheFilter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol MustacheFilter {
    func filterByCurryingArgument(argument: MustacheValue) -> MustacheFilter?
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue?
}

private class BlockFilter: MustacheFilter {
    let block: (MustacheValue, error: NSErrorPointer) -> (MustacheValue?)
    
    init(_ block: (MustacheValue, error: NSErrorPointer) -> (MustacheValue?)) {
        self.block = block
    }
    
    func filterByCurryingArgument(argument: MustacheValue) -> MustacheFilter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
        return block(value, error: outError)
    }
}

func MustacheFilterWithBlock(block: (MustacheValue, error: NSErrorPointer) -> (MustacheValue?)) -> MustacheFilter {
    return BlockFilter(block)
}

func MustacheFilterWithBlock(block: (String?) -> (MustacheValue)) -> MustacheFilter {
    return BlockFilter({ (value, outError) -> (MustacheValue?) in
        switch value.type {
        case .None:
            return block(nil)
        default:
            if let string = value.asString() {
                return block(string)
            } else {
                if outError != nil {
                    outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: not a string"])
                }
                return nil
            }
        }
    })
}

