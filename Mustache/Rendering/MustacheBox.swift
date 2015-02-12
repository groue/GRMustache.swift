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
// MARK: - Core function types
//
// GRMustache defines five "core function types". Each one defines a way to
// interact with the rendering engine.
//
// - SubscriptFunction extracts keys: {{name}} knows which value to render by
//   invoking a SubscriptFunction with the "name" argument.
//
// - FilterFunction evaluates filter expressions: {{f(x)}} invokes a
//   FilterFunction.
//
// - RenderFunction renders Mustache tags: {{name}} and {{#items}}...{{/items}}
//   both invoke a RenderFunction
//
// - WillRenderFunction can process a value before it gets rendered
//
// - DidRenderFunction is symmetric to WillRenderFunction: it is called after a
//   value has been rendered


// =============================================================================
// MARK: - SubscriptFunction

/**
SubscriptFunction turns a string key into a value. When GRMustache evaluates
expressions such as {{ name }} or {{ user.name }}, is extract the `name` and
`user` keys using a SubscriptFunction.

You can write and render your own SubscriptFunction:

::

  let s: SubscriptFunction = { (key: String) -> MustacheBox? in
      return Box(key.uppercaseString)
  }
  
  // Render "FOO & BAR"
  let template = Template(string: "{{foo}} & {{bar}}")!
  let rendering = template.render(Box(s))!

A SubscriptFunction is also the way to let your Swift types feed templates:

::

  struct User {
      let name: String
  }

  let user = User(name: "Arthur")
  let template = Template(string: "Hello {{name}}")!

  // Attempt to feed the template with the user produces a compiler error, since
  // User can not be boxed.
  let rendering = template.render(Box(user))!

  // Make User conform to MustacheBoxable
  extension User: MustacheBoxable {
      var mustacheBox: MustacheBox {
          // Return a Box that wraps our user, and knows how to extract
          // the `name` key of our user with a SubscriptFunction:
          return Box(value: self) { (key: String) in
              switch key {
              case "name":
                  return Box(self.name)
              default:
                  return nil
              }
          }
      }
  }
  
  // Render "Hello Arthur"
  let rendering = template.render(Box(user))!
*/
public typealias SubscriptFunction = (key: String) -> MustacheBox?


// =============================================================================
// MARK: - FilterFunction

/**
FilterFunction is the core type that lets GRMustache evalute filtered
expressions such as {{ uppercase(name) }}.

It turns a MustacheBox to another MustacheBox, and optionally returns an error.

You will generally not write your own FilterFunction, but rather use the
Filter() function. For example, here is a filter that processes integers:

::

  let square = Filter { (x: Int, error: NSErrorPointer) in
      return Box(x * x)
  }

  let template = Template(string: "{{square(x)}}")!
  template.registerInBaseContext("square", Box(square))

  // Renders "100"
  let rendering = template.render(Box(["x": 10]))!


If you want to have a section like {{# section }}...{{/ section }} perform a
custom rendering of its inner content, you do not need a FilterFunction because
there is no parenthesis that would denote the presence of a filter. No, instead
you need a RenderFunction (see below).

However, if you want a section like {{# pluralize(count) }}...{{/ }} perform a
custom rendering of its inner content, depending on the value of `count`, then
you are at the right place. Keep on reading.


The Filter() function comes in various flavors. Each one targets a use case for
filters:


- func Filter(filter: (MustacheBox, NSErrorPointer) -> MustacheBox?) -> FilterFunction

The most generic filter that takes a single Box argument and returns another
one.

If you want to process a specific type such as Int, String, or a custom class,
you should use a variant documented below.

::

  let isEmpty = Filter { (box: MustacheBox, error: NSErrorPointer) in
      return Box(box.isEmpty)
  }

  let template = Template(string: "{{# isEmpty(value) }}no value{{^}}{{value}}{{/}}")!
  template.registerInBaseContext("isEmpty", Box(isEmpty))

  // Renders "a value", and "no value"
  var rendering = template.render(Box(["value": "a value"]))!
  rendering = template.render(Box())!


- func Filter<T>(filter: (T?, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Int?, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (UInt?, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Double?, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (String?, NSErrorPointer) -> MustacheBox?) -> FilterFunction

Those variants returns a filter that takes an optional single argument of a
specific type.

If the provided argument is not nil, and of a different type, the filter returns
an error of domain GRMustacheErrorDomain and code
GRMustacheErrorCodeRenderingError.

The generic <T> variant is strict about its input: only values of type T enter
your filter. Other values generate an error. The type T must be "real" type, not
a protocol, because of the Swift inability to test for protocol conformance at
runtime.

The Int, UInt and Double variants accept numerical input (Float, Double, Int and
NSNumber), which are casted to the required type. Other values generate an
error.

The String variant accepts string input (String and NSString). Other values
generate an error. If you want to process rendered strings, whatever the input
value, you should use the (Rendering, NSErrorPointer) -> Rendering? variant
(see below).

::

  let succ = Filter { (i: Int?, error: NSErrorPointer) in
      if let i = i {
          return Box(i + 1)
      }
      return Box("Nil")
  }

  let template = Template(string: "{{ succ(x) }}")!
  template.registerInBaseContext("succ", Box(succ))

  // Renders "2", "3", "4"
  var rendering: String
  rendering = template.render(Box(["x": 1]))!
  rendering = template.render(Box(["x": 2.0]))!
  rendering = template.render(Box(["x": NSNumber(float: 3.1415)]))!

  // Renders "Nil"
  rendering = template.render(Box())!

  // Error evaluating {{ succ(x) }} at line 1: Unexpected argument type
  var error: NSError?
  template.render(Box(["x": "2.0"]), error: &error)
  error?.localizedDescription


- func Filter<T>(filter: (T, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Int, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (UInt, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Double, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (String, NSErrorPointer) -> MustacheBox?) -> FilterFunction

Those variants returns a filter that takes a single argument of a specific type.

If the provided argument is nil, or of a different type, the filter returns an
error of domain GRMustacheErrorDomain and code
GRMustacheErrorCodeRenderingError.

The generic <T> variant is strict about its input: only values of type T enter
your filter. Other values generate an error. The type T must be "real" type, not
a protocol, because of the Swift inability to test for protocol conformance at
runtime.

The Int, UInt and Double variants accept numerical input (Float, Double, Int and
NSNumber), which are casted to the required type. Other values generate an
error.

The String variant accepts string input (String and NSString). Other values
generate an error. If you want to process rendered strings, whatever the input
value, you should use the (Rendering, NSErrorPointer) -> Rendering? variant
(see below).

::

  let succ = Filter { (i: Int, error: NSErrorPointer) in
      return Box(i + 1)
  }

  let template = Template(string: "{{ succ(x) }}")!
  template.registerInBaseContext("succ", Box(succ))

  // Renders "2", "3", "4"
  var rendering: String
  rendering = template.render(Box(["x": 1]))!
  rendering = template.render(Box(["x": 2.0]))!
  rendering = template.render(Box(["x": NSNumber(float: 3.1415)]))!

  // Error evaluating {{ succ(x) }} at line 1: Unexpected argument type
  var error: NSError?
  template.render(Box(["x": "string"]), error: &error)
  error?.localizedDescription
  template.render(Box(), error: &error)
  error?.localizedDescription


- func Filter(filter: (Rendering, NSErrorPointer) -> Rendering?) -> FilterFunction

Returns a filter that performs post rendering.

Unlike other filters that process boxed values, this one processes output: it
turns a Rendering into another Rendering. It provides a way to process the
strings generated by any kind of value.

::

  let twice = Filter { (rendering: Rendering, error: NSErrorPointer) in
    return Rendering(rendering.string + rendering.string)
  }
  
  let template = Template(string: "{{ twice(x) }}")!
  template.registerInBaseContext("twice", Box(twice))

  // Renders "foofoo", "123123"
  var rendering: String
  rendering = template.render(Box(["x": "foo"]))!
  rendering = template.render(Box(["x": 123]))!

Beware eventual HTML-escaping has not happened yet: the rendering argument may
contain text. Use the Mustache.escapeHTML() function if you need to convert Text
to HTML:

::

  // Wraps its input in a <strong> HTML tag.
  let strong = Filter { (rendering: Rendering, error: NSErrorPointer) in
      // We return HTML, so we need to escape input if necessary.
      var string = rendering.string
      switch rendering.contentType {
      case .Text:
          string = escapeHTML(string)
      case .HTML:
          break
      }
      return Rendering("<strong>\(string)</strong>", .HTML)
  }

  let template = Template(string: "{{ strong(x) }}")!
  template.registerInBaseContext("strong", Box(strong))

  // Renders "<strong>Arthur &amp; Léa</strong>"
  var rendering: String
  rendering = template.render(Box(["x": "Arthur & Léa"]))!


- func Filter(filter: (MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter<T>(filter: (T, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (UInt, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (UInt?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Double, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (String, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (String?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction

Those variants return filters that are able to perform custom rendering.

The RenderingInfo type is documented with the RenderFunction type below.

For information about the various inputs (MustacheBox, T, Int, etc.), see above.

::

  // {{# pluralize(count) }}...{{/ }} renders the plural form of the section
  // content if the `count` argument is greater than 1.
  let pluralize = Filter { (count: Int, info: RenderingInfo, error: NSErrorPointer) in

      // Pluralize the inner content of the section tag:
      var string = info.tag.innerTemplateString
      if count > 1 {
          string += "s"  // naive
      }

      return Rendering(string)
  }

  let template = Template(string: "I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.")!
  template.registerInBaseContext("pluralize", Box(pluralize))
  
  // Renders "I have 3 cats."
  let data = ["cats": ["Kitty", "Pussy", "Melba"]]
  let rendering = template.render(Box(data))!


- func VariadicFilter(filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction

Returns a filter than accepts any number of arguments.

If your filter is given too many or too few arguments, please return an NSError
of domain GRMustacheErrorDomain and code GRMustacheErrorCodeRenderingError.

::

  let sum = VariadicFilter { (boxes: [MustacheBox], error: NSErrorPointer) in
      // Extract integers out of input boxes
      let integers = map(boxes) { $0.intValue ?? 0 }
      
      // Compute and box the sum
      let sum = integers.reduce(0,+)
      return Box(sum)
  }

  let template = Template(string: "{{ sum(a,b,c) }}")!
  template.registerInBaseContext("sum", Box(sum))

  // Renders "6"
  let rendering = template.render(Box(["a": 1, "b": 2, "c": 3]))!
*/
public typealias FilterFunction = (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox?


/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (MustacheBox, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
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

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter<T>(filter: (T?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if box.isEmpty {
            return filter(nil, error)
        } else if let t = box.value as? T {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter<T>(filter: (T, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.value as? T {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Int?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if box.isEmpty {
            return filter(nil, error)
        } else if let t = box.intValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Int, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.intValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (UInt?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if box.isEmpty {
            return filter(nil, error)
        } else if let t = box.uintValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (UInt, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.uintValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Double?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if box.isEmpty {
            return filter(nil, error)
        } else if let t = box.doubleValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Double, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.doubleValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (String?, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if box.isEmpty {
            return filter(nil, error)
        } else if let t = box.stringValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (String, NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Too many arguments"])
            }
            return nil
        } else if let t = box.stringValue {
            return filter(t, error)
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Unexpected argument type"])
            }
            return nil
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Rendering, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        if partialApplication {
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
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (box: MustacheBox, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(box, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (t: T?, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(t, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter<T>(filter: (T, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (t: T, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(t, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (int: Int?, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(int, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (int: Int, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(int, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (UInt?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (uint: UInt?, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(uint, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (UInt, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (uint: UInt, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(uint, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (double: Double?, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(double, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (Double, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (double: Double, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(double, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (String?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (string: String?, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(string, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (String, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    return Filter { (string: String, error: NSErrorPointer) in
        return Box { (info: RenderingInfo, error: NSErrorPointer) in
            return filter(string, info, error)
        }
    }
}

/**
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func VariadicFilter(filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return _VariadicFilter([], filter)
}

private func _VariadicFilter(boxes: [MustacheBox], filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) in
        let boxes = boxes + [box]
        if partialApplication {
            // await another argument
            return Box(_VariadicFilter(boxes, filter))
        } else {
            // no more argument: compute final value
            return filter(boxes: boxes, error: error)
        }
    }
}


// =============================================================================
// MARK: - RenderFunction

/**
A RenderFunction is invoked as soon as a variable tag {{name}} or a section
tag {{#name}}...{{/name}} is rendered, and lets you implement custom rendering.

This is how, for example, you implement "Mustache lambdas".

::

  // A custom render function
  let render: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
      return Rendering("foo")
  }
  
  // A template that contains both a section and a variable tag:
  let template = Template(string: "{{#section}}variable: {{variable}}{{/section}}")!
  
  // Attach the render function to `variable`: render "variable: foo"
  let data1 = ["section": Box(["variable": Box(render)])]
  let rendering1 = template.render(Box(data1))!

  // Attach the render function to `section`: render "foo"
  let data2 = ["section": Box(render)]
  let rendering2 = template.render(Box(data2))!


The Mustache specification defines lambdas at
https://github.com/mustache/spec/blob/master/specs/%7Elambdas.yml:

> Lambdas are a special-cased data type for use in interpolations and
> sections.
>
> When used as the data value for an Interpolation tag, the lambda MUST be
> treatable as an arity 0 function, and invoked as such.  The returned value
> MUST be rendered against the default delimiters, then interpolated in place
> of the lambda.

So here the way to write a spec-compliant lambda for a variable tag:

::
  // This RenderFunction is equivalent to the pure spec lambda:
  //
  // lambda() -> String {
  //     return "Hello {{ name }}"
  // }

  let greeting: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
      let lambdaString = "Hello {{ name }}"
      let template = Template(string: lambdaString)!
      return template.render(info.context, error: error)
  }

  let template = Template(string: "{{ greeting }}")!

  // Renders "Hello Arthur"
  let rendering = template.render(Box(["greeting": Box(greeting), "name": Box("Arthur")]))!

The spec continues:

> When used as the data value for a Section tag, the lambda MUST be treatable
> as an arity 1 function, and invoked as such (passing a String containing the
> unprocessed section contents).  The returned value MUST be rendered against
> the current delimiters, then interpolated in place of the section.

::

  // The strong RenderFunction below is equivalent to the pure spec lambda:
  //
  // lambda(string) -> String {
  //     return "<strong>\(string)</strong>"
  // }
  //
  // To this mustache.js lambda:
  //
  // var data = {
  //     strong : function() {
  //         return function(text, render) {
  //             return "<strong>" + render(text) + "</strong>"
  //         }
  //     }
  // };
  //
  // To this Ruby mustache lambda:
  //
  // class MyView < Mustache
  //   def strong
  //     lambda do |text|
  //       "<strong#{render(text)}</strong>"
  //     end
  //   end
  // end

  let strong: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
      let lambdaString = "<strong>\(info.tag.innerTemplateString)</strong>"
      let template = Template(string: lambdaString)!
      return template.render(info.context, error: error)
  }

Note how the spec, mustache.js and Ruby mustache require a double parsing of
the inner content of the section: they all process a String containing the
unprocessed section contents.

There is a better way to write this lambda, by wrapping the rendering of the
already-parsed Mustache tag:

::

  // The strong RenderFunction below is equivalent to this Handlebars.js helper:
  //
  // Handlebars.registerHelper('strong', function(options) {
  //   return new Handlebars.SafeString(
  //     '<strong>'
  //     + options.fn(this)
  //     + '</strong>');
  // });

  let strong: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
      return Rendering(
          "<strong>" +
          info.tag.render(info.context)!.string +   // Ignore errors for this example
          "</strong>", .HTML)
  }

  let template = Template(string: "{{#strong}}Hello {{name}}{{/strong}}")!
  template.registerInBaseContext("strong", Box(strong))

  // Renders "<strong>Hello Arthur</strong>"
  let rendering = template.render(Box(["name": Box("Arthur")]))!

RenderFunction is invoked for both {{ variable }} and {{# section }}...{{/}}
tags. You can query info.tag.type in order to have a different rendering
depending on the tag type:

::

  let render: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) in
      switch info.tag.type {
      case .Variable:
          return Rendering("variable")
      case .Section:
          return Rendering("section")
      }
  }

  let template = Template(string: "{{object}}, {{#object}}...{{/object}}")!

  // Renders "variable, section"
  let rendering = template.render(Box(["object": Box(render)]))!

*/
public typealias RenderFunction = (info: RenderingInfo, error: NSErrorPointer) -> Rendering?


/**
A Rendering is a tainted String, which knows its content type, Text or HTML.
*/
public struct Rendering {
    public let string: String
    public let contentType: ContentType
    
    /**
    Builds a Rendering with a String and a ContentType.
    
    Usage:
    
    ::
    
      Rendering("foo")        // Defaults to Text
      Rendering("foo", .Text)
      Rendering("foo", .HTML)
    
    You will meet the Rendering type when you implement custom rendering
    functions. Example:
    
    ::
    
      let render: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
          return Rendering("foo")
      }
    
      // Renders "foo"
      let template = Template(string: "{{object}}")!
      let data = ["object": Box(render)]
      let rendering = template.render(Box(data))!
    
    :param: string A string
    :param: contentType A content type
    
    :see: RenderFunction
    */
    public init(_ string: String, _ contentType: ContentType = .Text) {
        self.string = string
        self.contentType = contentType
    }
}

/**
The RenderingInfo type has no public initializer. You will meet it when you
implement custom rendering functions of type RenderFunction.

A RenderFunction is invoked as soon as a variable tag {{name}} or a section
tag {{#name}}...{{/name}} is rendered. Its RenderingInfo parameter provides
information about the rendered tag, and the context stack.

:see: RenderFunction
:see: Tag
:see: Context
*/
public struct RenderingInfo {
    
    /**
    The currently rendered tag.
    
    :see: Tag
    */
    public let tag: Tag
    
    /**
    The current context stack.
    
    :see: Context
    */
    public var context: Context
    
    
    // -------------------------------------------------------------------------
    // Non-public
    
    let enumerationItem: Bool
    
    func renderingInfoBySettingEnumerationItem() -> RenderingInfo {
        return RenderingInfo(tag: tag, context: context, enumerationItem: true)
    }
}


// =============================================================================
// MARK: - WillRenderFunction

/**
Once a WillRenderFunction has entered the context stack, it is called just
before tags are about to render, and has the opportunity to replace the value
they are about to render.

::

  let willRender: WillRenderFunction = { (tag: Tag, box: MustacheBox) in
      println("\(tag) will render \(box.value!)")
      return box
  }
  
  // By entering the base context of the template, the willRender function
  // will be notified of all tags.
  let template = Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")!
  template.extendBaseContext(Box(willRender))
  
  // Renders "Errol Flynn"
  //
  // Prints:
  // {{# user }} at line 1 will render { firstName = Errol; lastName = Flynn; }
  // {{ firstName }} at line 1 will render Errol
  // {{ lastName }} at line 1 will render Flynn
  let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
  let rendering = template.render(Box(data))!

WillRender functions don't have to enter the base context of a template to
perform: they can enter the context stack just like any other value, by being
attached to a section. In this case, they are only notified of tags inside that
section.

  let template = Template(string: "{{# user }}{{ firstName }} {{# spy }}{{ lastName }}{{/ spy }}{{/ user }}")!
  
  // Renders "Errol Flynn"
  //
  // Prints:
  // {{ lastName }} at line 1 will render Flynn
  let data = [
      "user": Box(["firstName": "Errol", "lastName": "Flynn"]),
      "spy": Box(willRender)
  ]
  let rendering = template.render(Box(data))!

WillRenderFunction and DidRenderFunction work nicely together:

::

  var indentLevel = 0
  
  // willRender outputs the rendered tags, and increments indentation level when
  // it enters a section tag.
  let willRender: WillRenderFunction = { (tag: Tag, box: MustacheBox) in
      print(String(count: indentLevel * 4, repeatedValue: " " as Character))
      println(tag)
      if tag.type == TagType.Section {
          indentLevel++
      }
      return box
  }
  
  // didRender decrements indentation level when it leaves a section tag.
  let didRender: DidRenderFunction = { (tag: Tag, box: MustacheBox, string: String?) in
      if tag.type == TagType.Section {
          indentLevel--
      }
  }
  
  // Have both willRender and didRender enter the context stack:
  let template = Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}\nAwards: {{# awards }}\n- {{.}}{{/ awards }}")!
  template.extendBaseContext(Box(willRender: willRender, didRender: didRender))
  
  // Prints:
  // {{# user }} at line 1
  //     {{ firstName }} at line 1
  //     {{ lastName }} at line 1
  // {{# awards }} at line 2
  //     {{.}} at line 3
  //     {{.}} at line 3
  //     {{.}} at line 3
  let data = [
      "user": [
          "firstName": "Sean",
          "lastName": "Connery"],
      "awards": ["Academy Award", "BAFTA Awards", "Golden Globes"]]
  let rendering = template.render(Box(data))!

:see: DidRenderFunction
:see: Tag
:see: MustacheBox
*/
public typealias WillRenderFunction = (tag: Tag, box: MustacheBox) -> MustacheBox


// =============================================================================
// MARK: - DidRenderFunction

/**
Once a DidRenderFunction has entered the context stack, it is called just
after tags have been rendered.

::

  let didRender: DidRenderFunction = { (tag: Tag, box: MustacheBox, string: String?) in
      println("\(tag) did render \(box.value!) as `\(string!)`")
  }
  
  // By entering the base context of the template, the willRender function
  // will be notified of all tags.
  let template = Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")!
  template.extendBaseContext(Box(didRender))
  
  // Renders "Errol Flynn"
  //
  // Prints:
  // {{ firstName }} at line 1 did render Errol as `Errol`
  // {{ lastName }} at line 1 did render Flynn as `Flynn`
  // {{# user }} at line 1 did render { firstName = Errol; lastName = Flynn; } as `Errol Flynn`
  // let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
  let rendering = template.render(Box(data))!

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
      "spy": Box(willRender)
  ]
  let rendering = template.render(Box(data))!

TODO: document why the string argument is optional
TODO: document how to wrap both a WillRenderFunction and DidRenderFunction
*/
public typealias DidRenderFunction = (tag: Tag, box: MustacheBox, string: String?) -> Void


// =============================================================================
// MARK: - MustacheBox

public struct MustacheBox {
    
    struct Converter {
        let intValue: (() -> Int?)?
        let uintValue: (() -> UInt?)?
        let doubleValue: (() -> Double?)?
        let stringValue: (() -> String?)?
        let arrayValue: (() -> [MustacheBox]?)?
        let dictionaryValue: (() -> [String: MustacheBox]?)?
        
        init(
            intValue: (() -> Int?)? = nil,
            uintValue: (() -> UInt?)? = nil,
            doubleValue: (() -> Double?)? = nil,
            stringValue: (() -> String?)? = nil,
            arrayValue: (() -> [MustacheBox]?)? = nil,
            dictionaryValue: (() -> [String: MustacheBox]?)? = nil)
        {
            self.intValue = intValue
            self.uintValue = uintValue
            self.doubleValue = doubleValue
            self.stringValue = stringValue
            self.arrayValue = arrayValue
            self.dictionaryValue = dictionaryValue
        }
    }
    
    public let isEmpty: Bool
    public let value: Any?
    public let mustacheBool: Bool
    public let mustacheSubscript: SubscriptFunction?
    public let render: RenderFunction
    public let filter: FilterFunction?
    public let willRender: WillRenderFunction?
    public let didRender: DidRenderFunction?
    let converter: Converter?
    
    init(
        mustacheBool: Bool? = nil,
        value: Any? = nil,
        converter: Converter? = nil,
        mustacheSubscript: SubscriptFunction? = nil,
        filter: FilterFunction? = nil,
        render: RenderFunction? = nil,
        willRender: WillRenderFunction? = nil,
        didRender: DidRenderFunction? = nil)
    {
        let empty = (value == nil) && (mustacheSubscript == nil) && (render == nil) && (filter == nil) && (willRender == nil) && (didRender == nil)
        self.isEmpty = empty
        self.value = value
        self.converter = converter
        self.mustacheBool = mustacheBool ?? !empty
        self.mustacheSubscript = mustacheSubscript
        self.filter = filter
        self.willRender = willRender
        self.didRender = didRender
        if let render = render {
            self.render = render
        } else {
            // Avoid compiler error: variable 'self.render' captured by a closure before being initialized
            self.render = { (info: RenderingInfo, error: NSErrorPointer) in return nil }
            self.render = { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    if let value = value {
                        return Rendering("\(value)")
                    } else {
                        return Rendering("")
                    }
                case .Section:
                    return info.tag.render(info.context.extendedContext(self), error: error)
                }
            }
        }
    }

    // Hackish helper function which helps us boxing NSArray, NSString and
    // NSNull: we just box a regular [MustacheBox] or Swift String, and rewrite
    // the value to the original Objective-C value.
    func boxWithValue(value: Any?) -> MustacheBox {
        return MustacheBox(
            mustacheBool: self.mustacheBool,
            value: value,
            converter: self.converter,
            mustacheSubscript: self.mustacheSubscript,
            filter: self.filter,
            render: self.render,
            willRender: self.willRender,
            didRender: self.didRender)
    }
}

/**
An example of a multi-facetted type:

::

  class Person {
      let firstName: String
      let lastName: String
    
      init(firstName: String, lastName: String) {
          self.firstName = firstName
          self.lastName = lastName
      }
  }

  extension Person: MustacheBoxable {
      var mustacheBox: MustacheBox {
          // A person is a multi-facetted object:
          return Box(
              // It has a value:
              value: self,
            
              // It lets Mustache extracts values by name:
              mustacheSubscript: mustacheSubscript,
            
              // It performs custom rendering:
              render: render)
      }
    
      // A SubscriptFunction is necessary for Mustache to extract values by name.
      func mustacheSubscript(key: String) -> MustacheBox? {
          switch key {
          case "firstName":
              return Box(firstName)
          case "lastName":
              return Box(lastName)
          default:
              return nil
          }
      }
    
      // The custom RenderFunction escapes default Mustache rendering
      func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
          switch info.tag.type {
          case .Variable:
              // Custom rendering of {{ person }} variable tags:
              let template = Template(string: "{{firstName}} {{lastName}}")!
              let context = info.context.extendedContext(Box(self))
              return template.render(context, error: error)
          case .Section:
              // Regular rendering of {{# person }}...{{/}} section tags:
              // Extend the context with self, and render the content of the tag:
              let context = info.context.extendedContext(Box(self))
              return info.tag.render(context, error: error)
          }
      }
  }

  // Renders "The person is Errol Flynn"
  let person = Person(firstName: "Errol", lastName: "Flynn")
  let template = Template(string: "{{# person }}The person is {{.}}{{/ person }}")!
  let rendering = template.render(Box(["person": person]))!
*/

public func Box(
    mustacheBool: Bool? = nil,
    value: Any? = nil,
    mustacheSubscript: SubscriptFunction? = nil,
    filter: FilterFunction? = nil,
    render: RenderFunction? = nil,
    willRender: WillRenderFunction? = nil,
    didRender: DidRenderFunction? = nil) -> MustacheBox
{
    return MustacheBox(
        mustacheBool: mustacheBool,
        value: value,
        mustacheSubscript: mustacheSubscript,
        filter: filter,
        render: render,
        willRender: willRender,
        didRender: didRender)
}


// =============================================================================
// MARK: - Value unwrapping

extension MustacheBox {
    
    /**
    If the boxed value is numerical (Swift numerical types, Bool, and NSNumber),
    returns this value as an Int.
    */
    public var intValue: Int? {
        return converter?.intValue?()
    }
    
    /**
    If the boxed value is numerical (Swift numerical types, Bool, and NSNumber),
    returns this value as a UInt.
    */
    public var uintValue: UInt? {
        return converter?.uintValue?()
    }
    
    /**
    If the boxed value is numerical (Swift numerical types, Bool, and NSNumber),
    returns this value as a Double.
    */
    public var doubleValue: Double? {
        return converter?.doubleValue?()
    }
    
    /**
    If the boxed value is a string (String and NSString), returns this value as
    a String.
    */
    public var stringValue: String? {
        return converter?.stringValue?()
    }
    
    /**
    If boxed value can be iterated (Swift collection, NSArray, NSSet, etc.),
    returns a [MustacheBox].
    */
    public var arrayValue: [MustacheBox]? {
        return converter?.arrayValue?()
    }
    
    /**
    If boxed value is a dictionary (Swift dictionary, NSDictionary, etc.),
    returns a [String: MustacheBox] dictionary.
    */
    public var dictionaryValue: [String: MustacheBox]? {
        return converter?.dictionaryValue?()
    }

}


// =============================================================================
// MARK: - DebugPrintable

extension MustacheBox: DebugPrintable {
    
    public var debugDescription: String {
        if let value = value {
            return "MustacheBox(\(value))"  // remove "Optional" from the output
        } else {
            return "MustacheBox(nil)"
        }
    }
}


// =============================================================================
// MARK: - Key extraction

extension MustacheBox {
    
    subscript(key: String) -> MustacheBox {
        if let mustacheSubscript = mustacheSubscript {
            if let box = mustacheSubscript(key: key) {
                return box
            }
        }
        return Box()
    }
}


// =============================================================================
// MARK: - Boxing of Core Mustache functions

// Non-optional value to force the user to provide a value when they provide a
// subscript function.
public func Box(value: Any, mustacheSubscript: SubscriptFunction) -> MustacheBox {
    return MustacheBox(value: value, mustacheSubscript: mustacheSubscript)
}

public func Box(value: Any? = nil, filter: FilterFunction) -> MustacheBox {
    return MustacheBox(value: value, filter: filter)
}

public func Box(value: Any? = nil, render: RenderFunction) -> MustacheBox {
    return MustacheBox(value: value, render: render)
}

public func Box(value: Any? = nil, willRender: WillRenderFunction) -> MustacheBox {
    return MustacheBox(value: value, willRender: willRender)
}

public func Box(value: Any? = nil, didRender: DidRenderFunction) -> MustacheBox {
    return MustacheBox(value: value, didRender: didRender)
}


// =============================================================================
// MARK: - Boxing of Swift scalar types

public protocol MustacheBoxable {
    var mustacheBox: MustacheBox { get }
}

public func Box(boxable: MustacheBoxable?) -> MustacheBox {
    if let boxable = boxable {
        return boxable.mustacheBox
    } else {
        return Box()
    }
}

extension MustacheBox: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        return self
    }
}

extension Bool: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { self ? 1 : 0 },         // Behave like [NSNumber numberWithBool:]
                uintValue: { self ? 1 : 0 },        // Behave like [NSNumber numberWithBool:]
                doubleValue: { self ? 1.0 : 0.0 }), // Behave like [NSNumber numberWithBool:]
            mustacheBool: self,
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(self)")
                case .Section:
                    // https://github.com/groue/GRMustache/issues/83
                    //
                    // {{# NSNumber }}...{{/}} renders the section if the number is
                    // not zero, and does not push the number on the top of the
                    // context stack.
                    //
                    // Be consistent with Objective-C, and make Bool behave just
                    // like [NSNumber numberWithBool:]
                    if info.enumerationItem {
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}

extension Int: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { self },
                uintValue: { UInt(self) },
                doubleValue: { Double(self) }),
            mustacheBool: (self != 0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(self)")
                case .Section:
                    // https://github.com/groue/GRMustache/issues/83
                    //
                    // {{# NSNumber }}...{{/}} renders the section if the number is
                    // not zero, and does not push the number on the top of the
                    // context stack.
                    //
                    // Be consistent with Objective-C, and make Int behave just
                    // like [NSNumber numberWithInteger:]
                    if info.enumerationItem {
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}

extension UInt: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { Int(self) },
                uintValue: { self },
                doubleValue: { Double(self) }),
            mustacheBool: (self != 0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(self)")
                case .Section:
                    // https://github.com/groue/GRMustache/issues/83
                    //
                    // {{# NSNumber }}...{{/}} renders the section if the number is
                    // not zero, and does not push the number on the top of the
                    // context stack.
                    //
                    // Be consistent with Objective-C, and make Int behave just
                    // like [NSNumber numberWithInteger:]
                    if info.enumerationItem {
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}

extension Double: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { Int(self) },
                uintValue: { UInt(self) },
                doubleValue: { self }),
            mustacheBool: (self != 0.0),
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(self)")
                case .Section:
                    // https://github.com/groue/GRMustache/issues/83
                    //
                    // {{# NSNumber }}...{{/}} renders the section if the number is
                    // not zero, and does not push the number on the top of the
                    // context stack.
                    //
                    // Be consistent with Objective-C, and make Double behave just
                    // like [NSNumber numberWithDouble:]
                    if info.enumerationItem {
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        return info.tag.render(info.context, error: error)
                    }
                }
        })
    }
}

extension String: MustacheBoxable {
    public var mustacheBox: MustacheBox {
        return MustacheBox(
            value: self,
            converter: MustacheBox.Converter(stringValue: { self }),
            mustacheBool: (countElements(self) > 0),
            mustacheSubscript: { (key: String) in
                switch key {
                case "length":
                    return Box(countElements(self))
                default:
                    return nil
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(self)")
                case .Section:
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                }
        })
    }
}


// =============================================================================
// MARK: - Boxing of Swift collections

// We don't provide any boxing function for `SequenceType`, because this type
// makes no requirement on conforming types regarding whether they will be
// destructively "consumed" by iteration (as stated by documentation).
//
// Now we need to consume a sequence several times:
//
// - for converting it to an array for the arrayValue property.
// - for consuming the first element to know if the sequence is empty or not.
// - for rendering it.
//
// So if we could provide some support for rendering sequences, it is somewhat
// difficult: give up for now, and provide a boxing function for
// `CollectionType` which ensures non-destructive iteration.


private func renderCollection<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C, info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
    var buffer = ""
    var contentType: ContentType?
    let enumerationRenderingInfo = info.renderingInfoBySettingEnumerationItem()
    for item in collection {
        let box = Box(item)
        if let boxRendering = box.render(info: enumerationRenderingInfo, error: error) {
            if contentType == nil {
                contentType = boxRendering.contentType
                buffer += boxRendering.string
            } else if contentType == boxRendering.contentType {
                buffer += boxRendering.string
            } else {
                if error != nil {
                    error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Content type mismatch"])
                }
                return nil
            }
        } else {
            return nil
        }
    }
    
    if let contentType = contentType {
        return Rendering(buffer, contentType)
    } else {
        return info.tag.render(info.context, error: error)
    }
}

public func Box<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(collection: C?) -> MustacheBox {
    if let collection = collection {
        let count = distance(collection.startIndex, collection.endIndex)    // C.Index.Distance == Int
        return MustacheBox(
            mustacheBool: (count > 0),
            value: collection,
            converter: MustacheBox.Converter(arrayValue: { map(collection) { Box($0) } }),
            mustacheSubscript: { (key: String) in
                switch key {
                case "count":
                    // Support for both Objective-C and Swift arrays.
                    return Box(count)
                    
                case "isEmpty":
                    // Support for Swift arrays.
                    return Box(count == 0)
                    
                case "firstObject", "first":
                    // Support for both Objective-C and Swift arrays.
                    if count > 0 {
                        return Box(collection[collection.startIndex])
                    } else {
                        return Box()
                    }
                    
                case "lastObject", "last":
                    // Support for both Objective-C and Swift arrays.
                    if count > 0 {
                        return Box(collection[collection.endIndex.predecessor()])   // C.Index: BidirectionalIndexType
                    } else {
                        return Box()
                    }
                    
                default:
                    return Box()
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(collection)), error: error)
                } else {
                    return renderCollection(collection, info, error)
                }
        })
    } else {
        return Box()
    }
}


// =============================================================================
// MARK: - Boxing of Swift dictionaries

public func Box<T: MustacheBoxable>(dictionary: [String: T]?) -> MustacheBox {
    if let dictionary = dictionary {
        
        return MustacheBox(
            mustacheBool: true,
            value: dictionary,
            converter: MustacheBox.Converter(
                dictionaryValue: {
                    var boxDictionary: [String: MustacheBox] = [:]
                    for (key, item) in dictionary {
                        boxDictionary[key] = Box(item)
                    }
                    return boxDictionary
                }),
            mustacheSubscript: { (key: String) in
                return Box(dictionary[key])
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(dictionary)")
                case .Section:
                    return info.tag.render(info.context.extendedContext(Box(dictionary)), error: error)
                }
            }
        )
    } else {
        return Box()
    }
}


// =============================================================================
// MARK: - Boxing of Objective-C types

/**
Conform to the GRMustacheSafeKeyAccess protocol in order to filter the keys that
can be accessed by GRMustache templates.
*/
@objc public protocol GRMustacheSafeKeyAccess {
    
    /**
    List the name of the keys GRMustache.swift can access on this class using
    the `valueForKey:` method.
    
    When objects do not respond to this method, only declared properties can be
    accessed. All properties of Core Data NSManagedObjects are also accessible,
    even without property declaration.
    
    This method is not used for objects responding to objectForKeyedSubscript:.
    For those objects, all keys are accessible from templates.
    
    @return The set of accessible keys on the class.
    */
    class func safeMustacheKeys() -> NSSet
}

// The MustacheBoxable protocol can not be used by Objc classes, because MustacheBox is
// not compatible with ObjC. So let's define another protocol.
@objc public protocol ObjCMustacheBoxable {
    // Can not return a MustacheBox, because MustacheBox is not compatible with ObjC.
    // So let's return an ObjC object which wraps a MustacheBox.
    var mustacheBox: ObjCMustacheBox { get }
}

// The ObjC object which wraps a MustacheBox (see ObjCMustacheBoxable)
public class ObjCMustacheBox: NSObject {
    let box: MustacheBox
    init(_ box: MustacheBox) {
        self.box = box
    }
}

public func Box(boxable: ObjCMustacheBoxable?) -> MustacheBox {
    if let boxable = boxable {
        return boxable.mustacheBox.box
    } else {
        return Box()
    }
}

public func BoxAnyObject(object: AnyObject?) -> MustacheBox {
    if let object: AnyObject = object {
        if let boxable = object as? ObjCMustacheBoxable {
            return Box(boxable)
        } else {
            // This code path will only run if object is not a NSObject
            // instance, since NSObject conforms to ObjCMustacheBoxable.
            //
            // This may mean that the class of object is NSProxy or any other
            // Objective-C class that does not derive from NSObject.
            //
            // This may also mean that object is an instance of a pure Swift
            // class.
            //
            // Objective-C objects and containers can contain pure Swift
            // instances. For example, given the following array:
            //
            //     class C: MustacheBoxable { ... }
            //     var array = NSMutableArray()
            //     array.addObject(C())
            //
            // GRMustache *can not* known that the array contains a valid
            // boxable value, because NSArray exposes its contents as AnyObject,
            // and AnyObject can not be tested for MustacheBoxable conformance:
            //
            // https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html#//apple_ref/doc/uid/TP40014097-CH25-XID_363
            // > you need to mark your protocols with the @objc attribute if you want to be able to check for protocol conformance.
            //
            // So GRMustache, when given an AnyObject, generally assumes that it
            // is an Objective-C value, even when it is wrong, and ends up here.
            //
            // As a conclusion: let's apologize.
            //
            // TODO: document caveat with something like:
            //
            // If GRMustache.BoxAnyObject was called from your own code, check
            // the type of the value you provide. If not, it is likely that an
            // Objective-C collection like NSArray, NSDictionary, NSSet or any
            // other Objective-C object contains a value that is not an
            // Objective-C object. GRMustache does not support such mixing of
            // Objective-C and Swift values.
            NSLog("Mustache.BoxAnyObject(): value `\(object)` does not conform to the ObjCMustacheBoxable protocol, and is discarded.")
            return Box()
        }
    } else {
        return Box()
    }
}

extension NSObject: ObjCMustacheBoxable {
    public var mustacheBox: ObjCMustacheBox {
        if let enumerable = self as? NSFastEnumeration
        {
            // Enumerable
            
            if respondsToSelector("objectForKeyedSubscript:")
            {
                // Dictionary-like enumerable
                
                return ObjCMustacheBox(MustacheBox(
                    mustacheBool: true,
                    value: self,
                    converter: MustacheBox.Converter(
                        dictionaryValue: {
                            var boxDictionary: [String: MustacheBox] = [:]
                            for key in GeneratorSequence(NSFastGenerator(enumerable)) {
                                if let key = key as? String {
                                    let item = (self as AnyObject)[key] // Cast to AnyObject so that we can access subscript notation.
                                    boxDictionary[key] = BoxAnyObject(item)
                                }
                            }
                            return boxDictionary
                        }),
                    mustacheSubscript: { (key: String) in
                        let item = (self as AnyObject)[key] // Cast to AnyObject so that we can access subscript notation.
                        return BoxAnyObject(item)
                    },
                    render: { (info: RenderingInfo, error: NSErrorPointer) in
                        switch info.tag.type {
                        case .Variable:
                            return Rendering("\(self)")
                        case .Section:
                            return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                        }
                    }
                ))
            }
            else
            {
                // Array-like enumerable
                
                let array = map(GeneratorSequence(NSFastGenerator(enumerable))) { BoxAnyObject($0) }
                let box = Box(array).boxWithValue(self)
                return ObjCMustacheBox(box)
            }
        }
        else
        {
            // Generic NSObject
            
            return ObjCMustacheBox(MustacheBox(
                mustacheBool: true,
                value: self,
                mustacheSubscript: { (key: String) in
                    if self.respondsToSelector("objectForKeyedSubscript:")
                    {
                        // Use objectForKeyedSubscript: first (see https://github.com/groue/GRMustache/issues/66:)
                        return BoxAnyObject((self as AnyObject)[key]) // Cast to AnyObject so that we can access subscript notation.
                    }
                    else if GRMustacheKeyAccess.isSafeMustacheKey(key, forObject: self)
                    {
                        // Use valueForKey: for safe keys
                        return BoxAnyObject(self.valueForKey(key))
                    }
                    else
                    {
                        // Missing key
                        return Box()
                    }
                },
                render: { (info: RenderingInfo, error: NSErrorPointer) in
                    switch info.tag.type {
                    case .Variable:
                        return Rendering("\(self)")
                    case .Section:
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    }
            }))
        }
    }
}

extension NSNull: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(MustacheBox().boxWithValue(self))
    }
}

extension NSNumber: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(MustacheBox(
            value: self,
            converter: MustacheBox.Converter(
                intValue: { self.integerValue },
                uintValue: { UInt(self.unsignedIntegerValue) }, // Oddly, -[NSNumber unsignedIntegerValue] returns an Int
                doubleValue: { self.doubleValue }),
            mustacheBool: self.boolValue,
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                switch info.tag.type {
                case .Variable:
                    return Rendering("\(self)")
                case .Section:
                    if info.enumerationItem {
                        return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                    } else {
                        return info.tag.render(info.context, error: error)
                    }
                }
        }))
    }
}

extension NSString: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(Box(self as String).boxWithValue(self))
    }
}

extension NSSet: ObjCMustacheBoxable {
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(MustacheBox(
            mustacheBool: (self.count > 0),
            value: self,
            converter: MustacheBox.Converter(arrayValue: { map(GeneratorSequence(NSFastGenerator(self))) { BoxAnyObject($0) } }),
            mustacheSubscript: { (key: String) in
                switch key {
                case "isEmpty":
                    return Box(self.count == 0)
                case "count":
                    return Box(self.count)
                case "anyObject":
                    return BoxAnyObject(self.anyObject())
                default:
                    return nil
                }
            },
            render: { (info: RenderingInfo, error: NSErrorPointer) in
                if info.enumerationItem {
                    return info.tag.render(info.context.extendedContext(Box(self)), error: error)
                } else {
                    let boxArray = map(GeneratorSequence(NSFastGenerator(self))) { BoxAnyObject($0) }
                    return renderCollection(boxArray, info, error)
                }
            }))
    }
}
