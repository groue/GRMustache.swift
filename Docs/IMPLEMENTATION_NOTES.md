Anatomy of GRMustache.swift
===========================

This page describes the internal guts of the library.

There are a lot of types in GRMustache.swift. Each one has its own tiny role. Let's use the following code to illustrate all of them:

```swift
// Render "Hello Arthur"
let template = Template(string: "Hello {{name}}")!
let data = ["name": "Arthur"]
let rendering = template.render(data)!
```


From the beginning:


```swift
let template = Template(string: "Hello {{name}}")!
```


## Loading the template

The `template` variable holds a [Template](Mustache/Template/Template.swift).

The Template initializer uses an internal [TemplateRepository](Mustache/Template/TemplateRepository.swift), an object that manages a collection of templates. In our specific case, this allows eventual partial tags `{{>partial}}` in the template string to be loaded from the resources of the Main Bundle. Template repositories can also be explicitly created by the library user, so that they load templates from bundle resources, file system, dictionaries of template strings, or custom containers through the [TemplateRepositoryDataSource](Mustache/Template/TemplateRepository.swift) protocol.

## Parsing

The template repository instantiates and configures a [TemplateParser](Mustache/Parsing/TemplateParser.swift) with its own [Configuration](Mustache/Configuration/Configuration.swift). The configuration provides the "tag delimiters". Default ones are `{{` and `}}`.

The parser emits [TemplateToken](Mustache/Parsing/TemplateToken.swift). In our case, one "text" token, and one "escaped variable tag" token.

## Compiling

The tokens are consumed by a [TemplateCompiler](Mustache/Compiling/TemplateCompiler.swift) which, in turn, builds a [TemplateAST](Mustache/Compiling/TemplateAST/TemplateAST.swift). The [Abstract Syntax Tree](http://en.wikipedia.org/wiki/Abstract_syntax_tree) is a recursive data structure which holds a collection of [TemplateASTNode](Mustache/Compiling/TemplateAST/TemplateASTNode.swift), some of them containing another sub-AST.

Nodes for section and variable tags (`{{#name}}...{{/name}}` and `{{name}}`) hold an [Expression](Mustache/Compiling/Expression/Expression.swift) that will be evaluated against the data provided by the user, during the template rendering. Strings like `name` or `uppercase(person.name)` are turned into expressions by [ExpressionParser](Mustache/Parsing/ExpressionParser.swift).

The three types Expression, TemplateAST and TemplateASTNode are 100% passive data structures.


---

```swift
let data = ["name": "Arthur"]
let box = Box(data)
```

Templates do not eat raw values. They eat boxed values.

## MustacheBox

The [Box() function](Mustache/Rendering/Box.swift) turn a value whose type is known at compile time into a [MustacheBox](Mustache/Rendering/MustacheBox.swift) that encapsulates a set of dynamic behaviors against the Mustache engine. Depending on how a box is used, one facet or another will be activated by the engine:

- `{{ name }}`: the *key extraction* facet of the current box is used, so that the key "name" gets turned into the value that gets eventually rendered.
    
    Boxed dictionaries, collections, strings, [Key-Value Coding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) compliant objects, etc. have their own key extraction facet.
    
    Key extraction is provided through the [KeyedSubscriptFunction](Mustache/Rendering/CoreFunctions.swift) type.

- `{{ name }}`: the *rendering* facet of the extracted box is invoked, so that it... renders.

    Boxed booleans, strings, numbers, collections, user lambdas, etc. have their own rendering facet.
    
    Box rendering is provided through the [RenderFunction](Mustache/Rendering/CoreFunctions.swift) type.

- `{{ f(x) }}`: the *filter* facet of `f` is invoked with the *value* facet of `x`, so that the `f(x)` expression gets evaluated.

    User filters and NSFormatter have their own filter facet.
    
    Filter facet is provided through the [FilterFunction](Mustache/Rendering/CoreFunctions.swift) type.

- `{{# value }}...{{/ value }}` and `{{^ value }}...{{/ value }}`: the *boolean* facet of the value lets the rendering engine know whether the section should render, or not.

    This facet is not exposed in public APIs. Built-in support for booleans, strings, numbers, etc. uses it.

- `{{# value }}...{{/ value }}`: the *tag observing* facet of the value is triggered for each tag inside the section.

    This (somewhat unexpected) facet lets, for example, NSDateFormatter formats all dates in a section.
    
    This facet is provided through the [WillRenderFunction and DidRenderFunction](Mustache/Rendering/CoreFunctions.swift) types.


---

```swift
let rendering = template.render(box)!
```

## Rendering

The render method creates a [RenderingEngine](Mustache/Rendering/RenderingEngine.swift) that visits the template AST: each AST node on its turn gets rendered by the rendering engine, with a special case for tags that wrap an [Expression](Mustache/Compiling/Expression/Expression.swift).

## Evaluation and Rendering of Expressions

[ExpressionInvocation](Mustache/Rendering/ExpressionInvocation.swift) evaluates a tag expression againts the [Context](Mustache/Rendering/Context.swift) stack. The context stack contains boxes that wrap the user data, and the invocation triggers the key extraction and filter facets of those boxes, until it gets the final result.

In our specific example, the only expression is `name`, and it is enough to use the key extraction facet: `Box(["name": "Arthur"])["name"] => Box("Arthur")`.

After an expression has been evaluated to a boxed value, the rendering engine invokes its rendering facet (of type [RenderFunction](Mustache/Rendering/CoreFunctions.swift)). The result of such a function is a [Rendering](Mustache/Rendering/CoreFunctions.swift) value which wraps a String and a [ContentType](Mustache/Shared/ContentType.swift), Text or HTML. The rendering engine, depending on its [Configuration](Mustache/Configuration/Configuration.swift), may have or not to escape Text renderings into HTML.
