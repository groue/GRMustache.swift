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
let value = Value([
    "name": "Chris",
    "value": 10000.0,
    "taxed_value": 10000 - (10000 * 0.4),
    "in_ca": true
])
let rendering = template.render(value)!
```


Rendering of pure Swift Objects
-------------------------------

GRMustache can render pure Swift objects, with a little help:

```swift
// Define a pure Swift object:
struct User {
    let name: String
}

// Let Mustache dig into it, using the `MustacheInspectable` protocol:
extension User: MustacheInspectable {
    func valueForMustacheKey(key: String) -> Value? {
        switch key {
        case "name":
            return Value(name)
        default:
            return nil
        }
    }
}

// Hello Arthur!
let user = User(name: "Arthur")
let template = Template(string: "Hello {{name}}!")!
let rendering = template.render(Value(user))!
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

let pluralize = { (count: Int?, renderingInfo: RenderingInfo) -> Rendering in
    
    // Pluralize the section inner content if needed:
    var string = renderingInfo.tag.innerTemplateString
    if count! > 1 {
        string = string + "s"  // naive
    }
    
    return .Success(string, .Text)
}


// Register the pluralize filter for all Mustache renderings:

Configuration.defaultConfiguration.extendBaseContextWithValue(Value(pluralize), forKey: "pluralize")


// I have 3 cats.

let template = Template(named: "example2")!
let value = Value(["cats": ["Kitty", "Pussy", "Melba"]])
let rendering = template.render(value)!
```
