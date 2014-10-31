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

private class BlockFilter: Filter {
    let block: (MustacheValue) -> (MustacheValue)
    
    init(_ block: (MustacheValue) -> (MustacheValue)) {
        self.block = block
    }
    
    func filterByCurryingArgument(argument: MustacheValue) -> Filter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue) -> MustacheValue {
        return block(value)
    }
}

func FilterWithBlock(block: (MustacheValue) -> (MustacheValue)) -> Filter {
    return BlockFilter(block)
}

func FilterWithBlock(block: (String?) -> (MustacheValue)) -> Filter {
    return BlockFilter({ (value) -> (MustacheValue) in
        switch value.type {
        case .None:
            return block(nil)
        case .BoolValue(let bool):
            return block("\(bool)")
        case .IntValue(let int):
            return block("\(int)")
        case .DoubleValue(let double):
            return block("\(double)")
        case .StringValue(let string):
            return block(string)
        case .DictionaryValue(let dictionary):
            return block("\(dictionary)")
        case .ArrayValue(let array):
            return block("\(array)")
        case .FilterValue(let filter):
            return block("\(filter)")
        case .ObjCValue(let object):
            return block("\(object)")
        case .CustomValue(let object):
            return block("\(object)")
        }
    })
}

