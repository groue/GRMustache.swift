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
        case .BoolValue, .IntValue, .DoubleValue, .StringValue, .ObjCValue, .ClusterValue:
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: not iterable"])
            }
            return nil
        case .DictionaryValue(let dictionary):
            return transformedDictionary(dictionary)
        case .ArrayValue(let array):
            return transformedSequence(array)
        case .SetValue(let set):
            return transformedSet(set)
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
    
    func transformedSet(set: NSSet) -> MustacheValue {
        var mustacheValues: [MustacheValue] = []
        let count = set.count
        var index = 0
        for item in set {
            let value = MustacheValue(item)
            let last = index == count
            let replacementValue = ReplacementValue(value: value, index: index, key: nil, last: last)
            mustacheValues.append(MustacheValue(replacementValue))
            ++index
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
    
    class ReplacementValue: MustacheCluster, MustacheRenderable {
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
        
        // TODO: API inconsistency: why is mustacheBoolValue easy to extract, and not mustacheFilter?
        var mustacheBoolValue: Bool { return value.mustacheBoolValue }
        var mustacheFilter: MustacheFilter? {
            switch value.type {
            case .ClusterValue(let cluster):
                return cluster.mustacheFilter
            default:
                return nil
            }
        }
        var mustacheTagObserver: MustacheTagObserver? {
            switch value.type {
            case .ClusterValue(let cluster):
                return cluster.mustacheTagObserver
            default:
                return nil
            }
        }
        var mustacheTraversable: MustacheTraversable? {
            switch value.type {
            case .ClusterValue(let cluster):
                return cluster.mustacheTraversable
            default:
                return nil
            }
        }
        var mustacheRenderable: MustacheRenderable? {
            return self
        }
        
        func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
            var position: [String: MustacheValue] = [:]
            position["@index"] = MustacheValue(index)
            position["@indexPlusOne"] = MustacheValue(index + 1)
            position["@indexIsEven"] = MustacheValue(index % 2 == 0)
            position["@first"] = MustacheValue(index == 0)
            position["@last"] = MustacheValue(last)
            if let key = key {
                position["@key"] = MustacheValue(key)
            }
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithValue(MustacheValue(position))
            return value.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }
}
