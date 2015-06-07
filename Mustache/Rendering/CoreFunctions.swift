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


import Foundation


// =============================================================================
// MARK: - KeyedSubscriptFunction

/**
`KeyedSubscriptFunction` is used by the Mustache rendering engine whenever it
has to resolve identifiers in expressions such as `{{ name }}` or
`{{ user.name }}`. Subscript functions turn those identifiers into
`MustacheBox`, the type that wraps rendered values.

All types that expose keys to Mustache templates provide such a subscript
function by conforming to the `MustacheBoxable` protocol. This is the case of
built-in types such as NSObject, that uses `valueForKey:` in order to expose
its properties; String, which exposes its "length"; collections, which expose
keys like "count", "first", etc. etc.
    
    var box = Box("string")
    box = box["length"] // Evaluates the KeyedSubscriptFunction
    box.value           // 6
    
    box = Box(["a", "b", "c"])
    box = box["first"]  // Evaluates the KeyedSubscriptFunction
    box.value           // "a"

Your can build boxes that hold a custom subscript function. This is a rather
advanced usage, only supported with the low-level function
`func Box(boolValue:value:keyedSubscript:filter:render:willRender:didRender:) -> MustacheBox`.
    
    // A KeyedSubscriptFunction that turns "key" into "KEY":
    let keyedSubscript: KeyedSubscriptFunction = { (key: String) -> MustacheBox in
        return Box(key.uppercaseString)
    }

    // Render "FOO & BAR"
    let template = Template(string: "{{foo}} & {{bar}}")!
    let box = Box(keyedSubscript: keyedSubscript)
    template.render(box)!


### Missing keys vs. missing values.

`KeyedSubscriptFunction` returns a non-optional `MustacheBox`.

In order to express "missing key", and have Mustache rendering engine dig deeper
in the context stack in order to resolve a key, return the empty box `Box()`.

In order to express "missing value", and prevent the rendering engine from
digging deeper, return `Box(NSNull())`.
*/
public typealias KeyedSubscriptFunction = (key: String) -> MustacheBox


// =============================================================================
// MARK: - FilterFunction

/**
`FilterFunction` is the core type that lets GRMustache evaluate filtered
expressions such as `{{ uppercase(string) }}`.

To build a filter, you use the `Filter()` function. It takes a function as an
argument. For example:
    
    let increment = Filter { (x: Int, _) in
        return Box(x + 1)
    }

To let a template use a filter, register it:

    let template = Template(string: "{{increment(x)}}")!
    template.registerInBaseContext("increment", Box(increment))
    
    // "2"
    template.render(Box(["x": 1]))!

`Filter()` can take several types of functions, depending on the type of filter
you want to build. The example above processes `Int`. Other filters are:

- Filters that process values:

    - `(MustacheBox, NSErrorPointer) -> MustacheBox?`
    - `(T?, NSErrorPointer) -> MustacheBox?` (Generic)
    - `(T, NSErrorPointer) -> MustacheBox?` (Generic)
    - `(Int?, NSErrorPointer) -> MustacheBox?`
    - `(Int, NSErrorPointer) -> MustacheBox?`
    - `(UInt?, NSErrorPointer) -> MustacheBox?`
    - `(UInt, NSErrorPointer) -> MustacheBox?`
    - `(Double?, NSErrorPointer) -> MustacheBox?`
    - `(Double, NSErrorPointer) -> MustacheBox?`

- Filter that perform post-rendering:

    - `(Rendering, NSErrorPointer) -> Rendering?`

- Filters that perform custom rendering:

    - `(MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?`
    - `(T?, RenderingInfo, NSErrorPointer) -> Rendering?` (Generic)
    - `(T, RenderingInfo, NSErrorPointer) -> Rendering?` (Generic)
    - `(Int?, RenderingInfo, NSErrorPointer) -> Rendering?`
    - `(Int, RenderingInfo, NSErrorPointer) -> Rendering?`
    - `(UInt?, RenderingInfo, NSErrorPointer) -> Rendering?`
    - `(UInt, RenderingInfo, NSErrorPointer) -> Rendering?`
    - `(Double?, RenderingInfo, NSErrorPointer) -> Rendering?`
    - `(Double, RenderingInfo, NSErrorPointer) -> Rendering?`

- Filters that accept several arguments, built with `VariadicFilter()`:

    - `(boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?`
*/
public typealias FilterFunction = (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox?


/**
Builds a filter that takes a single argument.

For example, here is the trivial `identity` filter:

    let identity = Filter { (box: MustacheBox, _) in
        return box
    }

    let template = Template(string: "{{identity(a)}}, {{identity(b)}}")!
    template.registerInBaseContext("identity", Box(identity))

    // "foo, 1"
    template.render(Box(["a": "foo", "b": 1]))!

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(MustacheBox, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter(filter: (MustacheBox, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else {
            return filter(box, error)
        }
    }
}

/**
Builds a filter that takes a single argument of type `T?`.

For example:

    let uppercase = Filter { (string: String?, _) in
        if let string = string {
            return Box(string.uppercaseString)
        } else {
            return Box()
        }
    }

    let template = Template(string: "{{uppercase(string)}}")!
    template.registerInBaseContext("uppercase", Box(uppercase))

    // "HELLO"
    template.render(Box(["string": "Hello"]))!

If the template argument evaluates to a missing value, or a value which is not
of type T, the filter is given nil:

    // Both render the empty string
    template.render(Box())!
    template.render(Box(["string": 1]))!

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(T?, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter<T>(filter: (T?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
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

/**
Builds a filter that takes a single argument of type `T`.

For example:

    let uppercase = Filter { (string: String, _) in
        return Box(string.uppercaseString)
    }

    let template = Template(string: "{{uppercase(string)}}")!
    template.registerInBaseContext("uppercase", Box(uppercase))

    // "HELLO"
    template.render(Box(["string": "Hello"]))!

If the template argument evaluates to a missing value, or a value which is not
of type T, the filter returns an error of domain `GRMustacheErrorDomain` and
code `GRMustacheErrorCodeRenderingError`:

    // Error evaluating {{uppercase(a)}} at line 1: Unexpected argument
    var error: NSError?
    template.render(Box(), error: &error)
    template.render(Box(["string": 1]), error: &error)

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(T, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter<T>(filter: (T, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.value as? T {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument"])
            }
            return nil
        }
    }
}

/**
Builds a filter that takes a single `Int?` argument.

For example:

    let increment = Filter { (x: Int?, _) in
        if let x = x {
            return Box(x + 1)
        } else {
            return Box()
        }
    }

    let template = Template(string: "{{increment(x)}}")!
    template.registerInBaseContext("increment", Box(increment))

    // "2"
    template.render(Box(["x": 1]))!

If the template argument evaluates to a missing value, or a value which is not
convertible to Int (see `MustacheBox.intValue`), the filter is given nil:

    // Both render the empty string
    template.render(Box())!
    template.render(Box(["x": "foo"]))!

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(Int?, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter(filter: (Int?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
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

/**
Builds a filter that takes a single `Int` argument.

For example:

    let increment = Filter { (x: Int, _) in
        return Box(x + 1)
    }

    let template = Template(string: "{{increment(x)}}")!
    template.registerInBaseContext("increment", Box(increment))

    // "2"
    template.render(Box(["x": 1]))!

If the template argument evaluates to a missing value, or a value which is not
convertible to Int (see `MustacheBox.intValue`), the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`:

    // Error evaluating {{increment(x)}} at line 1: Unexpected argument
    var error: NSError?
    template.render(Box(), error: &error)
    template.render(Box(["x": "foo"]), error: &error)

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(Int, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter(filter: (Int, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.intValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument"])
            }
            return nil
        }
    }
}

/**
Builds a filter that takes a single `UInt?` argument.

For example:

    let increment = Filter { (x: UInt?, _) in
        if let x = x {
            return Box(x + 1)
        } else {
            return Box()
        }
    }

    let template = Template(string: "{{increment(x)}}")!
    template.registerInBaseContext("increment", Box(increment))

    // "2"
    template.render(Box(["x": 1]))!

If the template argument evaluates to a missing value, or a value which is not
convertible to UInt (see `MustacheBox.uintValue`), the filter is given nil:

    // Both render the empty string
    template.render(Box())!
    template.render(Box(["x": "foo"]))!

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(UInt?, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter(filter: (UInt?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
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

/**
Builds a filter that takes a single `UInt` argument.

For example:

    let increment = Filter { (x: UInt, _) in
        return Box(x + 1)
    }

    let template = Template(string: "{{increment(x)}}")!
    template.registerInBaseContext("increment", Box(increment))

    // "2"
    template.render(Box(["x": 1]))!

If the template argument evaluates to a missing value, or a value which is not
convertible to UInt (see `MustacheBox.uintValue`), the filter returns an error
of domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`:

    // Error evaluating {{increment(x)}} at line 1: Unexpected argument
    var error: NSError?
    template.render(Box(), error: &error)
    template.render(Box(["x": "foo"]), error: &error)

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(UInt, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter(filter: (UInt, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.uintValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument"])
            }
            return nil
        }
    }
}

/**
Builds a filter that takes a single `Double?` argument.

For example:

    let square = Filter { (x: Double?, _) in
        if let x = x {
            return Box(x * x)
        } else {
            return Box()
        }
    }

    let template = Template(string: "{{square(x)}}")!
    template.registerInBaseContext("square", Box(square))

    // "100"
    template.render(Box(["x": 10.0]))!

If the template argument evaluates to a missing value, or a value which is not
convertible to Double (see `MustacheBox.doubleValue`), the filter is given nil:

    // Both render the empty string
    template.render(Box())!
    template.render(Box(["x": "foo"]))!

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(Double?, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter(filter: (Double?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
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

/**
Builds a filter that takes a single `Double` argument.

For example:

    let square = Filter { (x: Double, _) in
        return Box(x * x)
    }

    let template = Template(string: "{{square(x)}}")!
    template.registerInBaseContext("square", Box(square))

    // "100"
    template.render(Box(["x": 10.0]))!

If the template argument evaluates to a missing value, or a value which is not
convertible to Double (see `MustacheBox.doubleValue`), the filter returns an
error of domain `GRMustacheErrorDomain` and code
`GRMustacheErrorCodeRenderingError`:

    // Error evaluating {{increment(x)}} at line 1: Unexpected argument
    var error: NSError?
    template.render(Box(), error: &error)
    template.render(Box(["x": "foo"]), error: &error)

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

:param: filter a function `(Double, NSErrorPointer) -> MustacheBox?`
:returns: a FilterFunction
*/
public func Filter(filter: (Double, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.doubleValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument"])
            }
            return nil
        }
    }
}

/**
Builds a filter that performs post rendering.

`Rendering` is a type that wraps a rendered String, and its content type (HTML
or Text). This filter turns a rendering in another one:

    // twice filter renders its argument twice:
    let twice = Filter { (rendering: Rendering, _) in
        return Rendering(rendering.string + rendering.string, rendering.contentType)
    }

    let template = Template(string: "{{ twice(x) }}")!
    template.registerInBaseContext("twice", Box(twice))

    // Renders "foofoo", "123123"
    template.render(Box(["x": "foo"]))!
    template.render(Box(["x": 123]))!

Beware that when this filter is executed, eventual HTML-escaping has not
happened yet: the rendering argument may contain raw text.
*/
public func Filter(filter: (Rendering, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            // This is a single-argument filter: we do not wait for another one.
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else {
            return Box { (info: RenderingInfo, error: NSErrorPointer) in
                if let rendering = box.render(info: info, error: error) {
                    return filter(rendering, error)
                } else {
                    return nil
                }
            }
        }
    }
}

/**
Builds a filter that takes a single argument and performs custom rendering.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `MustacheBox`, but the idea is the same.

:param: filter a function `(MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter(filter: (MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (box: MustacheBox, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(box, info, error)
        }
    }
}

/**
Builds a filter that takes a single argument of type `T?` and performs custom
rendering.

If the template argument evaluates to a missing value, or a value which is not
of type T, the filter is given nil.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `T`, but the idea is the same.

:param: filter a function `(T?, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (t: T?, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(t, info, error)
        }
    }
}

/**
Builds a filter that takes a single argument of type `T` and performs custom
rendering.

If the template argument evaluates to a missing value, or a value which is not
of type T, the filter returns an error of domain `GRMustacheErrorDomain` and
code `GRMustacheErrorCodeRenderingError`.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `T`, but the idea is the same.

:param: filter a function `(T, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter<T>(filter: (T, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (t: T, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(t, info, error)
        }
    }
}

/**
Builds a filter that takes a single `Int?` argument and performs custom
rendering.

If the template argument evaluates to a missing value, or a value which is not
convertible to Int (see `MustacheBox.intValue`), the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `Int?`, but the idea is the same.

:param: filter a function `(Int?, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (int: Int?, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(int, info, error)
        }
    }
}

/**
Builds a filter that takes a single `Int` argument and performs custom
rendering.

For example:

    // {{# pluralize(count) }}...{{/ }} renders the plural form of the section
    // content if the `count` argument is greater than 1.
    let pluralize = Filter { (count: Int, info: RenderingInfo, _) in

        // Pluralize the inner content of the section tag:
        var string = info.tag.innerTemplateString
        if count > 1 {
            string += "s"  // naive pluralization
        }

        return Rendering(string)
    }

    let template = Template(string: "I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.")!
    template.registerInBaseContext("pluralize", Box(pluralize))

    // Renders "I have 3 cats."
    let data = ["cats": ["Kitty", "Pussy", "Melba"]]
    template.render(Box(data))!

If the template argument evaluates to a missing value, or a value which is not
convertible to Int (see `MustacheBox.intValue`), the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `T`, but the idea is the same.

:param: filter a function `(Int, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (int: Int, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(int, info, error)
        }
    }
}

/**
Builds a filter that takes a single `UInt?` argument and performs custom
rendering.

If the template argument evaluates to a missing value, or a value which is not
convertible to UInt (see `MustacheBox.uintValue`), the filter is given nil.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `UInt?`, but the idea is the same.

:param: filter a function `(UInt?, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter(filter: (UInt?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (uint: UInt?, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(uint, info, error)
        }
    }
}

/**
Builds a filter that takes a single `UInt` argument and performs custom
rendering.

If the template argument evaluates to a missing value, or a value which is not
convertible to UInt (see `MustacheBox.uintValue`), the filter returns an error
of domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `UInt`, but the idea is the same.

:param: filter a function `(UInt, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter(filter: (UInt, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (uint: UInt, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(uint, info, error)
        }
    }
}

/**
Builds a filter that takes a single `Double?` argument and performs custom
rendering.

If the template argument evaluates to a missing value, or a value which is not
convertible to Double (see `MustacheBox.doubleValue`), the filter is given nil.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `Double?`, but the idea is the same.

:param: filter a function `(Double?, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (double: Double?, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(double, info, error)
        }
    }
}

/**
Builds a filter that takes a single `Double` argument and performs custom
rendering.

If the template argument evaluates to a missing value, or a value which is not
convertible to Double (see `MustacheBox.doubleValue`), the filter returns an
error of domain `GRMustacheErrorDomain` and code
`GRMustacheErrorCodeRenderingError`.

If the template provides more than one argument, the filter returns an error of
domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction`.
This example processes `Int` instead of `Double`, but the idea is the same.

:param: filter a function `(Double, RenderingInfo, NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func Filter(filter: (Double, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (double: Double, error: NSErrorPointer) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(double, info, error)
        }
    }
}

/**
Returns a filter than accepts any number of arguments.

For example:

    // `sum(x, ...)` evaluates to the sum of provided integers
    let sum = VariadicFilter { (boxes: [MustacheBox], _) in
        // Extract integers out of input boxes, assuming zero for non numeric values
        let integers = map(boxes) { (box) in box.intValue ?? 0 }
        let sum = reduce(integers, 0, +)
        return Box(sum)
    }

    let template = Template(string: "{{ sum(a,b,c) }}")!
    template.registerInBaseContext("sum", Box(sum))

    // Renders "6"
    template.render(Box(["a": 1, "b": 2, "c": 3]))!

If your filter is given too many or too few arguments, you should return nil and
set error to an NSError of domain `GRMustacheErrorDomain` and code
`GRMustacheErrorCodeRenderingError`.

:param: filter a function `(boxes: [MustacheBox], error: NSErrorPointer) -> Rendering?`
:returns: a FilterFunction
*/
public func VariadicFilter(filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return _VariadicFilter([], filter)
}

private func _VariadicFilter(boxes: [MustacheBox], filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        let boxes = boxes + [box]
        if partialApplication {
            // Wait for another argument
            return Box(_VariadicFilter(boxes, filter))
        } else {
            // No more argument: compute final value
            return filter(boxes: boxes, error: error)
        }
    }
}


// =============================================================================
// MARK: - RenderFunction

/**
`RenderFunction` is used by the Mustache rendering engine when it renders a
variable tag (`{{name}}` or `{{{body}}}`) or a section tag
(`{{#name}}...{{/name}}`).


### Output: `Rendering`

The return type of `RenderFunction` is `Rendering`, a type that wraps a rendered
String, and its ContentType (HTML or Text).

Text renderings are HTML-escaped, except for `{{{triple}}}` mustache tags, and
Text templates (see `Configuration.contentType` for a full discussion of the
content type of templates).

For example:

    let HTML: RenderFunction = { (_, _) in
        return Rendering("<HTML>", .HTML)
    }
    let text: RenderFunction = { (_, _) in
        return Rendering("<text>")   // default content type is text
    }

    // Renders "<HTML>, &lt;text&gt;"
    let template = Template(string: "{{HTML}}, {{text}}")!
    let data = ["HTML": Box(HTML), "text": Box(text)]
    let rendering = template.render(Box(data))!


### Input: `RenderingInfo`

The `info` argument contains a `RenderingInfo` which provides information
about the requested rendering:

- `info.context: Context` is the context stack which contains the rendered data.

- `info.tag: Tag` is the tag to render.

- `info.tag.type: TagType` is the type of the tag (variable or section). You can
  use this type to have a different rendering for variable and section tags.

- `info.tag.innerTemplateString: String` is the inner content of the tag,
  unrendered. For the section tag `{{# person }}Hello {{ name }}!{{/ person }}`,
  it is `Hello {{ name }}!`.

- `info.tag.render: (Context, NSErrorPointer) -> Rendering?` is a
  function that renders the inner content of the tag, given a context stack.
  For example, the section tag `{{# person }}Hello {{ name }}!{{/ person }}`
  would render `Hello Arthur!`, assuming the provided context stack provides
  "Arthur" for the key "name".


### Example

As an example, let's write a `RenderFunction` which performs the default
rendering of a value:

- `{{ value }}` and `{{{ value }}}` renders the built-in Swift String
  Interpolation of the value: our render function will return a `Rendering` with
  content type Text when the rendered tag is a variable tag. The Text content
  type makes sure that the returned string will be HTML-escaped if needed.

- `{{# value }}...{{/ value }}` pushes the value on the top of the context
  stack, and renders the inner content of section tags.

The default rendering thus reads:

    let value = ... // Some value
    let renderValue: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) in
        
        // Rendering depends on the tag type:
        switch info.tag.type {

        case .Variable:
            // {{ value }} and {{{ value }}}

            // Return the built-in Swift String Interpolation of the value:
            return Rendering("\(value)", .Text)

        case .Section:
            // {{# value }}...{{/ value }}

            // Push the value on the top of the context stack:
            let context = info.context.extendedContext(Box(value))

            // Renders the inner content of the section tag:
            return info.tag.render(context, error: error)
        }
    }

    let template = Template(string: "{{value}}")!
    let rendering = template.render(Box(["value": Box(renderValue)]))!

:param: info   A RenderingInfo
:param: error  If there is a problem in the rendering, upon return contains an
               NSError object that describes the problem.

:returns: a Rendering, or nil in case of error.
*/
public typealias RenderFunction = (info: RenderingInfo, error: NSErrorPointer) -> Rendering?


/**
Builds a `RenderFunction` which conforms to the "lambda" defined by the
Mustache specification (see https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml).

The `lambda` parameter is a function which takes the unrendered context of a
section, and returns a String. The returned `RenderFunction` renders this string
against the current delimiters.

For example:

    let template = Template(string: "{{#bold}}{{name}} has a Mustache!{{/bold}}")!

    let bold = Lambda { (string) in "<b>\(string)</b>" }
    let data = [
        "name": Box("Clark Gable"),
        "bold": Box(bold)]

    // Renders "<b>Lionel Richie has a Mustache.</b>"
    let rendering = template.render(Box(data))!

Warning: the returned String is *parsed* each time the lambda is executed. In
the example above, this is inefficient because the inner content of the bolded
section has already been parsed with its template. You may prefer the raw
`RenderFunction` type, capable of an equivalent and faster implementation:

    let bold: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) in
        if let rendering = info.tag.render(info.context, error: error) {
            return Rendering("<b>\(rendering.string)</b>", rendering.contentType)
        } else {
            return nil
        }
    }
    let data = [
        "name": Box("Clark Gable"),
        "bold": Box(bold)]

    // Renders "<b>Lionel Richie has a Mustache.</b>"
    let rendering = template.render(Box(data))!

:param: lambda  A `String -> String` function
:returns: A RenderFunction
*/
public func Lambda(lambda: String -> String) -> RenderFunction {
    return { (info: RenderingInfo, error: NSErrorPointer) in
        switch info.tag.type {
        case .Variable:
            // {{ lambda }}
            return Rendering("(Lambda)")
        case .Section:
            // {{# lambda }}...{{/ lambda }}
            //
            // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L117
            // > Lambdas used for sections should parse with the current delimiters
            
            var templateRepository = TemplateRepository()
            templateRepository.configuration.tagDelimiterPair = info.tag.tagDelimiterPair
            
            let templateString = lambda(info.tag.innerTemplateString)
            let template = templateRepository.template(string: templateString)
            return template?.render(info.context, error: error)
        }
    }
}


/**
Builds a `RenderFunction` which conforms to the "lambda" defined by the
Mustache specification (see https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml).

The `lambda` parameter is a function without any argument that returns a String.
The returned `RenderFunction` renders this string against the default `{{` and
`}}` delimiters.

For example:

    let template = Template(string: "{{fullName}} has a Mustache.")!
    
    let fullName = Lambda { "{{firstName}} {{lastName}}" }
    let data = [
        "firstName": Box("Lionel"),
        "lastName": Box("Richie"),
        "fullName": Box(fullName)]

    // Renders "Lionel Richie has a Mustache."
    let rendering = template.render(Box(data))!

Warning: the returned String is *parsed* each time the lambda is executed. In
the example above, this is inefficient because the same
`"{{firstName}} {{lastName}}"` would be parsed several times. You may prefer
using a Template instead of a lambda (see the documentation of
`Template.mustacheBox` for more information):

    let fullName = Template(string:"{{firstName}} {{lastName}}")!
    let data = [
        "firstName": Box("Lionel"),
        "lastName": Box("Richie"),
        "fullName": Box(fullName)]

    // Renders "Lionel Richie has a Mustache."
    let rendering = template.render(Box(data))!

:param: lambda  A `() -> String` function
:returns: A RenderFunction
*/
public func Lambda(lambda: () -> String) -> RenderFunction {
    return { (info: RenderingInfo, error: NSErrorPointer) in
        switch info.tag.type {
        case .Variable:
            // {{ lambda }}
            //
            // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L73
            // > Lambda results should be appropriately escaped
            //
            // Let's render a text template:
            
            var templateRepository = TemplateRepository()
            templateRepository.configuration.contentType = .Text
            
            let templateString = lambda()
            let template = templateRepository.template(string: templateString)
            return template?.render(info.context, error: error)
        case .Section:
            // {{# lambda }}...{{/ lambda }}
            //
            // Behave as a true object, and render the section.
            let context = info.context.extendedContext(Box(Lambda(lambda)))
            return info.tag.render(context, error: error)
        }
    }
}


/**
`Rendering` is a type that wraps a rendered String, and its content type (HTML
or Text).

See `RenderFunction` and `FilterFunction` for more information.
*/
public struct Rendering {
    
    /// The rendered string
    public let string: String
    
    /// The content type of the rendering
    public let contentType: ContentType
    
    /**
    Builds a Rendering with a String and a ContentType.
    
        Rendering("foo")        // Defaults to Text
        Rendering("foo", .Text)
        Rendering("foo", .HTML)
    
    :param: string       A string
    :param: contentType  A content type
    */
    public init(_ string: String, _ contentType: ContentType = .Text) {
        self.string = string
        self.contentType = contentType
    }
}

/**
`RenderingInfo` provides information about a rendering.

See `RenderFunction` for more information.
*/
public struct RenderingInfo {
    
    /// The currently rendered tag.
    public let tag: Tag
    
    /// The current context stack.
    public var context: Context
    
    // If true, the rendering is part of an enumeration. Some values don't
    // render the same whenever they render as an enumeration item, or alone:
    // {{# values }}...{{/ values }} vs. {{# value }}...{{/ value }}.
    //
    // This is the case of Int, UInt, Double, Bool: they enter the context
    // stack when used in an iteration, and do not enter the context stack when
    // used as a boolean (see https://github.com/groue/GRMustache/issues/83).
    //
    // This is also the case of collections: they enter the context stack when
    // used as an item of a collection, and enumerate their items when used as
    // a collection.
    var enumerationItem: Bool
}


// =============================================================================
// MARK: - WillRenderFunction

/**
Once a `WillRenderFunction` has entered the context stack, it is called just
before tags are about to render, and has the opportunity to replace the value
they are about to render.

    let logTags: WillRenderFunction = { (tag: Tag, box: MustacheBox) in
        println("\(tag) will render \(box.value!)")
        return box
    }

    // By entering the base context of the template, the logTags function
    // will be notified of all tags.
    let template = Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")!
    template.extendBaseContext(Box(willRender))

    // Prints:
    // {{# user }} at line 1 will render { firstName = Errol; lastName = Flynn; }
    // {{ firstName }} at line 1 will render Errol
    // {{ lastName }} at line 1 will render Flynn
    let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
    template.render(Box(data))!

`WillRenderFunction` don't have to enter the base context of a template to
perform: they can enter the context stack just like any other value, by being
attached to a section. In this case, they are only notified of tags inside that
section.

    let template = Template(string: "{{# user }}{{ firstName }} {{# spy }}{{ lastName }}{{/ spy }}{{/ user }}")!

    // Prints:
    // {{ lastName }} at line 1 will render Flynn
    let data = [
        "user": Box(["firstName": "Errol", "lastName": "Flynn"]),
        "spy": Box(willRender)
    ]
    template.render(Box(data))!
*/
public typealias WillRenderFunction = (tag: Tag, box: MustacheBox) -> MustacheBox


// =============================================================================
// MARK: - DidRenderFunction

/**
Once a DidRenderFunction has entered the context stack, it is called just
after tags have been rendered.

    let logRenderings: DidRenderFunction = { (tag: Tag, box: MustacheBox, string: String?) in
        println("\(tag) did render \(box.value!) as `\(string!)`")
    }

    // By entering the base context of the template, the logRenderings function
    // will be notified of all tags.
    let template = Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")!
    template.extendBaseContext(Box(logRenderings))

    // Renders "Errol Flynn"
    //
    // Prints:
    // {{ firstName }} at line 1 did render Errol as `Errol`
    // {{ lastName }} at line 1 did render Flynn as `Flynn`
    // {{# user }} at line 1 did render { firstName = Errol; lastName = Flynn; } as `Errol Flynn`
    let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
    template.render(Box(data))!

DidRender functions don't have to enter the base context of a template to
perform: they can enter the context stack just like any other value, by being
attached to a section. In this case, they are only notified of tags inside that
section.

    let template = Template(string: "{{# user }}{{ firstName }} {{# spy }}{{ lastName }}{{/ spy }}{{/ user }}")!

    // Renders "Errol Flynn"
    //
    // Prints:
    // {{ lastName }} at line 1 did render Flynn as `Flynn`
    let data = [
        "user": Box(["firstName": "Errol", "lastName": "Flynn"]),
        "spy": Box(didRender)
    ]
    template.render(Box(data))!

The string argument of DidRenderFunction is optional: it is nil if and only if
the tag could not render because of a rendering error.

:see: WillRenderFunction
*/
public typealias DidRenderFunction = (tag: Tag, box: MustacheBox, string: String?) -> Void


