//
//  EachFilter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

let EachFilter = { (argument: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
    if argument.isEmpty {
        return argument
    } else if let dictionary = argument.value as? [String: MustacheBox] {
        return transformedDictionary(dictionary)
    } else if let array = argument.value as? [MustacheBox] {
        return transformedCollection(array)
    } else if let set = argument.value as? NSSet {
        return transformedSet(set)
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
        mustacheBoxes.append(itemBox.boxWithRenderFunction({ (var info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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

private func transformedSet(set: NSSet) -> MustacheBox {
    var mustacheBoxes: [MustacheBox] = []
    let count = set.count
    var index = 0
    for item in set {
        // Force ObjCMustacheBoxable cast. It's usually OK since NSObject conforms to ObjCMustacheBoxable.
        let itemBox = Box((item as ObjCMustacheBoxable))
        let last = index == count
        mustacheBoxes.append(itemBox.boxWithRenderFunction({ (var info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            var position: [String: MustacheBox] = [:]
            position["@index"] = Box(index)
            position["@indexPlusOne"] = Box(index + 1)
            position["@indexIsEven"] = Box(index % 2 == 0)
            position["@first"] = Box(index == 0)
            position["@last"] = Box(last)
            info.context = info.context.extendedContext(Box(position))
            return itemBox.render(info: info, error: error)
        }))
        ++index
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
        mustacheBoxes.append(itemBox.boxWithRenderFunction({ (var info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
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
