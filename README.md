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
let template = MustacheTemplate(named: "template")!
let value = MustacheValue([
    "name": "Chris",
    "value": 10000.0,
    "taxed_value": 10000 - (10000 * 0.4),
    "in_ca": true
])
let rendering = template.render(value)!
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

let pluralizeFilter = { (count: Int?) -> (MustacheValue) in
    
    // This filter returns an object that performs custom rendering:
    
    return MustacheValue({ (renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
        
        // Fetch the section inner content...
        
        let string = renderingInfo.tag.innerTemplateString
        
        // ... and pluralize it if needed.
        
        if count! > 1 {
            return string + "s"  // naive
        } else {
            return string
        }
    })
}


// Register the pluralize filter for all Mustache renderings:

MustacheConfiguration.defaultConfiguration.extendBaseContextWithValue(MustacheValue(["pluralize": MustacheValue(pluralizeFilter)]))


// I have 3 cats.

let template = MustacheTemplate(named: "cats")!
let value = MustacheValue(["cats": ["Kitty", "Pussy", "Melba"]])
let rendering = template.render(value)!
```
