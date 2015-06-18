GRMustache.swift
================

GRMustache.swift is a [Mustache](http://mustache.github.io) template engine written in Swift 2, from the author of the Objective-C [GRMustache](https://github.com/groue/GRMustache).

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
- Xcode 7


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

// Load the `document.mustache` resource of the main bundle
let template = try! Template(named: "document")

// Let template format dates with `{{format(...)}}`
let dateFormatter = NSDateFormatter()
dateFormatter.dateStyle = .MediumStyle
template.registerInBaseContext("format", Box(dateFormatter))

// The rendered data
let data = [
    "name": "Arthur",
    "date": NSDate(),
    "real_date": NSDate().dateByAddingTimeInterval(60*60*24*3),
    "late": true
]

// The rendering: "Hello Arthur..."
let rendering = try! template.render(Box(data))
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
=============

To fiddle with the library, open the `Mustache.xcworkspace` workspace: it contains a Mustache-enabled Playground at the top of the files list.

External links:

- [The Mustache Language](http://mustache.github.io/mustache.5.html): the Mustache language itself. You should start here.
- [GRMustache.swift Reference](http://cocoadocs.org/docsets/GRMustache.swift/0.9.3/Classes/Template.html) on cocoadocs.org

Rendering templates:

- [Templates](#templates)

Feeding templates:

- [Rendering of Standard Swift Types](#rendering-of-standard-swift-types)
- [Rendering of Custom Types](#rendering-of-custom-types)
- [Lambdas](#lambdas)
- [Filters](#filters)

Misc:

- [Template inheritance](#template-inheritance)
- [Errors](#errors)
- [Built-in goodies](#built-in-goodies)


Templates
---------

Generally speaking, rendering Mustache templates is a three step process:

```swift
// 1. Load a template
let template = try! Template(named: "profile")

// 2. Prepare the data that feeds the template:
let profile = ...

// 3. Render:
let rendering = try! template.render(Box(profile))
```

A template is defined by a string such as `Hello {{name}}`. Those strings may come from various sources:

- Raw Swift strings:

    ```swift
    let template = try! Template(string: "Hello {{name}}")
    ```

- Bundle resources:

    ```swift
    // Loads the "document.mustache" resource of the main bundle:
    let template = try! Template(named: "document")
    ```

- Files and URLs:

    ```swift
    let template = try! Template(path: "/path/to/document.mustache")
    let template = try! Template(URL: templateURL)
    ```

- A *repository of templates*:
    
    These repositories represent a group of templates. They can be configured independently, and provide a few neat features like template caching. Check [TemplateRepository.swift](Mustache/Template/TemplateRepository.swift) ([read on cocoadocs.org](http://cocoadocs.org/docsets/GRMustache.swift/0.9.3/Classes/TemplateRepository.html)). For example:
    
    ```swift
    // The repository of Bash templates, with extension ".sh":
    let repo = TemplateRepository(bundle: NSBundle.mainBundle(), templateExtension: "sh")
    
    // Disable HTML escaping for Bash scripts:
    repo.configuration.contentType = .Text
    
    // Load a template:
    let template = try! repo.template(named: "script")
    ```

For more information, check [Template.swift](Mustache/Template/Template.swift) ([read on cocoadocs.org](http://cocoadocs.org/docsets/GRMustache.swift/0.9.3/Classes/Template.html)).


Rendering of Standard Swift Types
---------------------------------

GRMustache.swift comes with built-in support for the following standard Swift types:


### Bool

- `{{bool}}` renders "0" or "1".
- `{{#bool}}...{{/bool}}` renders if and only if *bool* is true.
- `{{^bool}}...{{/bool}}` renders if and only if *bool* is false.


### Numeric types

GRMustache supports Int, UInt and Double:

**Int**

- `{{int}}` renders the standard Swift string interpolation of *int*.
- `{{#int}}...{{/int}}` renders if and only if *int* is not 0 (zero).
- `{{^int}}...{{/int}}` renders if and only if *int* is 0 (zero).

**UInt**

- `{{uint}}` renders the standard Swift string interpolation of *uint*.
- `{{#uint}}...{{/uint}}` renders if and only if *uint* is not 0 (zero).
- `{{^uint}}...{{/uint}}` renders if and only if *uint* is 0 (zero).

**Double**

- `{{double}}` renders the standard Swift string interpolation of *double*.
- `{{#double}}...{{/double}}` renders if and only if *double* is not 0.0 (zero).
- `{{^double}}...{{/double}}` renders if and only if *double* is 0.0 (zero).

To format numbers, use `NSNumberFormatter`:

```swift
let percentFormatter = NSNumberFormatter()
percentFormatter.numberStyle = .PercentStyle

let template = try! Template(string: "{{ percent(x) }}")
template.registerInBaseContext("percent", Box(percentFormatter))

// Rendering: 50%
let data = ["x": 0.5]
let rendering = try! template.render(Box(data))
```

[More info on NSFormatter](Docs/Guides/goodies.md#nsformatter).


### String

- `{{string}}` renders *string*, HTML-escaped.
- `{{{string}}}` renders *string*, not HTML-escaped.
- `{{#string}}...{{/string}}` renders if and only if *string* is not empty.
- `{{^string}}...{{/string}}` renders if and only if *string* is empty.

Exposed keys:

- `string.length`: the length of the string.


### Set

A set can be rendered as long as its elements are boxable.

- `{{set}}` renders the concatenation of the renderings of set elements.
- `{{#set}}...{{/set}}` renders as many times as there are elements in the set, pushing them on top of the context stack.
- `{{^set}}...{{/set}}` renders if and only if the set is empty.

Exposed keys:

- `set.first`: the first element.
- `set.count`: the number of elements in the set.

GRMustache.swift renders as `Set` all types conforming to `CollectionType where Generator.Element: MustacheBoxable, Index.Distance == Int`. This is the minimal type which allows iteration, access to the first element, and to the elements count.


### Array

An array can be rendered as long as its elements are boxable.

- `{{array}}` renders the concatenation of the renderings of array elements.
- `{{#array}}...{{/array}}` renders as many times as there are elements in the array, pushing them on top of the context stack.
- `{{^array}}...{{/array}}` renders if and only if the array is empty.

Exposed keys:

- `array.first`: the first element.
- `array.last`: the last element.
- `array.count`: the number of elements in the array.

GRMustache.swift renders as `Array` all types conforming to `CollectionType where Generator.Element: MustacheBoxable, Index: BidirectionalIndexType, Index.Distance == Int`. This is the minimal type which allows iteration, access to the first element, last element, and to the elements count.


### Dictionary

A dictionary can be rendered as long as its keys are String, and its values are boxable.

- `{{dictionary}}` renders the standard Swift string interpolation of *dictionary*.
- `{{#dictionary}}...{{/dictionary}}` renders once, pushing the dictionary on top of the context stack.
- `{{^dictionary}}...`{{/dictionary}}` does not render.


### NSObject conforming to NSFastEnumeration

The most common one is NSArray. Those objects render just like Swift Array.

There are two exceptions: NSSet is rendered as a Swift Set, and NSDictionary, as a Swift dictionary.


### NSNull

- `{{null}}` does not render.
- `{{#null}}...{{/null}}` does not render.
- `{{^null}}...{{/null}}` renders.


### NSNumber

NSNumber is rendered as a Swift Bool, Int, or UInt, depending on its value.


### NSString

NSString is rendered as String


### NSObject (other classes)

- `{{object}}` renders the `description` method, HTML-escaped.
- `{{{object}}}` renders the `description` method, not HTML-escaped.
- `{{#object}}...{{/object}}` renders once, pushing the object on top of the context stack.
- `{{^object}}...{{/object}}` does not render.

NSObject exposes all its properties to the templates.


### AnyObject and Any

When you try to render a value of type `Any` or `AnyObject`, you get a compiler error:

```swift
let any: Any = ...
let anyObject: AnyObject = ...

let rendering = try! template.render(Box(any))
// Compiler Error

let rendering = try! template.render(Box(anyObject))
// Compiler Error
```

The solution is to convert the value to its actual type:

```swift
let json: AnyObject = ["name": "Lionel Richie"]

// Convert to Dictionary:
let dictionary = json as! [String: String]

// Lionel Richie has a Mustache.
let template = try! Template(string: "{{ name }} has a Mustache.")
let rendering = try! template.render(Box(dictionary))
```


Rendering of Custom Types
-------------------------

### NSObject subclasses

You NSObject subclass can trivially feed your templates:

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
let template = try! Template(string: "{{name}} has a mustache.")
let rendering = try! template.render(Box(person))
```

When extracting values from your NSObject subclasses, GRMustache.swift uses the [Key-Value Coding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) method `valueForKey:`, as long as the key is "safe" (safe keys are the names of declared properties, and the name of NSManagedObject attributes). For a full description of the rendering of NSObject, see the documentation of `NSObject.mustacheBox` in [Box.swift](Mustache/Rendering/Box.swift).


### Pure Swift Values

Key-Value Coding is not available for Swift enums, structs and classes, regardless of eventual `@objc` or `dynamic` modifiers. Swift values can still feed templates, though, with a little help.

```swift
// Define a pure Swift object:
struct Person {
    let name: String
}
```

To let Mustache templates extract the `name` key out of a person so that they can render `{{ name }}` tags, we need to explicitly help the Mustache engine by conforming to the `MustacheBoxable` protocol:

```swift
extension Person : MustacheBoxable {
    
    // Here we simply feed templates with a dictionary:
    var mustacheBox: MustacheBox {
        return Box(["name": self.name])
    }
}
```

Now we can box and render users, arrays of users, dictionaries of users, etc:

```swift
// Freddy Mercury has a mustache.
let person = Person(name: "Freddy Mercury")
let template = try! Template(string: "{{name}} has a mustache.")
let rendering = try! template.render(Box(person))
```

For a more complete discussion, check the documentation of `MustacheBoxable` in [Box.swift](Mustache/Rendering/Box.swift).


Lambdas
-------

"Mustache lambdas" are functions that let you perform custom rendering. There are two kinds of Mustache lambdas: those that process section tags, and those that render variable tags.

```swift
// `{{fullName}}` renders just as `{{firstName}} {{lastName}}.`
let fullName = Lambda { "{{firstName}} {{lastName}}" }

// `{{#wrapped}}...{{/wrapped}}` renders the content of the section, wrapped in
// a <b> HTML tag.
let wrapped = Lambda { (string) in "<b>\(string)</b>" }

// <b>Frank Zappa is awesome.</b>
let templateString = "{{#wrapped}}{{fullName}} is awesome.{{/wrapped}}"
let template = try! Template(string: templateString)
let data = [
    "firstName": Box("Frank"),
    "lastName": Box("Zappa"),
    "fullName": Box(fullName),
    "wrapped": Box(wrapped)]
let rendering = try! template.render(Box(data))
```

Those "lambdas" are a special case of custom rendering functions. The raw `RenderFunction` type gives you extra flexibility when you need to perform custom rendering. See [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift).


Filters
-------

Filters apply like functions, with parentheses: `{{ uppercase(name) }}`.

Generally speaking, using filters is a three-step process:

```swift
// 1. Define the filter using the `Filter()` function:
let uppercase = Filter(...)

// 2. Assign a name to your filter, and register it in a template:
template.registerInBaseContext("uppercase", Box(uppercase))

// 3. Render
template.render(...)
```

It helps thinking about four kinds of filters:

- [Value filters](#value-filters), as in `{{ square(radius) }}`
- [Pre-rendering filters](#pre-rendering-filters), as in `{{ uppercase(...) }}`
- [Custom rendering filters](#custom-rendering-filters), as in `{{# pluralize(cats.count) }}cat{{/}}`
- [Advanced filters](#advanced-filters)


### Value Filters

Value filters transform any type of input. They can return anything as well.

For example, here is a `square` filter which squares integers:

```swift
// Define the `square` filter.
//
// square(n) evaluates to the square of the provided integer.
let square = Filter { (n: Int?) in
    guard let n = n else {
        // No value, or not an integer: return the empty box.
        // We could throw an error as well.
        return Box()
    }
    
    // Results are returned boxed, as always:
    return Box(n * n)
}

// Register the square filter in our template:
let template = try! Template(string: "{{n}} × {{n}} = {{square(n)}}")
template.registerInBaseContext("square", Box(square))

// 10 × 10 = 100
let rendering = try! template.render(Box(["n": 10]))
```


Filters can accept a precisely typed argument as above. You may prefer managing the value type yourself:

```swift
// Define the `abs` filter.
//
// abs(x) evaluates to the absolute value of x (Int, UInt or Double):
let absFilter = Filter { (box: MustacheBox) in
    switch box.value {
    case let int as Int:
        return Box(abs(int))
    case let uint as UInt:
        return Box(uint)
    case let double as Double:
        return Box(abs(double))
    default:
        // GRMustache does not support any other numeric types: give up.
        return Box()
    }
}
```


You can process collections and dictionaries as well, and return new ones:

```swift
// Define the `oneEveryTwoItems` filter.
//
// oneEveryTwoItems(collection) returns the array of even items in the input
// collection.
let oneEveryTwoItems = Filter { (box: MustacheBox) in
    // `box.arrayValue` returns a `Array<MustacheBox>` whatever the boxed Swift
    // or Foundation collection (Array, Set, NSOrderedSet, etc.).
    guard let boxes = box.arrayValue else {
        // No value, or not a collection: return the empty box
        return Box()
    }
    
    // Rebuild another array with even indexes:
    var result: [MustacheBox] = []
    for case let (index, box) in boxes.enumerate() where index % 2 == 0 {
        result.append(box)
    }
    
    return Box(result)
}

// A template where the filter is used in a section, so that the items in the
// filtered array are iterated:
let templateString = "{{# oneEveryTwoItems(items) }}<{{.}}>{{/ oneEveryTwoItems(items) }}"
let template = try! Template(string: templateString)

// Register the oneEveryTwoItems filter in our template:
template.registerInBaseContext("oneEveryTwoItems", Box(oneEveryTwoItems))

// <1><3><5><7><9>
let rendering = try! template.render(Box(["items": Box(1..<10)]))
```


Multi-arguments filters are OK as well. but you use the `VariadicFilter()` function, this time:

```swift
// Define the `sum` filter.
//
// sum(x, ...) evaluates to the sum of provided integers
let sum = VariadicFilter { (boxes: [MustacheBox]) in
    var sum = 0
    for box in boxes {
        sum += (box.value as? Int) ?? 0
    }
    return Box(sum)
}

// Register the sum filter in our template:
let template = try! Template(string: "{{a}} + {{b}} + {{c}} = {{ sum(a,b,c) }}")
template.registerInBaseContext("sum", Box(sum))

// 1 + 2 + 3 = 6
let rendering = try! template.render(Box(["a": 1, "b": 2, "c": 3]))
```


Filters can chain and generally be part of more complex expressions:

    Circle area is {{ format(product(PI, circle.radius, circle.radius)) }} cm².


When you want to format values, just use NSNumberFormatter, NSDateFormatter, or any NSFormatter. They are ready-made filters:

```swift
let percentFormatter = NSNumberFormatter()
percentFormatter.numberStyle = .PercentStyle

let template = try! Template(string: "{{ percent(x) }}")
template.registerInBaseContext("percent", Box(percentFormatter))

// Rendering: 50%
let data = ["x": 0.5]
let rendering = try! template.render(Box(data))
```

[More info on NSFormatter](Docs/Guides/goodies.md#nsformatter).


### Pre-Rendering Filters

Value filters as seen above process input values, which may be of any type (bools, ints, collections, etc.). Pre-rendering filters always process strings, whatever the input value. They have the opportunity to alter those strings before they get actually included in the final template rendering.

You can, for example, reverse a rendering:

```swift
// Define the `reverse` filter.
//
// reverse(x) renders the reversed rendering of its argument:
let reverse = Filter { (rendering: Rendering) in
    let reversedString = String(rendering.string.characters.reverse())
    return Rendering(reversedString, rendering.contentType)
}

// Register the reverse filter in our template:
let template = try! Template(string: "{{reverse(value)}}")
template.registerInBaseContext("reverse", Box(reverse))

// ohcuorG
try! template.render(Box(["value": "Groucho"]))

// 321
try! template.render(Box(["value": 123]))
```

Such filter does not quite process a raw string, as you have seen. It processes a `Rendering`, which is a flavored string, a string with its contentType (text or HTML).

This rendering will usually be text: simple values (ints, strings, etc.) render as text. Our `reverse` filter preserves this content-type, and does not mangle HTML entities:

```swift
// &gt;lmth&lt;
try! template.render(Box(["value": "<html>"]))
```


### Custom Rendering Filters

An example will show how they can be used:

```swift
// Define the `pluralize` filter.
//
// {{# pluralize(count) }}...{{/ }} renders the plural form of the
// section content if the `count` argument is greater than 1.
let pluralize = Filter { (count: Int?, info: RenderingInfo) in
    
    // The inner content of the section tag:
    var string = info.tag.innerTemplateString
    
    // Pluralize if needed:
    if count > 1 {
        string += "s"  // naive
    }
    
    return Rendering(string)
}

// Register the pluralize filter in our template:
let templateString = "I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}."
let template = try! Template(string: templateString)
template.registerInBaseContext("pluralize", Box(pluralize))

// I have 3 cats.
let data = ["cats": ["Kitty", "Pussy", "Melba"]]
let rendering = try! template.render(Box(data))
```

As those filters perform custom rendering, they are based on `RenderFunction`, just like lambdas. Check the `RenderFunction` type in [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift) for more information about the `RenderingInfo` and `Rendering` types.


### Advanced Filters

All the filters seen above are particular cases of `FilterFunction`. "Value filters", "Pre-rendering filters" and "Custom rendering filters" are common use cases that are granted with specific APIs.

Yet the library ships with a few built-in filters that don't quite fit any of those categories. Go check their [documentation](Docs/Guides/goodies.md). And since they are all written with public GRMustache.swift APIs, check also their [source code](Mustache/Goodies), for inspiration. The general `FilterFunction` itself is detailed in [CoreFunctions.swift](Mustache/Rendering/CoreFunctions.swift).



Template inheritance
--------------------

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


Errors
------

Not funny, but they happen. Standard NSErrors of domain NSCocoaErrorDomain, etc. may be thrown whenever the library needs to access the file system or other system resource. Mustache-specific errors are NSErrors of domain `GRMustacheErrorDomain`:

- Code `GRMustacheErrorCodeTemplateNotFound`:
    
    ```swift
    do {
        let template = try Template(named: "inexistant")
    } catch {
        // No such template: `inexistant`
    }
    ```
    
- Code `GRMustacheErrorCodeParseError`:
    
    ```swift
    do {
        let template = try Template(string: "Hello {{name")
    } catch {
        // Parse error at line 1: Unclosed Mustache tag
    }
    ```
    
- Code `GRMustacheErrorCodeRenderingError`:
    
    ```swift
    do {
        let template = try Template(string: "{{undefinedFilter(x)}}")
        let rendering = try template.render()
    } catch {
        // Error evaluating {{undefinedFilter(x)}} at line 1: Missing filter
    }
    ```

When you render trusted valid templates with trusted valid data, you can avoid error handling with the `try!` Swift construct:

```swift
// Assume valid parsing and rendering
let template = try! Template(string: "{{name}} has a Mustache.")
let rendering = try! template.render(Box(data))
```


Built-in goodies
----------------

The library ships with built-in [goodies](Docs/Guides/goodies.md) that will help you render your templates: format values, render array indexes, localize templates, etc.
