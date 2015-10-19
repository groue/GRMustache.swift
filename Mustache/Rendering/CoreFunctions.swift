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
    let template = try! Template(string: "{{foo}} & {{bar}}")
    let box = Box(keyedSubscript: keyedSubscript)
    try! template.render(box)


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
    
    let increment = Filter { (x: Int?) in
        return Box(x! + 1)
    }

To let a template use a filter, register it:

    let template = try! Template(string: "{{increment(x)}}")
    template.registerInBaseContext("increment", Box(increment))
    
    // "2"
    try! template.render(Box(["x": 1]))

`Filter()` can take several types of functions, depending on the type of filter
you want to build. The example above processes `Int` values. There are three
types of filters:

- Values filters:

    - `(MustacheBox) throws -> MustacheBox`
    - `(T?) throws -> MustacheBox` (Generic)
    - `([MustacheBox]) throws -> MustacheBox` (Multiple arguments)

- Pre-rendering filters:

    - `(Rendering) throws -> Rendering`

- Custom rendering filters:

    - `(MustacheBox, RenderingInfo) throws -> Rendering`
    - `(T?, RenderingInfo) throws -> Rendering` (Generic)

See the documentation of the `Filter()` functions.
*/
public typealias FilterFunction = (box: MustacheBox, partialApplication: Bool) throws -> MustacheBox


// -----------------------------------------------------------------------------
// MARK: - Values Filters

/**
Builds a filter that takes a single argument.

For example, here is the trivial `identity` filter:

    let identity = Filter { (box: MustacheBox) in
        return box
    }

    let template = try! Template(string: "{{identity(a)}}, {{identity(b)}}")
    template.registerInBaseContext("identity", Box(identity))

    // "foo, 1"
    try! template.render(Box(["a": "foo", "b": 1]))

If the template provides more than one argument, the filter returns a
MustacheError of type RenderError.

- parameter filter: A function `(MustacheBox) throws -> MustacheBox`.
- returns: A FilterFunction.
*/
public func Filter(filter: (MustacheBox) throws -> MustacheBox) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool) in
        guard !partialApplication else {
            // This is a single-argument filter: we do not wait for another one.
            throw MustacheError(kind: .RenderError, message: "Too many arguments")
        }
        return try filter(box)
    }
}

/**
Builds a filter that takes a single argument of type `T?`.

For example:

    let increment = Filter { (x: Int?) in
        return Box(x! + 1)
    }

    let template = try! Template(string: "{{increment(x)}}")
    template.registerInBaseContext("increment", Box(increment))

    // "2"
    try! template.render(Box(["x": 1]))

The argument is converted to `T` using the built-in `as?` operator before being
given to the filter.

If the template provides more than one argument, the filter returns a
MustacheError of type RenderError.

- parameter filter: A function `(T?) throws -> MustacheBox`.
- returns: A FilterFunction.
*/
public func Filter<T>(filter: (T?) throws -> MustacheBox) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool) in
        guard !partialApplication else {
            // This is a single-argument filter: we do not wait for another one.
            throw MustacheError(kind: .RenderError, message: "Too many arguments")
        }
        return try filter(box.value as? T)
    }
}

/**
Returns a filter than accepts any number of arguments.

For example:

    // `sum(x, ...)` evaluates to the sum of provided integers
    let sum = VariadicFilter { (boxes: [MustacheBox]) in
        // Extract integers out of input boxes, assuming zero for non numeric values
        let integers = boxes.map { (box) in (box.value as? Int) ?? 0 }
        let sum = integers.reduce(0, combine: +)
        return Box(sum)
    }

    let template = try! Template(string: "{{ sum(a,b,c) }}")
    template.registerInBaseContext("sum", Box(sum))

    // Renders "6"
    try! template.render(Box(["a": 1, "b": 2, "c": 3]))

- parameter filter: A function `([MustacheBox]) throws -> MustacheBox`.
- returns: A FilterFunction.
*/
public func VariadicFilter(filter: ([MustacheBox]) throws -> MustacheBox) -> FilterFunction {
    
    // f(a,b,c) is implemented as f(a)(b)(c).
    //
    // f(a) returns another filter, which returns another filter, which
    // eventually computes the final result.
    //
    // It is the partialApplication flag the tells when it's time to return the
    // final result.
    func partialFilter(filter: ([MustacheBox]) throws -> MustacheBox, arguments: [MustacheBox]) -> FilterFunction {
        return { (nextArgument: MustacheBox, partialApplication: Bool) in
            let arguments = arguments + [nextArgument]
            if partialApplication {
                // Wait for another argument
                return Box(partialFilter(filter, arguments: arguments))
            } else {
                // No more argument: compute final value
                return try filter(arguments)
            }
        }
    }
    
    return partialFilter(filter, arguments: [])
}


// -----------------------------------------------------------------------------
// MARK: - Pre-Rendering Filters

/**
Builds a filter that performs post rendering.

`Rendering` is a type that wraps a rendered String, and its content type (HTML
or Text). This filter turns a rendering in another one:

    // twice filter renders its argument twice:
    let twice = Filter { (rendering: Rendering) in
        return Rendering(rendering.string + rendering.string, rendering.contentType)
    }

    let template = try! Template(string: "{{ twice(x) }}")
    template.registerInBaseContext("twice", Box(twice))

    // Renders "foofoo", "123123"
    try! template.render(Box(["x": "foo"]))
    try! template.render(Box(["x": 123]))

When this filter is executed, eventual HTML-escaping performed by the rendering
engine has not happened yet: the rendering argument may contain raw text. This
allows you to chain pre-rendering filters without mangling HTML entities.

- parameter filter: A function `(Rendering) throws -> Rendering`.
- returns: A FilterFunction.
*/
public func Filter(filter: (Rendering) throws -> Rendering) -> FilterFunction {
    return { (box: MustacheBox, partialApplication: Bool) in
        guard !partialApplication else {
            // This is a single-argument filter: we do not wait for another one.
            throw MustacheError(kind: .RenderError, message: "Too many arguments")
        }
        // Box a RenderFunction
        return Box { (info: RenderingInfo) in
            let rendering = try box.render(info: info)
            return try filter(rendering)
        }
    }
}


// -----------------------------------------------------------------------------
// MARK: - Custom Rendering Filters

/**
Builds a filter that takes a single argument and performs custom rendering.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

For an example of such a filter, see the documentation of
`func Filter<T>(filter: (T?, RenderingInfo) throws -> Rendering) -> FilterFunction`.
This example processes `T?` instead of `MustacheBox`, but the idea is the same.

- parameter filter: A function `(MustacheBox, RenderingInfo) throws -> Rendering`.
- returns: A FilterFunction.
*/
public func Filter(filter: (MustacheBox, RenderingInfo) throws -> Rendering) -> FilterFunction {
    return Filter { (box: MustacheBox) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo) in
            return try filter(box, info)
        }
    }
}

/**
Builds a filter that takes a single argument of type `T?` and performs custom
rendering.

For example:

    // {{# pluralize(count) }}...{{/ }} renders the plural form of the section
    // content if the `count` argument is greater than 1.
    let pluralize = Filter { (count: Int?, info: RenderingInfo) in

        // Pluralize the inner content of the section tag:
        var string = info.tag.innerTemplateString
        if count > 1 {
            string += "s"  // naive pluralization
        }

        return Rendering(string)
    }

    let template = try! Template(string: "I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.")
    template.registerInBaseContext("pluralize", Box(pluralize))

    // Renders "I have 3 cats."
    let data = ["cats": ["Kitty", "Pussy", "Melba"]]
    try! template.render(Box(data))

The argument is converted to `T` using the built-in `as?` operator before being
given to the filter.

If the template provides more than one argument, the filter returns a
MustacheError of type RenderError.

See the documentation of the `RenderFunction` type for a detailed discussion of
the `RenderingInfo` and `Rendering` types.

- parameter filter: A function `(T?, RenderingInfo) throws -> Rendering`.
- returns: A FilterFunction.
*/
public func Filter<T>(filter: (T?, RenderingInfo) throws -> Rendering) -> FilterFunction {
    return Filter { (t: T?) in
        // Box a RenderFunction
        return Box { (info: RenderingInfo) in
            return try filter(t, info)
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

    let HTML: RenderFunction = { (_) in
        return Rendering("<HTML>", .HTML)
    }
    let text: RenderFunction = { (_) in
        return Rendering("<text>")   // default content type is text
    }

    // Renders "<HTML>, &lt;text&gt;"
    let template = try! Template(string: "{{HTML}}, {{text}}")
    let data = ["HTML": Box(HTML), "text": Box(text)]
    let rendering = try! template.render(Box(data))


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

- `info.tag.render: (Context) throws -> Rendering` is a
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
    let renderValue: RenderFunction = { (info: RenderingInfo) throws in
        
        // Default rendering depends on the tag type:
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
            return try info.tag.render(context)
        }
    }

    let template = try! Template(string: "{{value}}")
    let rendering = try! template.render(Box(["value": Box(renderValue)]))

- parameter info:  A RenderingInfo.
- parameter error: If there is a problem in the rendering, throws an error
                   that describes the problem.
- returns: A Rendering.
*/
public typealias RenderFunction = (info: RenderingInfo) throws -> Rendering


// -----------------------------------------------------------------------------
// MARK: - Mustache lambdas

/**
Builds a `RenderFunction` which conforms to the "lambda" defined by the
Mustache specification (see https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml).

The `lambda` parameter is a function which takes the unrendered context of a
section, and returns a String. The returned `RenderFunction` renders this string
against the current delimiters.

For example:

    let template = try! Template(string: "{{#bold}}{{name}} has a Mustache!{{/bold}}")

    let bold = Lambda { (string) in "<b>\(string)</b>" }
    let data = [
        "name": Box("Clark Gable"),
        "bold": Box(bold)]

    // Renders "<b>Clark Gable has a Mustache.</b>"
    let rendering = try! template.render(Box(data))

**Warning**: the returned String is *parsed* each time the lambda is executed.
In the example above, this is inefficient because the inner content of the
bolded section has already been parsed with its template. You may prefer the raw
`RenderFunction` type, capable of an equivalent and faster implementation:

    let bold: RenderFunction = { (info: RenderingInfo) in
        let rendering = try info.tag.render(info.context)
        return Rendering("<b>\(rendering.string)</b>", rendering.contentType)
    }
    let data = [
        "name": Box("Clark Gable"),
        "bold": Box(bold)]

    // Renders "<b>Lionel Richie has a Mustache.</b>"
    let rendering = try! template.render(Box(data))

- parameter lambda: A `String -> String` function.
- returns: A RenderFunction.
*/
public func Lambda(lambda: String -> String) -> RenderFunction {
    return { (info: RenderingInfo) in
        switch info.tag.type {
        case .Variable:
            // {{ lambda }}
            return Rendering("(Lambda)")
        case .Section:
            // {{# lambda }}...{{/ lambda }}
            //
            // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L117
            // > Lambdas used for sections should parse with the current delimiters
            
            let templateRepository = TemplateRepository()
            templateRepository.configuration.tagDelimiterPair = info.tag.tagDelimiterPair
            
            let templateString = lambda(info.tag.innerTemplateString)
            let template = try templateRepository.template(string: templateString)
            return try template.render(info.context)
            
            // IMPLEMENTATION NOTE
            //
            // This lambda implementation is unable of two things:
            //
            // - process partial tags correctly, because it uses a
            //   TemplateRepository that does not know how to load partials.
            // - honor the current content type.
            //
            // This partial problem is a tricky one to solve. A `{{>partial}}`
            // tag loads the "partial" template which is sibling of the
            // currently rendered template.
            //
            // Imagine the following template hierarchy:
            //
            // - /a.mustache: {{#lambda}}...{{/lambda}}...{{>dir/b}}
            // - /x.mustache: ...
            // - /dir/b.mustache: {{#lambda}}...{{/lambda}}
            // - /dir/x.mustache: ...
            //
            // If the lambda returns `{{>x}}` then rendering the `a.mustache`
            // template should trigger the inclusion of both `/x.mustache` and
            // `/dir/x.mustache`.
            //
            // Given the current state of GRMustache types, achieving proper
            // lambda would require:
            //
            // - a template repository
            // - a TemplateID
            // - a property `Tag.contentType`
            // - a method `TemplateRepository.template(string:contentType:tagDelimiterPair:baseTemplateID:)`
            //
            // Code would read something like:
            //
            //     let templateString = lambda(info.tag.innerTemplateString)
            //     let templateRepository = info.tag.templateRepository
            //     let templateID = info.tag.templateID
            //     let contentType = info.tag.contentType
            //     let template = try templateRepository.template(
            //         string: templateString,
            //         contentType: contentType
            //         tagDelimiterPair: info.tag.tagDelimiterPair,
            //         baseTemplateID: templateID)
            //     return try template.render(info.context)
            //
            // Should we ever implement this, beware the retain cycle between
            // tags and template repositories (which own tags through their
            // cached templateASTs).
            //
            // --------
            //
            // Lambda spec requires Lambda { ">" } to render "&gt".
            //
            // What should Lambda { "<{{>partial}}>" } render when partial
            // contains "<>"? "&lt;<>&gt;" ????
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

    let template = try! Template(string: "{{fullName}} has a Mustache.")
    
    let fullName = Lambda { "{{firstName}} {{lastName}}" }
    let data = [
        "firstName": Box("Lionel"),
        "lastName": Box("Richie"),
        "fullName": Box(fullName)]

    // Renders "Lionel Richie has a Mustache."
    let rendering = try! template.render(Box(data))

**Warning**: the returned String is *parsed* each time the lambda is executed.
In the example above, this is inefficient because the same
`"{{firstName}} {{lastName}}"` would be parsed several times. You may prefer
using a Template instead of a lambda (see the documentation of
`Template.mustacheBox` for more information):

    let fullName = try! Template(string:"{{firstName}} {{lastName}}")
    let data = [
        "firstName": Box("Lionel"),
        "lastName": Box("Richie"),
        "fullName": Box(fullName)]

    // Renders "Lionel Richie has a Mustache."
    let rendering = try! template.render(Box(data))

- parameter lambda: A `() -> String` function.
- returns: A RenderFunction.
*/
public func Lambda(lambda: () -> String) -> RenderFunction {
    return { (info: RenderingInfo) in
        switch info.tag.type {
        case .Variable:
            // {{ lambda }}
            //
            // https://github.com/mustache/spec/blob/83b0721610a4e11832e83df19c73ace3289972b9/specs/%7Elambdas.yml#L73
            // > Lambda results should be appropriately escaped
            //
            // Let's render a text template:
            
            let templateRepository = TemplateRepository()
            templateRepository.configuration.contentType = .Text
            
            let templateString = lambda()
            let template = try templateRepository.template(string: templateString)
            return try template.render(info.context)
            
            // IMPLEMENTATION NOTE
            //
            // This lambda implementation is unable to process partial tags
            // correctly: it uses a TemplateRepository that does not know how
            // to load partials.
            //
            // This problem is a tricky one to solve. The `{{>partial}}` tag
            // loads the "partial" template which is sibling of the currently
            // rendered template.
            //
            // Imagine the following template hierarchy:
            //
            // - /a.mustache: {{lambda}}...{{>dir/b}}
            // - /x.mustache: ...
            // - /dir/b.mustache: {{lambda}}
            // - /dir/x.mustache: ...
            //
            // If the lambda returns `{{>x}}` then rendering the `a.mustache`
            // template should trigger the inclusion of both `/x.mustache` and
            // `/dir/x.mustache`.
            //
            // Given the current state of GRMustache types, achieving this
            // feature would require:
            //
            // - a template repository
            // - a TemplateID
            // - a method `TemplateRepository.template(string:contentType:tagDelimiterPair:baseTemplateID:)`
            //
            // Code would read something like:
            //
            //     let templateString = lambda(info.tag.innerTemplateString)
            //     let templateRepository = info.tag.templateRepository
            //     let templateID = info.tag.templateID
            //     let template = try templateRepository.template(
            //         string: templateString,
            //         contentType: .Text,
            //         tagDelimiterPair: ("{{", "}}),
            //         baseTemplateID: templateID)
            //     return try template.render(info.context)
            //
            // Should we ever implement this, beware the retain cycle between
            // tags and template repositories (which own tags through their
            // cached templateASTs).
            //
            // --------
            //
            // Lambda spec requires Lambda { ">" } to render "&gt".
            //
            // What should Lambda { "<{{>partial}}>" } render when partial
            // contains "<>"? "&lt;<>&gt;" ????
        case .Section:
            // {{# lambda }}...{{/ lambda }}
            //
            // Behave as a true object, and render the section.
            let context = info.context.extendedContext(Box(Lambda(lambda)))
            return try info.tag.render(context)
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
    
    - parameter string:      A string.
    - parameter contentType: A content type.
    - returns: A Rendering.
    */
    public init(_ string: String, _ contentType: ContentType = .Text) {
        self.string = string
        self.contentType = contentType
    }
}

extension Rendering : CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        var contentTypeString: String
        switch contentType {
        case .HTML:
            contentTypeString = "HTML"
        case .Text:
            contentTypeString = "Text"
        }
        
        return "Rendering(\(contentTypeString):\(string.debugDescription))"
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
        print("\(tag) will render \(box.value!)")
        return box
    }

    // By entering the base context of the template, the logTags function
    // will be notified of all tags.
    let template = try! Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")
    template.extendBaseContext(Box(logTags))

    // Prints:
    // {{# user }} at line 1 will render { firstName = Errol; lastName = Flynn; }
    // {{ firstName }} at line 1 will render Errol
    // {{ lastName }} at line 1 will render Flynn
    let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
    try! template.render(Box(data))

`WillRenderFunction` don't have to enter the base context of a template to
perform: they can enter the context stack just like any other value, by being
attached to a section. In this case, they are only notified of tags inside that
section.

    let template = try! Template(string: "{{# user }}{{ firstName }} {{# spy }}{{ lastName }}{{/ spy }}{{/ user }}")

    // Prints:
    // {{ lastName }} at line 1 will render Flynn
    let data = [
        "user": Box(["firstName": "Errol", "lastName": "Flynn"]),
        "spy": Box(logTags)
    ]
    try! template.render(Box(data))
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
    let template = try! Template(string: "{{# user }}{{ firstName }} {{ lastName }}{{/ user }}")
    template.extendBaseContext(Box(logRenderings))

    // Renders "Errol Flynn"
    //
    // Prints:
    // {{ firstName }} at line 1 did render Errol as `Errol`
    // {{ lastName }} at line 1 did render Flynn as `Flynn`
    // {{# user }} at line 1 did render { firstName = Errol; lastName = Flynn; } as `Errol Flynn`
    let data = ["user": ["firstName": "Errol", "lastName": "Flynn"]]
    try! template.render(Box(data))

DidRender functions don't have to enter the base context of a template to
perform: they can enter the context stack just like any other value, by being
attached to a section. In this case, they are only notified of tags inside that
section.

    let template = try! Template(string: "{{# user }}{{ firstName }} {{# spy }}{{ lastName }}{{/ spy }}{{/ user }}")

    // Renders "Errol Flynn"
    //
    // Prints:
    // {{ lastName }} at line 1 did render Flynn as `Flynn`
    let data = [
        "user": Box(["firstName": "Errol", "lastName": "Flynn"]),
        "spy": Box(logRenderings)
    ]
    try! template.render(Box(data))

The string argument of DidRenderFunction is optional: it is nil if and only if
the tag could not render because of a rendering error.

See also:

- WillRenderFunction
*/
public typealias DidRenderFunction = (tag: Tag, box: MustacheBox, string: String?) -> Void


