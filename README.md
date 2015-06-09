GRMustache.swift
================

GRMustache.swift is a [Mustache](http://mustache.github.io) template engine written in Swift 1.2, from the author of the Objective-C [GRMustache](https://github.com/groue/GRMustache).

It ships with built-in goodies and extensibility hooks that let you avoid the strict minimalism of the genuine Mustache language when you need it.

**June 9, 2015: GRMustache.swift 0.9.3 is out.** [Release notes](RELEASE_NOTES.md)

Get release announcements and usage tips: follow [@GRMustache on Twitter](http://twitter.com/GRMustache).

Jump to:

- [Usage](#usage)
- [Installation](#installation)
- [Documentation](#documentation)

Features
--------

- Support for the full [Mustache syntax](http://mustache.github.io/mustache.5.html)
- Filters, as `{{ uppercase(name) }}`
- Template inheritance, as in [hogan.js](http://twitter.github.com/hogan.js/), [mustache.java](https://github.com/spullara/mustache.java) and [mustache.php](https://github.com/bobthecow/mustache.php).
- Built-in [goodies](Docs/Guides/goodies.md)
- Unlike many Swift template engines, GRMustache.swift does not rely on the Objective-C runtime. It lets you feed your templates with ad-hoc values or your existing models, without forcing you to refactor your Swift code into Objective-C objects.


Requirements
------------

- iOS 7.0+ / OSX 10.9+
- Xcode 6.3


Usage
-----

`document.mustache`:

```mustache
Hello {{name}}
Your beard trimmer will arrive on {{format(date)}}.
{{#late}}
Well, on {{format(real_date)}} because of a Martian attack.
{{/late}}
```

```swift
import Mustache

let template = Template(named: "document")!

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

Installation
------------

### iOS7

To use GRMustache.swift in a project targetting iOS7, you must include the source files directly in your project.


### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Xcode projects.

To use GRMustache.swift with Cocoapods, specify in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'GRMustache.swift', '0.9.3'
```


### Carthage

[Carthage](https://github.com/Carthage/Carthage) is another dependency manager for Xcode projects.

To use GRMustache.swift with Carthage, specify in your Cartfile:

```
github "groue/GRMustache.swift" == 0.9.3
```


### Manually

Download a copy of GRMustache.swift, embed the `Mustache.xcodeproj` project in your own project, and add the `MustacheOSX` or `MustacheiOS` target as a dependency of your own target.


Documentation
-------------

Mustache is a cross-platform templating system supported by [many languages](https://github.com/mustache/mustache/wiki/Other-Mustache-implementations). This documentation does not describe the Mustache language itself. So if you are not familiar with it, **start here**: http://mustache.github.io/mustache.5.html.


### Playground & Sample Code

You'll find in the repository a `Mustache.xcworkspace` workspace that contains a Playground and demo applications.


### Reference

All public types, functions and methods of the library are documented in the source code, and available online on [cocoadocs.org](http://cocoadocs.org/docsets/GRMustache.swift/0.9.3/index.html).

The main entry points are:

- the `Template` class, documented in [Template.swift](Mustache/Template/Template.swift), which loads and renders templates ([read on cocoadocs.org](http://cocoadocs.org/docsets/GRMustache.swift/0.9.3/Classes/Template.html)):
    
    ```swift
    let template = Template(named: "template")!
    ```

- the `Box()` functions, documented in [Box.swift](Mustache/Rendering/Box.swift), which provide data to templates ([read on cocoadocs.org](http://cocoadocs.org/docsets/GRMustache.swift/0.9.3/Functions.html)):
    
    ```swift
    let data = ["mustaches": ["Charles Bronson", "Errol Flynn", "Clark Gable"]]
    let rendering = template.render(Box(data))!
    ```

- The `Configuration` type, documented in [Configuration.swift](Mustache/Configuration/Configuration.swift), which describes how to tune Mustache rendering ([read on cocoadocs.org](http://cocoadocs.org/docsets/GRMustache.swift/0.9.3/Structs/Configuration.html)):
    
    ```swift
    // Have all templates render text, and avoid HTML-escaping:
    Mustache.DefaultConfiguration.contentType = .Text
    ```

The documentation contains many examples that you can run in the Playground included in `Mustache.xcworkspace`.

We describe below a few use cases of the library:


### Errors

Not funny, but they happen. Whenever the library needs to access the file system or other system resources, you may get standard errors of domain like NSCocoaErrorDomain, etc. Mustache-specific errors are covered by the domain `GRMustacheErrorDomain`:

- Code `GRMustacheErrorCodeTemplateNotFound`:
    
    ```swift
    // No such template: `inexistent`
    var error: NSError?
    Template(named: "inexistent", error: &error)
    error!.localizedDescription
    ```
    
- Code `GRMustacheErrorCodeParseError`:
    
    ```swift
    // Parse error at line 1: Unclosed Mustache tag
    Template(string: "Hello {{name", error: &error)
    error!.localizedDescription
    ```
    
- Code `GRMustacheErrorCodeRenderingError`:
    
    ```swift
    // Error evaluating {{undefinedFilter(x)}} at line 1: Missing filter
    template = Template(string: "{{undefinedFilter(x)}}")!
    template.render(error: &error)
    error!.localizedDescription
    ```

When you render trusted valid templates with trusted valid data, you can avoid error handling: ignore the `error` argument, and use the bang `!` to force the unwrapping of templates and their renderings, as in this example:

```swift
// Assume valid parsing and rendering
template = Template(string: "{{name}} has a Mustache.")!
template.render(Box(data))!
```


### Rendering of NSObject and its subclasses

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

When extracting values from your NSObject subclasses, GRMustache.swift uses the [Key-Value Coding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) method `valueForKey:`, as long as the key is "safe" (safe keys are the names of declared properties, and the name of NSManagedObject attributes). For a full description of the rendering of NSObject, see the "Boxing of NSObject" section in [Box.swift](Mustache/Rendering/Box.swift).


### Rendering of AnyObject

Many standard APIs return values of type `AnyObject`. You get AnyObject when you deserialize JSON data, or when you extract a value out of an NSArray, for example. AnyObject can be turned into a Mustache box. However, due to constraints in the Swift language, you have to use the dedicated `BoxAnyObject()` function:

```swift
// Decode some JSON data
let data = "{ \"name\": \"Lionel Richie\" }".dataUsingEncoding(NSUTF8StringEncoding)!
let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)!

// Lionel Richie has a Mustache.
let template = Template(string: "{{ name }} has a Mustache.")!
let rendering = template.render(BoxAnyObject(json))
```


### Rendering of pure Swift values

Key-Value Coding is not available for Swift types, regardless of eventual `@objc` or `dynamic` modifiers. Swift types can still feed templates, though, with a little help.

```swift
// Define a pure Swift object:
struct Person {
    let name: String
}
```

Now we want to let Mustache templates extract the `name` key out of a person so that they can render `{{ name }}` tags.

Unlike the NSObject class, Swift types don't provide support for evaluating the `name` property given its name. We need to explicitly help the Mustache engine by conforming to the `MustacheBoxable` protocol:

```swift
extension Person : MustacheBoxable {
    
    // Here we simply feed templates with a dictionary:
    var mustacheBox: MustacheBox {
        return Box(["name": self.name])
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

For a more complete discussion, see the "Boxing of Swift types" section in [Box.swift](Mustache/Rendering/Box.swift)


### Lambdas

"Mustache lambdas" are functions that let you perform custom rendering. There are two kinds of Mustache lambdas: those that process section tags, and those that render variable tags.

Quoting the [Mustache specification](https://github.com/mustache/spec/blob/master/specs/~lambdas.yml):

> Lambdas are a special-cased data type for use in interpolations and sections.
> 
> When used as the data value for an Variable {{tag}}, the lambda MUST be treatable as an arity 0 function, and invoked as such.  The returned value MUST be rendered against the default delimiters, then interpolated in place of the lambda.
> 
> When used as the data value for a Section {{#tag}}...{{/tag}}, the lambda MUST be treatable as an arity 1 function, and invoked as such (passing a String containing the unprocessed section contents).  The returned value MUST be rendered against the current delimiters, then interpolated in place of the section.

The `Lambda` function produces spec-compliant "Mustache lambdas":

```swift
// `{{fullName}}` renders just as `{{firstName}} {{lastName}}.`
let fullName = Lambda { "{{firstName}} {{lastName}}" }

// `{{#wrapped}}...{{/wrapped}}` renders the content of the section, wrapped in
// a <b> HTML tag.
let wrapped = Lambda { (string) in "<b>\(string)</b>" }

// <b>Frank Zappa is awesome.</b>
let templateString = "{{#wrapped}}{{fullName}} is awesome.{{/wrapped}}"
let template = Template(string: templateString)!
let data = [
    "firstName": Box("Frank"),
    "lastName": Box("Zappa"),
    "fullName": Box(fullName),
    "wrapped": Box(wrapped)]
let rendering = template.render(Box(data))!
```

Those "lambdas" are a special case of custom rendering functions. The raw `RenderFunction` type gives you extra flexibility when you need to perform custom rendering. See [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift).


### Filters

**Filters process values:**

```swift
// Define the `square` filter.
//
// square(n) evaluates to the square of the provided integer.
let square = Filter { (n: Int?, _) in
    return Box(n! * n!)
}


// Register the square filter in our template:

let template = Template(string: "{{n}} × {{n}} = {{square(n)}}")!
template.registerInBaseContext("square", Box(square))


// 10 × 10 = 100

let rendering = template.render(Box(["n": 10]))!
```


**Filters can chain and generally be part of more complex expressions:**

    Circle area is {{ format(product(PI, circle.radius, circle.radius)) }} cm².


**Filters can provide special rendering of mustache sections:**

`cats.mustache`:

```mustache
I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.
```

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
template.registerInBaseContext("pluralize", Box(pluralize))


// I have 3 cats.

let data = ["cats": ["Kitty", "Pussy", "Melba"]]
let rendering = template.render(Box(data))!
```


**Filters can take several arguments:**

```swift
// Define the `sum` filter.
//
// sum(x, ...) evaluates to the sum of provided integers

let sum = VariadicFilter { (boxes: [MustacheBox], _) in
    // Extract integers out of input boxes, assuming zero for non integer values
    let integers = map(boxes) { (box) in (box.value as? Int) ?? 0 }
    let sum = reduce(integers, 0, +)
    return Box(sum)
}


// Register the sum filter in our template:

let template = Template(string: "{{a}} + {{b}} + {{c}} = {{ sum(a,b,c) }}")!
template.registerInBaseContext("sum", Box(sum))


// 1 + 2 + 3 = 6

template.render(Box(["a": 1, "b": 2, "c": 3]))!
```


Filters are documented with the `FilterFunction` type in [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift).

When you want to format values, you don't have to write your own filters: just use NSFormatter objects such as NSNumberFormatter and NSDateFormatter. [More info](Docs/Guides/goodies.md#nsformatter).


### Template inheritance

GRMustache template inheritance is compatible with [hogan.js](http://twitter.github.com/hogan.js/), [mustache.java](https://github.com/spullara/mustache.java) and [mustache.php](https://github.com/bobthecow/mustache.php).

Templates may contain *inheritable sections*. In the following `layout.mustache` template, the `page_title` and `page_content` sections may be overriden by other templates:

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

The `article.mustache` below inherits from `layout.mustache`, and overrides its sections:

`article.mustache`:

```mustache
{{< layout }}

    {{$ page_title }}{{ article.title }}{{/ page_title }}
    
    {{$ page_content }}
        {{{ article.html_body }}}
        by {{ article.author }}
    {{/ page_content }}
    
{{/ layout }}
```

When you render `article.mustache`, you get a full HTML page.


### Built-in goodies

The library ships with built-in [goodies](Docs/Guides/goodies.md) that will help you render your templates: format values, render array indexes, localize templates, etc.
