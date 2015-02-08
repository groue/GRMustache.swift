TODO

- [X] boxValue(InspectFunction)
- [X] boxValue(FilterFunction)
- [X] boxValue(RenderFunction)
- [X] boxValue(WillRenderFunction)
- [X] boxValue(DidRenderFunction)
- [X] rename InspectFunction
- [ ] rename the objectForKeyedSubscript key to something shorter that still reminds of subscripting
- [X] Box(AnyObject) without forcing the end user to force the ObjCMustacheBoxable cast. Maybe define a specific BoxAnyObject() function.
- [ ] Replace RenderingEngine.currentContentType and currentTemplateRepository with currentConfiguration.
- [X] Don't automatically register the standard library. Instead, provide a way to register the full standard lib, or a way to register one standard tool at a time.
- [X] Import safe handling of valueForKey: from ObjC GRMustache
- [X] Now that MustacheBox exposes arrayValue and dictionaryValue properties, we can, and should, box the exact provided value, and not a rewritten Array/Dictionary.
- [ ] NSNumber, NSString boxing: should we box the original values as we box original collectoins and dictionaries?
- [X] Make MustacheBox.arrayValue and MustacheBox.dictionaryValue lazy
