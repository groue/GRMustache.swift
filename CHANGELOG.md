Release Notes
=============

## v1.0.0rc1

Released on December 7, 2015

**New**

- Support for Swift Package Manager ([#17](https://github.com/groue/GRMustache.swift/issues/17))

**Breaking Change**

- Swift 2.2 ([#17](https://github.com/groue/GRMustache.swift/issues/17))


## v0.11.0

Released on October 14, 2015

**Fixed**

- Compatibility with iOS7 ([#13](https://github.com/groue/GRMustache.swift/issues/13))
- GRMustache.swift no longer messes with AnyObject subscript operator ([#12](https://github.com/groue/GRMustache.swift/issues/12))


**Breaking Changes**

- `Error` has been renamed `MustacheError`.
- `Error.Type` has been renamed `MustacheError.Kind`
- Subscript operators on `MustacheBox` and `Context` have been removed due to a [weird Swift bug](https://github.com/groue/GRMustache.swift/issues/12). Use the `mustacheBoxForKey()` function instead.


## v0.10.0

Released on September 10, 2015

**New**

- `StandardLibrary.Logger` is there to help debugging templates.


**Breaking changes**

- Swift 2.

- Collections no longer expose Objective-C-compatible keys to templates: `{{ array.firstObject }}`, `{{ array.lastObject }}`, `{{ set.anyObject }}` no longer render anything. Focusing on Swift standard library, the only supported keys are now `first`, `count`, and `last` (the latter being undefined for sets).

- `Context.BoxForMustacheExpression` has been renamed `Context.mustacheBoxForExpression`

- `BoxAnyObject()` is removed. You must now explicit cast `AnyObject` to a boxable type that you can box with `Box()`.

- `Box(value:boolValue:keyedSubscript:filter:render:willRender:didRender:)` has been replaced by a MustacheBox initializer with the same arguments.


## v0.9.4

Released on August 19, 2015

**Fixed**

- A memory leak
- Reduced deployment targets to iOS 8.0 and OSX 10.9 ([#11](https://github.com/groue/GRMustache.swift/pull/11))


## v0.9.3

Released on June 9, 2015

**Breaking changes**

- There is no longer any automatic conversion between Swift and Objective-C numeric types beyond conversions provided by the Swift language itself. For example, a filter of `Int` no longer accepts `Double` inputs. The `MustacheBox.intValue`, `uintValue`, `doubleValue` properties that performed those conversions are removed.

- High-level APIs that would build filters of non-optional values are removed. It is now the responsability of the library user to handle values that are missing or of the wrong type.


## v0.9.2

Released on June 7, 2015

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

- Mustache-specific errors are now of type `Mustache.Error`.

## v0.9.1

Released on 19 May, 2015

**New**

- support for [Carthage](https://github.com/Carthage/Carthage) (contribution by [@acwright](https://github.com/acwright))



## v0.9.0

Released on 12 May, 2015

**New**

- support for [CocoaPods](https://cocoapods.org) (contribution by [@marcelofabri](https://github.com/marcelofabri))
