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
import GRMustache

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
struct User {
    let name: String
}
```

We want to let templates extract the `name` key out of a user, so that, for example, the we can render the `Hello {{name}}!` template.

Since there is no way to introspect pure Swift classes and structs, we need to help the Mustache engine finding the `name` of a User.

Helping the Mustache engine always involves "boxing" with the `Box()` function. Only values that conform to the `MustacheBoxable` protocol can be boxed:

```swift
// Allow Mustache engine to consume User values.
extension User: MustacheBoxable {
    var mustacheBox: MustacheBox {
        // Return a Box that is able to extract the `name` key of our user:
        return Box { (key: String) -> MustacheBox? in
            switch key {
            case "name":
                return Box(self.name)
            default:
                return nil
            }
        }
    }
}

// Hello Arthur!
let user = User(name: "Arthur")
let template = Template(string: "Hello {{name}}!")!
let rendering = template.render(Box(user))!
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

let pluralize = Filter { (count: Int?, info: RenderingInfo, error: NSErrorPointer) -> Rendering? in
    
    // Pluralize the inner content of the section tag:
    var string = info.tag.innerTemplateString
    if count > 1 {
        string += "s"  // naive
    }
    
    return Rendering(string)
}


// Register the pluralize filter for all Mustache renderings:

GRMustache.DefaultConfiguration.extendBaseContext(Box(["pluralize": Box(pluralizeFilter)]))


// I have 3 cats.

let template = Template(named: "example2")!
let data = ["cats": ["Kitty", "Pussy", "Melba"]]
let rendering = template.render(Box(data))!
```
