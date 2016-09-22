TODO

- [ ] Swift3: Formatter / NSFormatter
- [ ] Use in examples: Freddy Mercury, Salvador Dali, Tom Selleck, Charles Bronson, Clark Gable, Albert Einstein, Charlie Chaplin, Errol Flynn, Groucho Marx, Hulk Hogan, Mario, Luigi, Zorro, Frank Zappa, Lionel Richie
- [ ] Rewrite GRMustacheKeyAccess.m in pure Swift
- [ ] Think about migration from ObjC GRMustache, and list incompatibilities. Fix the most cruel ones.
- [ ] Review all calls to fatalError(), all `as!` operators, and check if it's not type-system fighting (for example, couldn't we turn Tag into a protocol?). The same for undefined/defined AST, TemplateToken.tagDelimiterPair, etc.
- [ ] `extension P where Self: ... { }` can we use this?
- [ ] Is support for IntMax useful?
- [ ] Experiment with replacing Box(value:boolValue:keyedSubscript:...) by a protocol with default implementations.
- [ ] Experiment with NSError.setUserInfoValueProviderForDomain
- [ ] Restore `Box([MustacheBoxable?]?)` as soon as Swift2 can
- [ ] Make sure we have a test for all cases of errors thrown from user closures: MustacheError should get a templateID and a line number when possible, and other errors should be wrapped as underlying errors of MustacheError.
- [ ] (Xcode7b6) Evaluate the consequences of:
    http://adcdownload.apple.com/Developer_Tools/Xcode_7_beta_6/Xcode_7_beta_6_Release_Notes.pdf
    > Collections containing types that are not Objective-C compatible are no longer considered Objective-C compatible types themselves. For example, previously Array<SwiftClassType> was permitted as the type of a property marked @objc. This is no longer the case. (19787270)
- [?] Custom escape function? HTML, shell, javascript, whatever...
- [ ] Python-like string interpolation: "Hello {{name}}" % ["name": "Arthur"] which wraps String.mustacheInterpolate(data: ?). Needs another global configuration: StringInterpolationConfiguration. StringInterpolationConfiguration could be filled with all built-in helpers.
- [ ] Check https://github.com/twitter/hogan.js/issues/175
- [ ] Just as in Obj-C GRMustache, we need to distinguish "missing key" from "missing value for a known key". Obj-C uses nil vs. NSNull. What should GRMustache.swift use?
