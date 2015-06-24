The Box function
================

Why do we force the user to box the rendered data with the `Box()` function?

```swift
template.registerInBaseContext("square", Box(squareFilter))
template.render(Box(["foo": "bar"]))
template.render(Box(profile))
```

It is not because we want it.

It is because it is the only way to feed templates with a *unique* API. `Box()` is the only function the library user has to remember in order to feed templates with ints, strings, arrays, dictionaries, filters, lambdas, Obj-C objects, custom types, all of them being able to inject their behaviors in the rendering engine. Especially custom types: only them let the user escape the dull world of a Mustache engine that would only support a fixed set of blessed types.

The tricky part is of course to wrap all those "boxable" types into `MustacheBox`, a single type that wraps the various behaviors of all boxed values. Mustache templates are not a printf-like flat format, but a way to render values burried inside a tree. When the boxed value is a such a tree, we must make sure that all intermediate values, down to the leaves, are rendered correctly, according to their actual type.

Well, the `Box()` function allows us to do that, with some reasonable limitations that we will see. Other options could have been:

- No API at all:
    
    - `template.render(["foo": "bar"])`.
    - `template.render(profile)`.
    
    This is what the Objective-C GRMustache do. Because it can.
    
    With Swift, this is impossible, because is it impossible to define a single type (the argument to `Template.render()`) that does the job. Let's review some candidates for this unicorn type:
    
    - **Any** is not an option: there is no dynamic dispatch behind it, and Swift makes it impossible to perform a runtime check for some boxable types, like collections of boxable types.
    
    - **AnyObject** is not an option: structs and enums are not classes, and we want GRMustache.swift to eat structs and enums. If it would not, the library would need to refactor his code, and this a key requirement of GRMustache.swift that it eats user types without refactoring.
    
    - **NSObject** is not an option: this would again require the user to refactor his existing structs and enum models. And the Objective-C GRMustache already exists. What's the purpose of a Swift Mustache engine that can only render Objective-C objects?
    
    - A **protocol** with a required function is a serious candidate, but Swift won't let specializations of generic types adopt a protocol. In other words, the type system can not make boxable a collection of boxable values. And we need to support collections and dictionaries.
    
    - A **protocol extension** is not an option, because protocol extensions are limited to static dispatch, unable to fulfill our needs.
    
    We have exhausted all general types of Swift, and none of them help us.

- A common method:
    
    - `template.render(["foo": "bar"].asMustacheFood)`.
    - `template.render(profile.asMustacheFood)`.
    
    This will not do because one can not add methods to function types, and templates have to eat some functions, such as `FilterFunction`, `RenderFunction`, etc.
    
    Even if we'd remove those functions from the GRMustache.swift bestiary, and hide them behind some struct that can have such method, we would still face an issue: the method name should never conflict with user-land concepts. To make this happen, it would need to contain the "mustache" word, and would thus be more verbose that `Box()`.

That said, let's have `Box()` box as many types as we can.

We can acheive a reasonably good result through a long series of Swift features and work arounds.

By "reasonably good", we mean that library user does not have to think about it too much: boxing usually work. And when boxing fails, it is because of a few, understandable reasons, that are not too difficult to fix.

1. We start with the MustacheBoxable protocol, and `func Box(boxable: MustacheBoxable?) -> MustacheBox`
    
    Through adoption of MustacheBoxable by Swift standard types Int, UInt,
    etc. and user types, we support:
    
    - `Int`
    - `UInt`
    - `Double`
    - `String`
    - `MustacheBox`
    - User types that adopt MustacheBoxable, with a limitation: Swift won't let non-@objc subclasses override mustacheBox if protocol is adopted by an extension of a non-@objc super class. We get a compiler error "declarations in extensions cannot override yet").

2. `MustacheBox` is an @objc class.
    
    Of course it should have been a struct. Being an immutable class, we don't loose value semantics. Being an @objc class, we avoid the "declarations in extensions cannot override yet" error: subclasses of NSObject can override NSObject.mustacheBox, and this gives us support for:
    
    - `NSObject`
    - `NSNumber`
    - `NSNull`
    - `NSString`
    - `NSSet`
    - `NSDictionary`
    - `NSFormatter`
    - All user subclasses of NSObject
    
    If `MustacheBox` were not an @objc class, NSObject subclasses could not override NSObject.mustacheBox. We'd have to support NSNumber, NSString, etc. through runtime check, and user types would not provide their own custom behavior.

3. `NSObject.mustacheBox` checks for NSFastEnumeration conformance.
    
    This gives us support for:
    
    - `NSArray`
    - `NSOrderedSet`
    - All classes that conform to NSFastEnumeration
    
    This runtime check is necessary because Swift won't let us provide any other way to support NSFastEnumeration.

4. We box Set-like collections with `func Box<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index.Distance == Int>(set: C?) -> MustacheBox`
    
    We get support for:
    
    - `Set<Int>`
    - `Set<String>`
    - `Set<UserType>` as long as UserType conforms to MustacheBoxable.

5. We box Array-like collections with `func Box<C: CollectionType where C.Generator.Element: MustacheBoxable, C.Index: BidirectionalIndexType, C.Index.Distance == Int>(array: C?) -> MustacheBox`
    
    We get support for:
    
    - `Range<Int>`
    - `Array<String>`
    - `Array<MustacheBox>`
    - `Array<UserType>` as long as UserType conforms to MustacheBoxable.
    
    Swift2 currently won't support collections of optional MustacheBoxable because of a compiler crash. Swift1.2 supports it, though: we can expect support for those collections to come back sooner or later.

6. We box dictionaries with `func Box<T: MustacheBoxable>(dictionary: [String: T]?) -> MustacheBox` and `func Box<T: MustacheBoxable>(dictionary: [String: T?]?) -> MustacheBox`
    
    We get support for:
    
    - `[String:Int]`
    - `[String:String?]`
    - `[String:MustacheBox]`
    - `[String:UserType]` as long as UserType conforms to MustacheBoxable.

7. NSObject adopts MustacheBoxable, so an explicit `func Box(object: NSObject?) -> MustacheBox` is rendundant.
    
    Yet we define it.
    
    This (documented?) trick makes Swift perform automatic conversion to Foundation types when possible. This is very handy because we get support for Foundation-compatible nested collections:
    
    - `[String: [Int]]`
    - `[String: [[String: String]]`

8. Core functions FilterFunction, RenderFunction, WillRenderFunction and DidRenderFunction have their own `Box()` variants.
    
    This gives us support for:
    
    - `Filter { ... }`
    - `Lambda { ... }`
    - `RenderFunction`
    - `WillRenderFunction`
    - `DidRenderFunction`

Phew, now we can box quite a bunch of types. But that's a lot of work, and there is often a long chain of causes that makes a type boxable. Don't look for elegance here: there is none. Just a best effort, considering the language limitations.

Some types are still not boxable. Especially all types involving Any or AnyObject, and nested collections that are not Foundation-compatible:

- `[Any]`
- `[String:AnyObject]`
- `[Range<Int>]`
- `[String: FilterFunction]`

For those, there is a single rule: the user has to convert them to a known boxable type. He doesn't feed his templates with random data, does he? So he just has to use the `as` operator or to create a brand new `MustacheBox`, `[MustacheBox]`, or `[String: MustacheBox]`.
