TODO

- [ ] Use in examples: Freddy Mercury, Salvador Dali, Tom Selleck, Charles Bronson, Clark Gable, Albert Einstein, Charlie Chaplin, Errol Flynn, Groucho Marx, Hulk Hogan, Mario, Luigi, Zorro, Frank Zappa, Lionel Richie
- [ ] Rewrite GRMustacheKeyAccess.m in pure Swift
- [ ] Think about migration from ObjC GRMustache, and list incompatibilities. Fix the most cruel ones.
- [ ] Review all calls to fatalError(), all `as!` operators, and check if it's not type-system fighting (for example, couldn't we turn Tag into a protocol?). The same for undefined/defined AST, TemplateToken.tagDelimiterPair, etc.
- [ ] `extension P where Self: ... { }` can we use this?
- [ ] Is support for IntMax useful?
- [ ] Experiment with replacing Box(value, boolValue, ...) by a protocol with default implementations.
- [ ] Experiment with NSError.setUserInfoValueProviderForDomain
- [ ] Restore `Box([MustacheBoxable?]?)` as soon as Swift2 can
- [ ] How to wrap errors thrown from user closures (TemplateRepositoryDataSource, FilterFunction, RenderFunction)?
