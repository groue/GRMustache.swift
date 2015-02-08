// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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
