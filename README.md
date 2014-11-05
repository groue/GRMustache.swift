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
let template = MustacheTemplate(named: "template", error: nil)!
let value = MustacheValue([
    "name": "Chris",
    "value": 10000.0,
    "taxed_value": 10000 - (10000 * 0.4),
    "in_ca": true
])
let rendering = template.render(value, error: nil)!
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

let pluralizeFilter = MustacheFilterWithBlock { (count: Int?) -> (MustacheValue) in
    
    // This filter returns an object that performs custom rendering:
    
    return MustacheValue(MustacheRenderableWithBlock({ (renderingInfo: RenderingInfo, contentType: ContentTypePointer, error: NSErrorPointer) -> (String?) in
        
        // Perform the regular rendering of the section content...
        
        let rendering = renderingInfo.tag.renderContent(renderingInfo, contentType: contentType, error: error)!
        
        // ... and pluralize it if needed.
        
        if count! > 1 {
            return rendering + "s"  // naive
        } else {
            return rendering
        }
    }))
}


// Register the pluralize filter for all Mustache renderings:

MustacheConfiguration.defaultConfiguration.extendBaseContextWithValue(MustacheValue(["pluralize": MustacheValue(pluralizeFilter)]))


// Use it

let template = MustacheTemplate(named: "cats", error: nil)!
let value = MustacheValue(["cats": ["Kitty", "Pussy", "Melba"]])


// I have 3 cats.

let rendering = template.render(value, error: nil)!
```
