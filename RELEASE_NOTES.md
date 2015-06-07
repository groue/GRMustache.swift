Release Notes
=============


## v0.9.2

**Fixed**

- The `Lambda` functions pass all [mustache/spec tests for "Mustache lambdas"](https://github.com/mustache/spec/blob/v1.1.2/specs/%7Elambdas.yml).


**New**

- `TagDelimiterPair` is a pair of tag delimiters such as `("{{","}}")`. It is the type of the properties `Configuration.tagDelimiterPair` and `Tag.tagDelimiterPair`.

- The `Template.contentType` property exposes the content type (Text or HTML) of a template.

- The Swift `Set` type now has explicit support through `func Box<T: MustacheBoxable>(set: Set<T>?) -> MustacheBox`.


**Breaking changes**

- `Template(string:error:)` used to load `{{>partial}}` tags from resources in the main bundle. It is no longer the case, and it returns a `GRMustacheErrorDomain` error of code `GRMustacheErrorCodeTemplateNotFound` if such partial tag is found. To parse a template string that contain partial tags that should be loaded from the main bundle resources, store this string as a resource and load `Template(named:...)`, or use an explicit `TemplateRepository(bundle: NSBundle.mainBundle())`.

- `Configuration.tagStartDelimiter` and `Configuration.tagEndDelimiter` have been replaced by `Configuration.tagDelimiterPair`.

- `Tag.renderInnerContent` has been renamed `Tag.render`.


## v0.9.1

Released on 19 May, 2015

**New**

- support for [Carthage](https://github.com/Carthage/Carthage) (contribution by [@acwright](https://github.com/acwright))



## v0.9.0

Released on 12 May, 2015

**New**

- support for [CocoaPods](https://cocoapods.org) (contribution by [@marcelofabri](https://github.com/marcelofabri))
