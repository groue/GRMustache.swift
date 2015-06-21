TODO

- [ ] Use in examples: Freddy Mercury, Salvador Dali, Tom Selleck, Charles Bronson, Clark Gable, Albert Einstein, Charlie Chaplin, Errol Flynn, Groucho Marx, Hulk Hogan, Mario, Luigi, Zorro, Frank Zappa, Lionel Richie
- [ ] Rewrite GRMustacheKeyAccess.m in pure Swift
- [ ] Think about migration from ObjC GRMustache, and list incompatibilities. Fix the most cruel ones.
- [ ] Review all calls to fatalError(), all `as!` operators, and check if it's not type-system fighting (for example, couldn't we turn Tag into a protocol?). The same for undefined/defined AST, TemplateToken.tagDelimiterPair, etc.
- [ ] `extension P where Self: ... { }` can we use this?
- Vocabulary: "inherited partial" and "inheritable section" are heavy and confusing. What about "super partial" and "blocks" ("blocks" comes from Mustache.php). Check Hogan and mustache.java doc, and try to harmonize.
