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


// =============================================================================
// MARK: - Arity 0 filter factories

// MustacheBox input
public func Filter(filter: (MustacheBox, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else {
            return filter(box, error)
        }
    }
}

// Generic input
public func Filter<T>(filter: (T?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.value as? T {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Int input (see MustacheBox#intValue)
public func Filter(filter: (Int?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.intValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// UInt input (see MustacheBox#intValue)
public func Filter(filter: (UInt?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.uintValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Double input (see MustacheBox#doubleValue)
public func Filter(filter: (Double?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.doubleValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Single input (see MustacheBox#stringValue)
public func Filter(filter: (String?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.stringValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}


// =============================================================================
// MARK: - Arity N filter factories

public func VariadicFilter(filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return _VariadicFilter([], filter)
}

private func _VariadicFilter(boxes: [MustacheBox], filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        let boxes = boxes + [box]
        if partialApplication {
            return Box(_VariadicFilter(boxes, filter))
        } else {
            return filter(boxes: boxes, error: error)
        }
    }
}


// =============================================================================
// MARK: - Arity 0 rendering filter factories

// MustacheBox input
public func Filter(filter: (MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (box: MustacheBox, error: NSErrorPointer) -> MustacheBox? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(box, info, error)
        })
    })
}

// Generic input
public func Filter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (t: T?, error: NSErrorPointer) -> MustacheBox? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(t, info, error)
        })
    })
}

// Int input (see MustacheBox#intValue)
public func Filter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (int: Int?, error: NSErrorPointer) -> MustacheBox? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(int, info, error)
        })
    })
}

// UInt input (see MustacheBox#intValue)
public func Filter(filter: (UInt?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (uint: UInt?, error: NSErrorPointer) -> MustacheBox? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(uint, info, error)
        })
    })
}

// Double input (see MustacheBox#doubleValue)
public func Filter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (double: Double?, error: NSErrorPointer) -> MustacheBox? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(double, info, error)
        })
    })
}

// Single input (see MustacheBox#stringValue)
public func Filter(filter: (String?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (string: String?, error: NSErrorPointer) -> MustacheBox? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(string, info, error)
        })
    })
}


