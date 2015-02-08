GRMustache.swift
================

GRMustache.swift is an implementation of [Mustache templates](http://mustache.github.io) in Swift.

It is quite similar to the Objective-C [GRMustache](https://github.com/groue/GRMustache).


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
struct User {
    let name: String
}
```

We want to let the `Hello {{name}}!` template extract the `name` key out of a user.

Since there is no way to introspect pure Swift classes and structs, we need to help the Mustache engine.

Helping the Mustache engine involves "boxing", through the `MustacheBoxable` protocol:

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
```

Now we can box and render a user:

```swift
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

Mustache.DefaultConfiguration.registerInBaseContext("pluralize", Box(pluralizeFilter))


// I have 3 cats.

let template = Template(named: "cats")!
let data = ["cats": ["Kitty", "Pussy", "Melba"]]
let rendering = template.render(Box(data))!
```


Built-in goodies
----------------

GRMustache ships with a library of built-in goodies available for your templates.

**They are all built on top of public APIs**: get [inspired](Mustache/Goodies).


### NSFormatter

GRMustache provides built-in support for NSFormatter and its subclasses such as NSNumberFormatter and NSDateFormatter.

#### Formatting a value

```swift
let percentFormatter = NSNumberFormatter()
percentFormatter.numberStyle = .PercentStyle

let template = Template(string: "{{ percent(x) }}")!
template.registerInBaseContext("percent", Box(percentFormatter))

// Rendering: 50%
let data = ["x": 0.5]
let rendering = template.render(Box(data))!
```

#### Formatting all values in a section

NSFormatters are able to *format all variable tags* inside the section:

`Document.mustache`:

    {{# percent }}
    hourly: {{ hourly }}
    daily: {{ daily }}
    weekly: {{ weekly }}
    {{/ percent }}

Rendering code:

```swift
let percentFormatter = NSNumberFormatter()
percentFormatter.numberStyle = .PercentStyle

let template = Template(named: "Document")!
template.registerInBaseContext("percent", Box(percentFormatter))

// Rendering:
//
//   hourly: 10%
//   daily: 150%
//   weekly: 400%

id data = [
    "hourly": 0.1,
    "daily": 1.5,
    "weekly": 4,
};
let rendering = template.render(Box(data))!
```

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections. However, values that can't be formatted are left untouched:

`Document.mustache`:

    {{# percent }}
      {{# ingredients }}
      - {{ name }}: {{ proportion }}  {{! name is intact, proportion is formatted. }}
      {{/ ingredients }}
    {{/ percent }}

Would render:

    - bread: 50%
    - ham: 22%
    - butter: 43%

Precisely speaking, "values that can't be formatted" are the ones that have the `stringForObjectValue:` method return nil, as stated by [NSFormatter documentation](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSFormatter_Class/index.html#//apple_ref/occ/instm/NSFormatter/stringForObjectValue:).

Typically, NSNumberFormatter only formats numbers, and NSDateFormatter, dates: you can safely mix various data types in a section controlled by those well-behaved formatters.


### StandardLibrary.HTMLEscape

Usage:

```swift
Mustache.DefaultConfiguration.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
```

As a filter, `HTMLEscape` returns its argument, HTML-escaped.

```html
<pre>
   {{ HTMLEscape(content) }}
</pre>
```

When used in a section, `HTMLEscape` escapes all inner variable tags in a section:

    {{# HTMLEscape }}
      {{ firstName }}
      {{ lastName }}
    {{/ HTMLEscape }}

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections:

    {{# HTMLEscape }}
      {{# items }}
        {{ name }}
      {{/}}
    {{/ HTMLEscape }}

See also [javascriptEscape](#javascriptescape), [URLEscape](#urlescape)


### StandardLibrary.javascriptEscape

Usage:

```swift
Mustache.DefaultConfiguration.registerInBaseContext("javascriptEscape", Box(StandardLibrary.javascriptEscape))
```

As a filter, `javascriptEscape` outputs a Javascript and JSON-savvy string:

```html
<script type="text/javascript">
  var name = "{{ javascriptEscape(name) }}";
</script>
```

When used in a section, `javascriptEscape` escapes all inner variable tags in a section:

```html
<script type="text/javascript">
  {{# javascriptEscape }}
    var firstName = "{{ firstName }}";
    var lastName = "{{ lastName }}";
  {{/ javascriptEscape }}
</script>
```

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections:

```html
<script type="text/javascript">
  {{# javascriptEscape }}
    var firstName = {{# firstName }}"{{ firstName }}"{{^}}null{{/}};
    var lastName = {{# lastName }}"{{ lastName }}"{{^}}null{{/}};
  {{/ javascriptEscape }}
</script>
```

See also [HTMLEscape](#htmlescape), [URLEscape](#urlescape)


### StandardLibrary.URLEscape

Usage:

```swift
Mustache.DefaultConfiguration.registerInBaseContext("URLEscape", Box(StandardLibrary).URLEscape)
```

As a filter, `URLEscape` returns its argument, percent-escaped.

```html
<a href="http://google.com?q={{ URLEscape(query) }}">...</a>
```

When used in a section, `URLEscape` escapes all inner variable tags in a section:

```html
{{# URLEscape }}
  <a href="http://google.com?q={{query}}&amp;hl={{language}}">...</a>
{{/ URLEscape }}
```

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections:

```html
{{# URLEscape }}
  <a href="http://google.com?q={{query}}{{#language}}&amp;hl={{language}}{{/language}}">...</a>
{{/ URLEscape }}
```

See also [HTMLEscape](#htmlescape), [javascriptEscape](#javascriptescape)


### StandardLibrary.each

Usage:

```swift
Mustache.DefaultConfiguration.registerInBaseContext("each", Box(StandardLibrary.each))
```

Iteration is natural to Mustache templates: `{{# users }}{{ name }}, {{/ users }}` renders "Alice, Bob, etc." when the `users` key is given a list of users.

The `each` filter is there to give you some extra keys:

- `@index` contains the 0-based index of the item (0, 1, 2, etc.)
- `@indexPlusOne` contains the 1-based index of the item (1, 2, 3, etc.)
- `@indexIsEven` is true if the 0-based index is even.
- `@first` is true for the first item only.
- `@last` is true for the last item only.

```
One line per user:
{{# each(users) }}
- {{ @index }}: {{ name }}
{{/}}

Comma-separated user names:
{{# each(users) }}{{ name }}{{^ @last }}, {{/}}{{/}}.
```

```
One line per user:
- 0: Alice
- 1: Bob
- 2: Craig

Comma-separated user names: Alice, Bob, Craig.
```

When provided with a dictionary, `each` iterates each key/value pair of the dictionary, stores the key in `@key`, and sets the value as the current context:

```
{{# each(dictionary) }}
- {{ @key }}: {{.}}
{{/}}
```

```
- name: Alice
- score: 200
- level: 5
```

The other positional keys `@index`, `@first`, etc. are still available when iterating dictionaries.


### StandardLibrary.Localizer

Usage:

```swift
Mustache.DefaultConfiguration.registerInBaseContext("localize", Box(StandardLibrary.Localizer(bundle: nil, table: nil)))
```

#### Localizing a value

As a filter, `localize` outputs a localized string:

    {{ localize(greeting) }}

This would render `Bonjour`, given `Hello` as a greeting, and a French localization for `Hello`.

#### Localizing template content

When used in a section, `localize` outputs the localization of a full section:

    {{# localize }}Hello{{/ localize }}

This would render `Bonjour`, given a French localization for `Hello`.

#### Localizing template content with embedded variables

When looking for the localized string, GRMustache replaces all variable tags with "%@":

    {{# localize }}Hello {{name}}{{/ localize }}

This would render `Bonjour Arthur`, given a French localization for `Hello %@`. `String(format:)` is used for the final interpolation.

#### Localizing template content with embedded variables and conditions

You can embed conditional sections inside:

    {{# localize }}Hello {{#name}}{{name}}{{^}}you{{/}}{{/ localize }}

Depending on the name, this would render `Bonjour Arthur` or `Bonjour toi`, given French localizations for both `Hello %@` and `Hello you`.

