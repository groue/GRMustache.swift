// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

/**
A Context represents a state of the Mustache "context stack".

The context stack grows and shrinks as the Mustache engine enters and leaves
Mustache sections.

The top of the context stack is called the "current context". It is the value
rendered by the `{{.}}` tag:

    // Renders "Kitty, Pussy, Melba, "
    let template = try! Template(string: "{{#cats}}{{.}}, {{/cats}}")
    try! template.render(Box(["cats": ["Kitty", "Pussy", "Melba"]]))

Key lookup starts with the current context and digs down the stack until if
finds a value:

    // Renders "<child>, <parent>, "
    let template = try! Template(string: "{{#children}}<{{name}}>, {{/children}}")
    let data = [
      "name": "parent",
      "children": [
          ["name": "child"],
          [:]    // a child without a name
      ]
    ]
    try! template.render(Box(data))

See also:

- Configuration
- TemplateRepository
- RenderFunction
*/
final public class Context {
    
    // =========================================================================
    // MARK: - Creating Contexts
    
    /**
    Builds an empty Context.
    */
    public convenience init() {
        self.init(type: .Root)
    }
    
    /**
    Builds a context that contains the provided box.
    
    - parameter box: A box.
    - returns: A new context that contains *box*.
    */
    public convenience init(_ box: MustacheBox) {
        self.init(type: .Box(box: box, parent: Context()))
    }
    
    /**
    Builds a context with a registered key. Registered keys are looked up first
    when evaluating Mustache tags.
    
    - parameter key: An identifier.
    - parameter box: A box.
    - returns: A new context with *box* registered for *key*.
    */
    public convenience init(registeredKey key: String, box: MustacheBox) {
        let d = [key: box]
        self.init(type: .Root, registeredKeysContext: Context(Box(d)))
    }
    
    
    // =========================================================================
    // MARK: - Deriving New Contexts
    
    /**
    Returns a new context with the provided box pushed at the top of the context
    stack.
    
    - parameter box: A box.
    - returns: A new context with *box* pushed at the top of the stack.
    */
    @warn_unused_result(message="Context.extendedContext returns a new Context.")
    public func extendedContext(box: MustacheBox) -> Context {
        return Context(type: .Box(box: box, parent: self), registeredKeysContext: registeredKeysContext)
    }
    
    /**
    Returns a new context with the provided box at the top of the context stack.
    Registered keys are looked up first when evaluating Mustache tags.
    
    - parameter key: An identifier.
    - parameter box: A box.
    - returns: A new context with *box* registered for *key*.
    */
    @warn_unused_result(message="Context.contextWithRegisteredKey returns a new Context.")
    public func contextWithRegisteredKey(key: String, box: MustacheBox) -> Context {
        let d = [key: box]
        let registeredKeysContext = (self.registeredKeysContext ?? Context()).extendedContext(Box(d))
        return Context(type: self.type, registeredKeysContext: registeredKeysContext)
    }
    
    
    // =========================================================================
    // MARK: - Fetching Values from the Context Stack
    
    /**
    Returns the top box of the context stack, the one that would be rendered by
    the `{{.}}` tag.
    */
    public var topBox: MustacheBox {
        switch type {
        case .Root:
            return Box()
        case .Box(box: let box, parent: _):
            return box
        case .PartialOverride(partialOverride: _, parent: let parent):
            return parent.topBox
        }
    }
    
    /**
    Returns the boxed value stored in the context stack for the given key.
    
    The following search pattern is used:
    
    1. If the key is "registered", returns the registered box for that key.
    
    2. Otherwise, searches the context stack for a box that has a non-empty
       box for the key (see `InspectFunction`).
    
    3. If none of the above situations occurs, returns the empty box.
    
            let data = ["name": "Groucho Marx"]
            let context = Context(Box(data))
    
            // "Groucho Marx"
            context.mustacheBoxForKey("name").value

    If you want the value for a full Mustache expression such as `user.name` or
    `uppercase(user.name)`, use the `mustacheBoxForExpression` method.
    
    - parameter key: A key.
    - returns: The MustacheBox for *key*.
    */
    public func mustacheBoxForKey(key: String) -> MustacheBox {
        if let registeredKeysContext = registeredKeysContext {
            let box = registeredKeysContext.mustacheBoxForKey(key)
            if !box.isEmpty {
                return box
            }
        }
        
        switch type {
        case .Root:
            return Box()
        case .Box(box: let box, parent: let parent):
            let innerBox = box.mustacheBoxForKey(key)
            if innerBox.isEmpty {
                return parent.mustacheBoxForKey(key)
            } else {
                return innerBox
            }
        case .PartialOverride(partialOverride: _, parent: let parent):
            return parent.mustacheBoxForKey(key)
        }
    }
    
    /**
    Evaluates a Mustache expression such as `name`, or `uppercase(user.name)`.
    
        let data = ["person": ["name": "Albert Einstein"]]
        let context = Context(Box(data))

        // "Albert Einstein"
        try! context.mustacheBoxForExpression("person.name").value
    
    - parameter string: The expression string.
    - parameter error:  If there is a problem parsing or evaluating the
                        expression, throws an error that describes the problem.
    
    - returns: The value of the expression.
    */
    public func mustacheBoxForExpression(string: String) throws -> MustacheBox {
        let parser = ExpressionParser()
        var empty = false
        let expression = try parser.parse(string, empty: &empty)
        let invocation = ExpressionInvocation(expression: expression)
        return try invocation.invokeWithContext(self)
    }
    
    
    // =========================================================================
    // MARK: - Not public
    
    private enum `Type` {
        case Root
        case Box(box: MustacheBox, parent: Context)
        case PartialOverride(partialOverride: TemplateASTNode.PartialOverride, parent: Context)
    }
    
    private var registeredKeysContext: Context?
    private let type: Type
    
    var willRenderStack: [WillRenderFunction] {
        switch type {
        case .Root:
            return []
        case .Box(box: let box, parent: let parent):
            if let willRender = box.willRender {
                return [willRender] + parent.willRenderStack
            } else {
                return parent.willRenderStack
            }
        case .PartialOverride(partialOverride: _, parent: let parent):
            return parent.willRenderStack
        }
    }
    
    var didRenderStack: [DidRenderFunction] {
        switch type {
        case .Root:
            return []
        case .Box(box: let box, parent: let parent):
            if let didRender = box.didRender {
                return parent.didRenderStack + [didRender]
            } else {
                return parent.didRenderStack
            }
        case .PartialOverride(partialOverride: _, parent: let parent):
            return parent.didRenderStack
        }
    }
    
    var partialOverrideStack: [TemplateASTNode.PartialOverride] {
        switch type {
        case .Root:
            return []
        case .Box(box: _, parent: let parent):
            return parent.partialOverrideStack
        case .PartialOverride(partialOverride: let partialOverride, parent: let parent):
            return [partialOverride] + parent.partialOverrideStack
        }
    }
    
    private init(type: Type, registeredKeysContext: Context? = nil) {
        self.type = type
        self.registeredKeysContext = registeredKeysContext
    }

    func extendedContext(partialOverride partialOverride: TemplateASTNode.PartialOverride) -> Context {
        return Context(type: .PartialOverride(partialOverride: partialOverride, parent: self), registeredKeysContext: registeredKeysContext)
    }
}

extension Context: CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        switch type {
        case .Root:
            return "Context.Root"
        case .Box(box: let box, parent: let parent):
            return "Context.Box(\(box)):\(parent.debugDescription)"
        case .PartialOverride(partialOverride: _, parent: let parent):
            return "Context.PartialOverride:\(parent.debugDescription)"
        }
    }
}