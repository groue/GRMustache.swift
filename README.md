GRMustache.swift
================

GRMustache.swift is an implementation of [Mustache templates](http://mustache.github.io) in Swift, from the author of the Objective-C [GRMustache](https://github.com/groue/GRMustache).


Features
--------

- Support for the full [Mustache syntax](http://mustache.github.io/mustache.5.html)
- Ability to render Swift values as well as Objective-C objects
- Filters, as `{{ uppercase(name) }}`
- Template inheritance
- Built-in [goodies](Guides/goodies.md)


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


Rendering of pure Swift Objects
-------------------------------

GRMustache can render pure Swift objects, with a little help.

```swift
// Define a pure Swift object:
struct Person {
    let name: String
}
```

We want to let Mustache templates extract the `{{name}}` key out of a person.

Since there is no way to introspect pure Swift classes and structs, we need to help the Mustache engine.

Helping the Mustache engine involves "boxing", through the `MustacheBoxable` protocol:

```swift
// Allow Mustache engine to consume User values.
extension User: MustacheBoxable {
    var mustacheBox: MustacheBox {
        // Return a Box that wraps our user, and knows how to extract
        // the `name` key of our user:
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


Mustache, and beyond
--------------------

GRMustache is an extensible Mustache engine.

`cats.mustache`:

    I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.

```swift
// Define the `pluralize` filter.
//
// {{# pluralize(count) }}...{{/ }} renders the plural form of the
// section content if the `count` argument is greater than 1.

let pluralize = Filter { (count: Int?, info: RenderingInfo, error: NSErrorPointer) in
    
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
