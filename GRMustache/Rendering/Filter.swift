//
//  Filter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 05/01/2015.
//  Copyright (c) 2015 Gwendal Roué. All rights reserved.
//


// =============================================================================
// MARK: - Arity 0 filter factories

// Box input
public func Filter(filter: (Box, NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else {
            return filter(argument, error)
        }
    }
}

// Generic input
public func Filter<T>(filter: (T?, NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.value as? T {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Int input (see Box#intValue)
public func Filter(filter: (Int?, NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.intValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Double input (see Box#doubleValue)
public func Filter(filter: (Double?, NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = argument.doubleValue {
            return filter(t, error)
        } else {
            return filter(nil, error)
        }
    }
}

// Single input (see Box#stringValue)
public func Filter(filter: (String?, NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
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

public func VariadicFilter(filter: (arguments: [Box], error: NSErrorPointer) -> Box?) -> FilterFunction {
    return _VariadicFilter([], filter)
}

private func _VariadicFilter(arguments: [Box], filter: (arguments: [Box], error: NSErrorPointer) -> Box?) -> FilterFunction {
    return { (argument: Box, partialApplication: Bool, error: NSErrorPointer) -> Box? in
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

// Box input
public func Filter(filter: (Box, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (box: Box, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(box, info, error)
        })
    })
}

// Generic input
public func Filter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (t: T?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(t, info, error)
        })
    })
}

// Int input (see Box#intValue)
public func Filter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (int: Int?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(int, info, error)
        })
    })
}

// Double input (see Box#doubleValue)
public func Filter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (double: Double?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(double, info, error)
        })
    })
}

// Single input (see Box#stringValue)
public func Filter(filter: (String?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter({ (string: String?, error: NSErrorPointer) -> Box? in
        return Box({ (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
            return filter(string, info, error)
        })
    })
}


