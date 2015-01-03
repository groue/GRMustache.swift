GRMustache.swift
================

GRMustache.swift is an implementation of [Mustache templates](http://mustache.github.io) in Swift.

Its APIs are similar to the Objective-C version [GRMustache](https://github.com/groue/GRMustache).

**The code is currently of alpha quality, and the API is not stabilized yet.**

`template.mustache`:

    Hello {{name}}
    You have just won {{value}} dollars!
    {{#in_ca}}
    Well, {{taxed_value}} dollars, after taxes.
    {{/in_ca}}

```swift
let template = Template(named: "template")!
let data = [
    "name": "Chris",
    "value": 10000.0,
    "taxed_value": 10000 - (10000 * 0.4),
    "in_ca": true
]
let rendering = template.render(Box(data))!
```


Rendering of pure Swift Objects
-------------------------------

GRMustache can render pure Swift objects, with a little help:

```swift
// Define a pure Swift object:
struct User {
    let name: String
}

// There are many ways for a value to contribute to Mustache rendering, and it
// always requires "boxing", through the `MustacheBoxable` protocol.
//
// Here we only want to let templates extract the `name` key out of our users.
extension User: MustacheBoxable {
    func mustacheBox() -> Box {
        // What we box is a function that turns Strings into boxed values:
        return Box({ (key: String) -> Box? in
            switch key {
            case "name":
                return Box(self.name)
            default:
                return nil
            }
        })
    }
}

// Hello Arthur!
let user = User(name: "Arthur")
let template = Template(string: "Hello {{name}}!")!
let rendering = template.render(Box(user))!
```


Mustache, and beyond
--------------------

Forget the strict minimalism of the genuine Mustache language: GRMustache ships with built-in goodies and extensibility hooks that won't let you down.

`cats.mustache`:

    I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.

```swift
// Define the `pluralize` filter.
//
// {{# pluralize(count) }}...{{/ }} renders the plural form of the
// section content if the `count` argument is greater than 1.

let pluralize = MakeFilter({ (count: Int?, info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
    
    // Pluralize the section inner content if needed:
    var string = info.tag.innerTemplateString
    if count > 1 {
        string = string + "s"  // naive
    }
    
    return Rendering(string)
}


// Register the pluralize filter for all Mustache renderings:

Configuration.defaultConfiguration.extendBaseContext(Box(["pluralize": Box(pluralize)]))


// I have 3 cats.

let template = Template(named: "example2")!
let box = Box(["cats": ["Kitty", "Pussy", "Melba"]])
let rendering = template.render(box)!
```
