//
//  EachFilter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class EachFilter: MustacheFilter {
    
    func filterByCurryingArgument(argument: MustacheValue) -> MustacheFilter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
        switch(value.type) {
        case .None:
            return value
        case .BoolValue, .IntValue, .DoubleValue, .StringValue, .FilterValue, .ObjCValue, .RenderableValue:
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: not iterable"])
            }
            return nil
        case .DictionaryValue(let dictionary):
            return transformedDictionary(dictionary)
        case .ArrayValue(let array):
            return transformedSequence(array)
        }
    }
    
    func transformedSequence<T: CollectionType where T.Generator.Element == MustacheValue, T.Index: Comparable, T.Index.Distance == Int>(collection: T) -> MustacheValue {
        var mustacheValues: [MustacheValue] = []
        let start = collection.startIndex
        let end = collection.endIndex
        var i = start
        while i < end {
            let value = collection[i]
            let index = distance(start, i)
            let last = i.successor() == end
            let replacementValue = ReplacementValue(value: value, index: index, key: nil, last: last)
            mustacheValues.append(MustacheValue(replacementValue))
            i = i.successor()
        }
        return MustacheValue(mustacheValues)
    }
    
    func transformedDictionary(dictionary: [String: MustacheValue]) -> MustacheValue {
        var mustacheValues: [MustacheValue] = []
        let start = dictionary.startIndex
        let end = dictionary.endIndex
        var i = start
        while i < end {
            let (key, value) = dictionary[i]
            let index = distance(start, i)
            let last = i.successor() == end
            let replacementValue = ReplacementValue(value: value, index: index, key: key, last: last)
            mustacheValues.append(MustacheValue(replacementValue))
            i = i.successor()
        }
        return MustacheValue(mustacheValues)
    }
    
    class ReplacementValue: MustacheRenderable {
        let value: MustacheValue
        let index: Int
        let last: Bool
        let key: String?
        
        init(value: MustacheValue, index: Int, key: String?, last: Bool) {
            self.value = value
            self.index = index
            self.key = key
            self.last = last
        }
        
        let mustacheFilter: MustacheFilter? = nil
        let mustacheTagObserver: MustacheTagObserver? = nil
        var mustacheBoolValue: Bool { return value.mustacheBoolValue }
        
        func renderForMustacheTag(tag: Tag, context: Context, options: RenderingOptions, error outError: NSErrorPointer) -> MustacheRendering? {
            var position: [String: MustacheValue] = [:]
            position["@index"] = MustacheValue(index)
            position["@indexPlusOne"] = MustacheValue(index + 1)
            position["@indexIsEven"] = MustacheValue(index % 2 == 0)
            position["@first"] = MustacheValue(index == 0)
            position["@last"] = MustacheValue(last)
            if let key = key {
                position["@key"] = MustacheValue(key)
            }
            let context = context.contextByAddingValue(MustacheValue(position))
            return value.renderForMustacheTag(tag, context: context, options: options, error: outError)
        }
        
        func valueForMustacheIdentifier(identifier: String) -> MustacheValue? {
            return value.valueForMustacheIdentifier(identifier)
        }
    }
}
