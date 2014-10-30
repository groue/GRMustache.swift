//
//  MustacheFilter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol Filter {
    func filterByCurryingArgument(argument: MustacheValue) -> Filter?
    func transformedValue(value: MustacheValue) -> MustacheValue
}

typealias FilterClosure = (MustacheValue) -> (MustacheValue)

private class BlockFilter: Filter {
    let block: FilterClosure
    
    init(block: FilterClosure) {
        self.block = block
    }
    
    func filterByCurryingArgument(argument: MustacheValue) -> Filter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue) -> MustacheValue {
        return block(value)
    }
}

func FilterWithBlock(block: FilterClosure) -> Filter {
    return BlockFilter(block: block)
}
