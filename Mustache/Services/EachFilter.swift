//
//  EachFilter.swift
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

let EachFilter = Filter { (box: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
    if box.isEmpty {
        return box
    } else if let dictionary = box.dictionaryValue {
        return transformedDictionary(dictionary)
    } else if let array = box.arrayValue {
        return transformedCollection(array)
    } else {
        if error != nil {
            error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: not iterable"])
        }
        return nil
    }
}

private func transformedCollection<T: CollectionType where T.Generator.Element == MustacheBox, T.Index: Comparable, T.Index.Distance == Int>(collection: T) -> MustacheBox {
    var mustacheBoxes: [MustacheBox] = []
    let start = collection.startIndex
    let end = collection.endIndex
    var i = start
    while i < end {
        let itemBox = collection[i]
        let index = distance(start, i)
        let last = i.successor() == end
        mustacheBoxes.append(Box(itemBox, render: { (var info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            var position: [String: MustacheBox] = [:]
            position["@index"] = Box(index)
            position["@indexPlusOne"] = Box(index + 1)
            position["@indexIsEven"] = Box(index % 2 == 0)
            position["@first"] = Box(index == 0)
            position["@last"] = Box(last)
            info.context = info.context.extendedContext(Box(position))
            return itemBox.render(info: info, error: error)
        }))
        i = i.successor()
    }
    return Box(mustacheBoxes)
}

private func transformedDictionary(dictionary: [String: MustacheBox]) -> MustacheBox {
    var mustacheBoxes: [MustacheBox] = []
    let start = dictionary.startIndex
    let end = dictionary.endIndex
    var i = start
    while i < end {
        let (key, itemBox) = dictionary[i]
        let index = distance(start, i)
        let last = i.successor() == end
        mustacheBoxes.append(Box(itemBox, render: { (var info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            var position: [String: MustacheBox] = [:]
            position["@index"] = Box(index)
            position["@indexPlusOne"] = Box(index + 1)
            position["@indexIsEven"] = Box(index % 2 == 0)
            position["@first"] = Box(index == 0)
            position["@last"] = Box(last)
            position["@key"] = Box(key)
            info.context = info.context.extendedContext(Box(position))
            return itemBox.render(info: info, error: error)
        }))
        i = i.successor()
    }
    return Box(mustacheBoxes)
}
