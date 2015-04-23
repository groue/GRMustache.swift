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
KeyedSubscriptFunction turns a string key into a boxed value. When GRMustache
evaluates expressions such as {{ name }} or {{ user.name }}, is extract both
`name` and `user` using a KeyedSubscriptFunction.

You can write and render your own KeyedSubscriptFunction:

::

  let keyedSubscript: KeyedSubscriptFunction = { (key: String) -> MustacheBox in
      return Box(key.uppercaseString)
  }
  
  // Render "FOO & BAR"
  let template = Template(string: "{{foo}} & {{bar}}")!
  template.render(Box(keyedSubscript))!

A KeyedSubscriptFunction is also the way to let your Swift types feed templates:

::

  struct User {
      let name: String
  }

  let user = User(name: "Arthur")
  let template = Template(string: "Hello {{name}}")!

  // Attempt to feed the template with the user produces a compiler error, since
  // User can not be boxed.
  template.render(Box(user))!

  // Make User conform to MustacheBoxable
  extension User : MustacheBoxable {
      var mustacheBox: MustacheBox {
          // Return a Box that wraps our user, and knows how to extract
          // the `name` key of our user with a KeyedSubscriptFunction:
          return Box(value: self) { (key: String) in
              switch key {
              case "name":
                  return Box(self.name)
              default:
                  return Box()
              }
          }
      }
  }
  
  // Render "Hello Arthur"
  template.render(Box(user))!
*/
public typealias KeyedSubscriptFunction = (key: String) -> MustacheBox


// =============================================================================
// MARK: - FilterFunction

/**
FilterFunction is the core type that lets GRMustache evaluate filtered
expressions such as {{ uppercase(name) }}.

It turns a MustacheBox to another MustacheBox, and optionally returns an error.

You will generally not write your own FilterFunction, but rather use one
procuded by Filter(). For example, here is a filter that processes integers:

::

  let square: FilterFunction = Filter { (x: Int, _) in
      return Box(x * x)
  }

  let template = Template(string: "{{square(x)}}")!
  template.registerInBaseContext("square", Box(square))

  // Renders "100"
  template.render(Box(["x": 10]))!


The Filter() function comes in various flavors. Each one targets a use case for
filters:


- func Filter(filter: (MustacheBox, NSErrorPointer) -> MustacheBox?) -> FilterFunction

The most generic filter that takes a single Box argument and returns another
one.

::

  let isEmpty = Filter { (box: MustacheBox, _) in
      return Box(box.isEmpty)
  }

  let template = Template(string: "{{# isEmpty(value) }}no value{{/}}{{^ isEmpty(value) }}{{value}}{{/}}")!
  template.registerInBaseContext("isEmpty", Box(isEmpty))

  // Renders "a value", and "no value"
  template.render(Box(["value": "a value"]))!
  template.render(Box())!

It is likely you will want to extract the boxed value. MustacheBox comes with
the `value`, `boolValue`, `intValue`, `uintValue`, `doubleValue`, `arrayValue`
and `dictionaryValue` properties. All but the first help extracting values that
may come in different shapes. For example, the `intValue` returns an Int for
boxed ints (obviously), but also doubles and NSNumbers.

Yet, the Filter function comes with more straightforward variants that help you
process int, strings, custom classes, etc:

- func Filter<T>(filter: (T?, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Int?, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (UInt?, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Double?, NSErrorPointer) -> MustacheBox?) -> FilterFunction

Those variants returns a filter that takes an optional single argument of a
specific type.

If the filtered value is nil, or of a different type, the filter gets
nil as its argument.

The Int, UInt and Double variants accept any numerical input (Float, Double,
Int, NSNumber and Bool), which are casted to the required type. Out of bounds
numerical input is turned into nil (an Int filter gets nil if provided with
UInt.max, for example).

The String variant accepts string input (String and NSString). Other values
are turned into nil. If you want to process rendered strings, whatever the input
value, you should use the (Rendering, NSErrorPointer) -> Rendering? variant
(see below).

::

  let succ = Filter { (i: Int?, _) in
      if let i = i {
          return Box(i + 1)
      }
      return Box("Undefined")
  }

  let template = Template(string: "{{ succ(x) }}")!
  template.registerInBaseContext("succ", Box(succ))

  // Render "2", "3", "4"
  template.render(Box(["x": 1]))!
  template.render(Box(["x": 2.0]))!
  template.render(Box(["x": NSNumber(float: 3.1415)]))!

  // Render "Undefined"
  template.render(Box())!
  template.render(Box(["x": "foo"]))!


- func Filter<T>(filter: (T, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Int, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (UInt, NSErrorPointer) -> MustacheBox?) -> FilterFunction
- func Filter(filter: (Double, NSErrorPointer) -> MustacheBox?) -> FilterFunction

Those variants returns a filter that takes a single argument of a specific type.

If the provided argument is nil, or of a different type, the filter returns an
error of domain GRMustacheErrorDomain and code
GRMustacheErrorCodeRenderingError.

The Int, UInt and Double variants accept numerical input (Float, Double, Int,
NSNumber and Bool), which are casted to the required type. Other values and out
of bounds numerical input generate an error.

The String variant accepts string input (String and NSString). Other values
generate an error. If you want to process rendered strings, whatever the input
value, you should use the (Rendering, NSErrorPointer) -> Rendering? variant
(see below).

::

  let succ = Filter { (i: Int, _) in
      return Box(i + 1)
  }

  let template = Template(string: "{{ succ(x) }}")!
  template.registerInBaseContext("succ", Box(succ))

  // Renders "2", "3", "4"
  template.render(Box(["x": 1]))!
  template.render(Box(["x": 2.0]))!
  template.render(Box(["x": NSNumber(float: 3.1415)]))!

  // Error evaluating {{ succ(x) }} at line 1: Unexpected argument
  var error: NSError?
  template.render(Box(), error: &error)
  template.render(Box(["x": UInt.max]), error: &error)
  template.render(Box(["x": "string"]), error: &error)


- func Filter(filter: (Rendering, NSErrorPointer) -> Rendering?) -> FilterFunction

Returns a filter that performs post rendering.

Unlike other filters that process boxed values, this one processes output: it
turns a Rendering into another Rendering. It provides a way to process the
strings generated by any kind of value.

::

  let twice = Filter { (rendering: Rendering, _) in
    return Rendering(rendering.string + rendering.string)
  }
  
  let template = Template(string: "{{ twice(x) }}")!
  template.registerInBaseContext("twice", Box(twice))

  // Renders "foofoo", "123123"
  template.render(Box(["x": "foo"]))!
  template.render(Box(["x": 123]))!

Beware eventual HTML-escaping has not happened yet: the rendering argument may
contain text. Use the Mustache.escapeHTML() function if you need to convert Text
to HTML:

::

  // Wraps its input in a <strong> HTML tag.
  let strong = Filter { (rendering: Rendering, _) in
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
  template.render(Box(["x": "Arthur & Léa"]))!


- func Filter(filter: (MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter<T>(filter: (T, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter<T>(filter: (T?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Int, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Int?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (UInt, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (UInt?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Double, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction
- func Filter(filter: (Double?, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction

Those variants return filters that are able to perform custom rendering, based
on their input.

The RenderingInfo and Rendering types are documented with the RenderFunction
type below.

For information about the various inputs (MustacheBox, Int, <T>, etc.), see
above.

::

  // {{# pluralize(count) }}...{{/ }} renders the plural form of the section
  // content if the `count` argument is greater than 1.
  let pluralize = Filter { (count: Int, info: RenderingInfo, _) in

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
  template.render(Box(data))!


- func VariadicFilter(filter: (boxes: [MustacheBox], error: NSErrorPointer) -> MustacheBox?) -> FilterFunction

Returns a filter than accepts any number of arguments.

If your filter is given too many or too few arguments, you should return nil and
set error to an NSError of domain GRMustacheErrorDomain and code
GRMustacheErrorCodeRenderingError.

Variadic filters are given raw boxes, and it is likely you will want to extract
values out of them. MustacheBox comes with the `value`, `boolValue`, `intValue`,
`uintValue`, `doubleValue`, `arrayValue` and `dictionaryValue` properties. All
but the first help extracting values that may come in different shapes. For
example, `intValue` returns an Int for boxed ints (obviously), but also doubles
and NSNumbers.

::

  let sum = VariadicFilter { (boxes: [MustacheBox], _) in
      // Extract integers out of input boxes
      let integers = map(boxes) { $0.intValue ?? 0 }
      
      // Compute and box the sum
      let sum = integers.reduce(0,+)
      return Box(sum)
  }

  let template = Template(string: "{{ sum(a,b,c) }}")!
  template.registerInBaseContext("sum", Box(sum))

  // Renders "6"
  template.render(Box(["a": 1, "b": 2, "c": 3]))!

:param: box                The argument of the filter.

:param: partialApplication This parameter is used for multi-argument filter
                           expressions such as {{ f(a,b,c) }}.

                           If true, the filter should return another filter
                           that will accept the next argument. If false, box
                           parameter is the last argument of the Mustache filter
                           expression, and the filter should return the result.

                           For single-argument filter expressions such as f(x),
                           partialApplication is always false.
                           
                           We recommend that you do not implement multi-argument
                           filters with this parameter, but instead use the
                           VariadicFilter function. See its documentation.

:param: error              If there is a problem evaluating the result, upon
                           return contains an NSError object that describes the
                           problem.
*/
public typealias FilterFunction = (box: MustacheBox, partialApplication: Bool, error: NSErrorPointer) -> MustacheBox?


/**
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
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
This function is documented with the FilterFunction type.

:see: FilterFunction
*/
public func Filter(filter: (MustacheBox, RenderingInfo, NSErrorPointer) -> Rendering?) -> FilterFunction {
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
    // The roles of core functions are clear:
    // - transforming values is the role of FilterFunction
    // - performing custom rendering is the role of RenderFunction
    //
    // Hence, a "filter that performs custom rendering" is simply a
    // FilterFunction which returns a RenderFunction:
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
A RenderFunction is invoked as soon as a variable tag {{name}} or a section
tag {{#name}}...{{/name}} is rendered, and lets you implement custom rendering.

This is how, for example, you implement "Mustache lambdas".

::

  // A custom render function
  let render: RenderFunction = { (info: RenderingInfo, _) -> Rendering? in
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

Here is the way to write a spec-like lambda for a variable tag:

::

  // This RenderFunction is equivalent to the pure spec lambda:
  //
  // lambda() -> String {
  //     return "Hello {{ name }}"
  // }

  let greeting: RenderFunction = { (info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
      let template = Template(string: "Hello {{ name }}")!
      return template.render(info.context, error: error)
  }

  let template = Template(string: "{{ greeting }}")!

  // Renders "Hello Arthur"
  let data = [
      "name": Box("Arthur"),
      "greeting": Box(greeting)]
  template.render(Box(data))!

The spec continues:

> When used as the data value for a Section tag, the lambda MUST be treatable
> as an arity 1 function, and invoked as such (passing a String containing the
> unprocessed section contents).  The returned value MUST be rendered against
> the current delimiters, then interpolated in place of the section.

::

  // The strong RenderFunction below is equivalent to the pure spec lambda:
  //
  // lambda(string: String) -> String {
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
      let template = Template(string: "<strong>\(info.tag.innerTemplateString)</strong>")!
      return template.render(info.context, error: error)
  }

Note how the spec, mustache.js and Ruby mustache require a double parsing of
the inner, unprocessed, content of the section.

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

  let strong: RenderFunction = { (info: RenderingInfo, _) -> Rendering? in
      let innerContent = info.tag.renderInnerContent(info.context)!.string
      return Rendering("<strong>\(innerContent)</strong>", .HTML)
  }

  let template = Template(string: "{{#strong}}Hello {{name}}{{/strong}}")!
  template.registerInBaseContext("strong", Box(strong))

  // Renders "<strong>Hello Arthur</strong>"
  template.render(Box(["name": Box("Arthur")]))!


As seen in the example above, the returned rendering has a content type, text or
HTML. If you return text, the rendering is HTML-escaped in the final template
rendering (except for {{{triple}}} mustache tags and text templates - see the
Configuration type for more information about text templates).

::

  let HTML: RenderFunction = { (info: RenderingInfo, _) in
      return Rendering("<HTML>", .HTML)
  }
  let text: RenderFunction = { (info: RenderingInfo, _) in
      return Rendering("<text>")   // default content type is text
  }

  // Renders "<HTML>, &lt;text&gt;"
  let template = Template(string: "{{HTML}}, {{text}}")!
  let data = ["HTML": Box(HTML), "text": Box(text)]
  let rendering = template.render(Box(data))!


RenderFunction is invoked for both {{ variable }} and {{# section }}...{{/}}
tags. You can query info.tag.type in order to have a different rendering
depending on the tag type:

::

  let render: RenderFunction = { (info: RenderingInfo, _) in
      switch info.tag.type {
      case .Variable:
          // {{ object }}
          return Rendering("variable")
      case .Section:
          // {{# object }}...{{/ object }}
          return Rendering("section")
      }
  }

  let template = Template(string: "{{object}}, {{#object}}...{{/object}}")!

  // Renders "variable, section"
  template.render(Box(["object": Box(render)]))!


:see: RenderingInfo
:see: Rendering
:see: Configuration
*/
public typealias RenderFunction = (info: RenderingInfo, error: NSErrorPointer) -> Rendering?

/**
TODO: doc & tests
*/
public func Lambda(lambda: String -> String) -> RenderFunction {
    return { (info: RenderingInfo, error: NSErrorPointer) in
        switch info.tag.type {
        case .Variable:
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Section lambda used in a variable tag."])
            }
            return nil
        case .Section:
            let templateString = lambda(info.tag.innerTemplateString)
            let template = Template(string: templateString)
            return template?.render(info.context, error: error)
        }
    }
}

/**
TODO: doc & tests
*/
public func Lambda(lambda: () -> String) -> RenderFunction {
    return { (info: RenderingInfo, error: NSErrorPointer) in
        switch info.tag.type {
        case .Variable:
            let templateString = lambda()
            let template = Template(string: templateString)
            return template?.render(info.context, error: error)
        case .Section:
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Section lambda used in a variable tag."])
            }
            return nil
        }
    }
}


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
    
      let render: RenderFunction = { (info: RenderingInfo, _) -> Rendering? in
          return Rendering("foo")
      }
    
      // Renders "foo"
      let template = Template(string: "{{object}}")!
      let data = ["object": Box(render)]
      template.render(Box(data))!
    
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
You will meet RenderingInfo when you implement custom rendering functions of
type RenderFunction.

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
    
    
    // Not public
    //
    // If true, the rendering is part of an enumeration. Some values don't
    // render the same whenever they render as an enumeration item, or alone:
    // {{# values }}...{{/ values }} vs. {{# value }}...{{/ value }}.
    //
    // This is the case of Int, UInt, Double, Bool: they enter the context
    // stack when used in an iteration, and do not enter the context stack when
    // used as a boolean.
    //
    // This is also the case of collections: they enter the context stack when
    // used as an item of a collection, and enumerate their items when used as
    // a collection.
    var enumerationItem: Bool
}


// =============================================================================
// MARK: - WillRenderFunction

/**
Once a WillRenderFunction has entered the context stack, it is called just
before tags are about to render, and has the opportunity to replace the value
they are about to render.

::

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

WillRender functions don't have to enter the base context of a template to
perform: they can enter the context stack just like any other value, by being
attached to a section. In this case, they are only notified of tags inside that
section.

::

  let template = Template(string: "{{# user }}{{ firstName }} {{# spy }}{{ lastName }}{{/ spy }}{{/ user }}")!
  
  // Prints:
  // {{ lastName }} at line 1 will render Flynn
  let data = [
      "user": Box(["firstName": "Errol", "lastName": "Flynn"]),
      "spy": Box(willRender)
  ]
  template.render(Box(data))!

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
  template.render(Box(data))!

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

::

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


