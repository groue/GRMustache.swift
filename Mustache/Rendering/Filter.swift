//
//  Filter.swift
//
//  Created by Gwendal Roué on 05/01/2015.
//  Copyright (c) 2015 Gwendal Roué. All rights reserved.
//


// =============================================================================
// MARK: - Arity 0 filter factories

// MustacheBox input
public func Filter(filter: (MustacheBox, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (argument: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: cheErrorDomain, code: cheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else {
            return filter(argument, error)
        }
    }
}

// Generic input
public func Filter<T>(filter: (T?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (argument: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: cheErrorDomain, code: cheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.value as? T {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Int input (see MustacheBox#intValue)
public func Filter(filter: (Int?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (argument: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: cheErrorDomain, code: cheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.intValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Double input (see MustacheBox#doubleValue)
public func Filter(filter: (Double?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (argument: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: cheErrorDomain, code: cheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.doubleValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Single input (see MustacheBox#stringValue)
public func Filter(filter: (String?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (argument: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: cheErrorDomain, code: cheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.stringValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}


// =============================================================================
// MARK: - Arity N filter factories

public func VariadicFilter(filter: (arguments: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return _VariadicFilter([], filter)
}

private func _VariadicFilter(arguments: [MustacheBox], filter: (arguments: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (argument: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox? in
        let arguments = arguments + [argument]
        if partialApplication {
            return Box(_VariadicFilter(arguments, filter))
        } else {
            return filter(arguments: arguments, error: error)
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


