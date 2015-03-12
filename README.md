GRMustache.swift
================

GRMustache.swift is a [Mustache](http://mustache.github.io) template engine written in Swift, from the author of the Objective-C [GRMustache](https://github.com/groue/GRMustache).

It ships with built-in goodies and extensibility hooks that let you avoid the strict minimalism of the genuine Mustache language when you need it.

Get release announcements and usage tips: follow [@GRMustache on Twitter](http://twitter.com/GRMustache).


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


Usage
-----

`template.mustache`:

```mustache
Hello {{name}}
Your beard trimmer will arrive on {{format(date)}}.
{{#late}}
Well, on {{format(real_date)}} because of a Martian attack.
{{/late}}
```

```swift
import Mustache

let template = Template(named: "template")!

let dateFormatter = NSDateFormatter()
dateFormatter.dateStyle = .MediumStyle
template.registerInBaseContext("format", Box(dateFormatter))

let data = [
    "name": "Arthur",
    "date": NSDate(),
    "real_date": NSDate().dateByAddingTimeInterval(60*60*24*3),
    "late": true
]
let rendering = template.render(Box(data))!
```


Documentation
-------------

You'll find in the repository:

- a `Mustache.xcodeproj` project to be embedded in your applications so that you can import the Mustache module.
- a `Mustache.xcworkspace` workspace that contains a Playground and a demo application


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

For a full description of the rendering of NSObject, see the "Boxing of Objective-C objects" section in [MustacheBox.swift](Mustache/Rendering/MustacheBox.swift)


### Rendering of pure Swift Objects

Pure Swift types can feed templates as well, with a little help.

```swift
// Define a pure Swift object:
struct Person {
    let name: String
}
```

Now we want to let Mustache templates extract the `name` key out of a person so that they can render `{{ name }}` tags.

Since there is no way to introspect pure Swift classes and structs, we need to help the Mustache engine by conforming to the `MustacheBoxable` protocol:

```swift
// Allow Person to feed Mustache template.
extension Person : MustacheBoxable {
    var mustacheBox: MustacheBox {
        // Return a Box that wraps the person, and knows how to extract
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

For a more complete discussion, see the "Boxing of Swift types" section in [MustacheBox.swift](Mustache/Rendering/MustacheBox.swift)


### Filters

#### Filters process values:

```swift
// Define the `square` filter.
//
// square(n) evaluates to the square of the provided integer.
let square = Filter { (n: Int, _) in
    return Box(n * n)
}


// Register the square filter in our template:

let template = Template(string: "{{n}} × {{n}} = {{square(n)}}")!
template.registerInBaseContext("square", Box(square))


// 10 × 10 = 100

let rendering = template.render(Box(["n": 10]))!
```


#### Filters can take several arguments:

```swift
// Define the `sum` filter.
//
// sum(x, ...) evaluates to the sum of provided integers

let sum = VariadicFilter { (boxes: [MustacheBox], _) in
    // Extract integers out of input boxes, assuming zero for non numeric values
    let integers = map(boxes) { $0.intValue ?? 0 }
    
    // Compute and box the sum
    return Box(integers.reduce(0,+))
}


// Register the sum filter in our template:

let template = Template(string: "{{a}} + {{b}} + {{c}} = {{ sum(a,b,c) }}")!
template.registerInBaseContext("sum", Box(sum))


// 1 + 2 + 3 = 6

template.render(Box(["a": 1, "b": 2, "c": 3]))!
```


#### Filters can chain and generally be part of more complex expressions:

    Circle area is {{ format(product(PI, circle.radius, circle.radius)) }} cm².


#### Filters can provide special rendering of mustache sections:

`cats.mustache`:

```mustache
I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.
```

```swift
// Define the `pluralize` filter.
//
// {{# pluralize(count) }}...{{/ }} renders the plural form of the
// section content if the `count` argument is greater than 1.

let pluralize = Filter { (count: Int, info: RenderingInfo, _) in
    
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


// I have 3 cats.

let data = ["cats": ["Kitty", "Pussy", "Melba"]]
let rendering = template.render(Box(data))!
```

Filters are documented with the `FilterFunction` type in [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift).

When you want to format values, you don't have to write your own filters: just use NSFormatter objects such as NSNumberFormatter and NSDateFormatter. [More info](Docs/Guides/goodies.md#nsformatter).


#### Filters can validate their arguments and return errors:

```swift
// Define the `squareRoot` filter.
//
// squareRoot(x) evaluates to the square root of the provided double, and
// returns an error for negative values.
let squareRoot = Filter { (x: Double, error: NSErrorPointer) in
    if x < 0 {
        if error != nil {
            error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "Invalid negative value"])
        }
        return nil
    } else {
        return Box(sqrt(x))
    }
}


// Register the squareRoot filter in our template:

let template = Template(string: "√{{x}} = {{squareRoot(x)}}")!
template.registerInBaseContext("squareRoot", Box(squareRoot))


// √100 = 10.0

let rendering = template.render(Box(["x": 100]))!


// Error evaluating {{squareRoot(x)}} at line 1: Invalid negative value

var error: NSError?
template.render(Box(["x": -1]), error: &error)
error!.localizedDescription
```


### Lambdas

"Mustache lambdas" are functions that let you perform custom rendering. For example, here is a lambda that wraps a section into a HTML tag:

```swift
let lambda: RenderFunction = { (info: RenderingInfo, _) in
    let innerContent = info.tag.renderInnerContent(info.context)!.string
    return Rendering("<b>\(innerContent)</b>", .HTML)
}

// <b>Willy is awesome.</b>

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

```mustache
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
```

Other templates can inherit from `layout.mustache`, and override its sections:

`article.mustache`:

```mustache
{{< layout }}

    {{$ page_title }}{{ article.title }}{{/ page_title }}
    
    {{$ page_content }}
        {{# article }}
            {{ body }}
            by {{ author }}
        {{/ article }}
    {{/ page_content }}
    
{{/ layout }}
```

When you render `article.mustache`, you get a full HTML page.


### Built-in goodies

The library ships with built-in [goodies](Docs/Guides/goodies.md) that will help you render your templates: format values, render array indexes, localize templates, etc.
