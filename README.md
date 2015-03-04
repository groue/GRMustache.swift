GRMustache.swift
================

GRMustache.swift is a [Mustache](http://mustache.github.io) template engine written in Swift, from the author of the Objective-C [GRMustache](https://github.com/groue/GRMustache).


Features
--------

- Support for the full [Mustache syntax](http://mustache.github.io/mustache.5.html)
- Ability to render Swift values as well as Objective-C objects
- Filters, as `{{ uppercase(name) }}`
- Template inheritance, as in [hogan.js](http://twitter.github.com/hogan.js/), [mustache.java](https://github.com/spullara/mustache.java) and [mustache.php](https://github.com/bobthecow/mustache.php).
- Built-in [goodies](Docs/Guides/goodies.md)


Requirements
------------

- iOS 7.0+ / OSX 10.9+
- Xcode 6.1


How to
------

You'll find in the repository:

- a `Mustache.xcodeproj` project to be embedded in your applications
- a `Mustache.xcworkspace` workspace that contains a Playground and a demo application


Usage
-----

`template.mustache`:

    Hello {{name}}
    You have just won {{value}} dollars!
    {{#in_ca}}
    Well, {{taxed_value}} dollars, after taxes.
    {{/in_ca}}

```swift
import Mustache

let template = Template(named: "template")!
let data = [
    "name": "Chris",
    "value": 10000,
    "taxed_value": 10000 - (10000 * 0.4),
    "in_ca": true]
let rendering = template.render(Box(data))!
```


Documentation
-------------

All public types, functions and methods of the library are documented in the source code.

The main entry points are:

- the `Template` class, documented in [Template.swift](Mustache/Template/Template.swift), which loads and renders templates:
    
    ```swift
    let template = Template(named: "template")!
    ```

- the `Box()` functions, documented in [MustacheBox.swift](Mustache/Rendering/MustacheBox.swift), which provide data to templates:
    
    ```swift
    let data = ["mustaches": ["Charles Bronson", "Errol Flynn", "Clark Gable"]]
    let rendering = template.render(Box(data))!
    ```

- The `Configuration` type, documented in [Configuration.swift](Mustache/Configuration/Configuration.swift), which describes how to tune Mustache rendering:
    
    ```swift
    // Have all templates render text, and avoid HTML-escaping:
    Mustache.DefaultConfiguration.contentType = .Text
    ```

The documentation contains many examples that you can run in the Playground included in `Mustache.xcworkspace`.

We describe below a few use cases of the library:


### Rendering of Objective-C Objects

NSObject subclasses can trivially feed your templates:

```swift
// An NSObject subclass
class Person : NSObject {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}


// Charlie Chaplin has a mustache.
let person = Person(name: "Charlie Chaplin")
let template = Template(string: "{{name}} has a mustache.")!
let rendering = template.render(Box(person))!
```

For a full description of the rendering of NSObject, see the inline documentation of the `NSObject.mustacheBox` method in [MustacheBox.swift](Mustache/Rendering/MustacheBox.swift)


### Rendering of pure Swift Objects

Pure Swift types can feed templates as well, with a little help.

```swift
// Define a pure Swift object:
struct Person {
    let name: String
}
```

Now we want to let Mustache templates extract the `name` key out of a person so that they can render `{{ name }}` tags.

Since there is no way to introspect pure Swift classes and structs, we need to help the Mustache engine.

Helping the Mustache engine involves "boxing", through the `MustacheBoxable` protocol:

```swift
// Allow Mustache engine to consume Person values.
extension Person : MustacheBoxable {
    var mustacheBox: MustacheBox {
        // Return a Box that wraps our person, and knows how to extract
        // the `name` key:
        return Box(value: self) { (key: String) in
            switch key {
            case "name":
                return Box(self.name)
            default:
                return Box() // the empty box
            }
        }
    }
}
```

Now we can box and render a user:

```swift
// Freddy Mercury has a mustache.
let person = Person(name: "Freddy Mercury")
let template = Template(string: "{{name}} has a mustache.")!
let rendering = template.render(Box(person))!
```

For a more complete discussion, see the documentation of the `MustacheBoxable` protocol in [MustacheBox.swift](Mustache/Rendering/MustacheBox.swift)


### Filters

GRMustache filters can process values:

```swift
let square = Filter { (int: Int, _) in
    return Box(int * int)
}

let template = Template(string: "{{n}} × {{n}} = {{square(n)}}")!
template.registerInBaseContext("square", Box(square))

// Render "10 × 10 = 100"
let rendering = template.render(Box(["n": 10]))!
```


Filters can also provide special rendering of mustache sections:

`cats.mustache`:

    I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.

```swift
// Define the `pluralize` filter.
//
// {{# pluralize(count) }}...{{/ }} renders the plural form of the
// section content if the `count` argument is greater than 1.

let pluralize = Filter { (count: Int?, info: RenderingInfo, _) in
    
    // Pluralize the inner content of the section tag:
    var string = info.tag.innerTemplateString
    if count > 1 {
        string += "s"  // naive
    }
    
    return Rendering(string)
}


// Register the pluralize filter in our template:

let template = Template(named: "cats")!
template.registerInBaseContext("pluralize", Box(pluralizeFilter))


// Render "I have 3 cats."

let data = ["cats": ["Kitty", "Pussy", "Melba"]]
let rendering = template.render(Box(data))!
```

Filters are documented with the `FilterFunction` type in [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift).

When you want to format values, you don't have to write your own filters: just use NSFormatter objects such as NSNumberFormatter and NSDateFormatter. [More info](Docs/Guides/goodies.md#nsformatter).


### Lambdas

You can extend the Mustache engine with custom rendering functions. For example, here is how to wrap a section into a HTML tag:

```swift
let lambda: RenderFunction = { (info: RenderingInfo, _) in
    let innerContent = info.tag.renderInnerContent(info.context)!.string
    return Rendering("<b>\(innerContent)</b>", .HTML)
}

// Render "<b>Willy is awesome.</b>"

let template = Template(string: "{{#wrapped}}{{name}} is awesome.{{/wrapped}}")!
let data = [
    "name": Box("Willy"),
    "wrapped": Box(lambda)]
let rendering = template.render(Box(data))!
```

Custom rendering functions are documented with the `RenderFunction` type in [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift).


### Template inheritance

Templates may contain *inheritable sections*:

`layout.mustache`:

    <html>
    <head>
        <title>{{$ page_title }}Default title{{/ page_title }}</title>
    </head>
    <body>
        <h1>{{$ page_title }}Default title{{/ page_title }}</h1>
        {{$ page_content }}
            Default content
        {{/ page_content }}}
    </body>
    </html>

Other templates can inherit from `layout.mustache`, and override its sections:

`article.mustache`:

    {{< layout }}
    
        {{$ page_title }}{{ article.title }}{{/ page_title }}
        
        {{$ page_content }}
            {{# article }}
                {{ body }}
                by {{ author }}
            {{/ article }}
        {{/ page_content }}
        
    {{/ layout }}

When you render `article.mustache`, you get a full HTML page.
