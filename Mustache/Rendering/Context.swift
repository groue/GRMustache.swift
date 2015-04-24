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
rendered by the {{.}} tag:

::

  // Renders "Kitty, Pussy, Melba, "
  let template = Template(string: "{{#cats}}{{.}}, {{/cats}}")!
  template.render(Box(["cats": ["Kitty", "Pussy", "Melba"]]))!

Key lookup starts with the current context and digs down the stack until if
finds a value:

::

  // Renders "child, parent, "
  let template = Template(string: "{{#children}}{{name}}, {{/children}}")!
  let data = [
      "name": "parent",
      "children": [
          ["name": "child"],
          [:]    // a child without a name
      ]
  ]
  template.render(Box(data))!

:see: Configuration
:see: TemplateRepository
:see: RenderFunction
*/
final public class Context {
    private enum Type {
        case Root
        case BoxType(box: MustacheBox, parent: Context)
        case InheritedPartialType(inheritedPartial: TemplateASTNode.InheritedPartialDescriptor, parent: Context)
    }
    
    private var registeredKeysContext: Context?
    private let type: Type
    
    
    // =========================================================================
    // MARK: - Creating Contexts
    
    /**
    Returns an empty Context.
    */
    public convenience init() {
        self.init(type: .Root)
    }
    
    /**
    Returns a context containing the provided box.
    
    ::
    
      let context = Context(Box(["foo": "bar"]))
    
      // Renders "bar"
      let template = Template(string: "{{foo}}")!
      template.baseContext = context
      template.render()!
    */
    public convenience init(_ box: MustacheBox) {
        self.init(type: .BoxType(box: box, parent: Context()))
    }
    
    /**
    Returns a context containing the provided box.
    
    The registered key can not be shadowed by: it will always evaluate to the
    same value.
    ::
    
      let context = Context(registeredKey: "foo", box: Box("bar"))
    
      let template = Template(string: "{{foo}}")!
      template.baseContext = context
    
      // Renders "bar"
      template.render()!
    
      // Renders "bar" again, because the registered key "foo" can not be
      // shadowed.
      template.render(Box(["foo": "qux"]))!
    */
    public convenience init(registeredKey key: String, box: MustacheBox) {
        self.init(type: .Root, registeredKeysContext: Context(Box([key: box])))
    }
    
    
    // =========================================================================
    // MARK: - Deriving New Contexts
    
    /**
    Inserts the box at the top of the context stack, and returns the new context
    stack.
    */
    public func extendedContext(box: MustacheBox) -> Context {
        return Context(type: .BoxType(box: box, parent: self), registeredKeysContext: registeredKeysContext)
    }
    
    /**
    Registers the box in the context stack, and returns the new context stack.
    
    The registered key can not be shadowed by: it will always evaluate to the
    same value.
    */
    public func contextWithRegisteredKey(key: String, box: MustacheBox) -> Context {
        let registeredKeysContext = (self.registeredKeysContext ?? Context()).extendedContext(Box([key: box]))
        return Context(type: self.type, registeredKeysContext: registeredKeysContext)
    }
    
    
    // =========================================================================
    // MARK: - Fetching Values from the Context Stack
    
    /**
    Returns the boxed value at the top of the context stack.
    
    The returned box is the same as the one that would be rendered by the {{.}}
    tag.
    
    The topBox of an empty context is the empty box.
    */
    public var topBox: MustacheBox {
        switch type {
        case .Root:
            return Box()
        case .BoxType(box: let box, parent: _):
            return box
        case .InheritedPartialType(inheritedPartial: _, parent: let parent):
            return parent.topBox
        }
    }
    
    /**
    Returns the boxed value stored in the context stack for the given key.
    
    The following search pattern is used:
    
    1. If the key is registered, returns the registered box for that key.
    
    2. Otherwise, searches the context stack for a box that has a non-empty
       box for the key (see InspectFunction).
    
    3. If none of the above situations occurs, returns the empty box.

    ::
    
      let data = ["name": "Groucho Marx"]
      let context = Context(Box(data))
      
      // "Groucho Marx"
      context["name"].value as String
    
    If you want the value for a full Mustache expression such as `user.name` or
    `uppercase(user.name)`, use the boxForMustacheExpression method.
    
    :see: boxForMustacheExpression
    */
    public subscript (key: String) -> MustacheBox {
        if let registeredKeysContext = registeredKeysContext {
            let box = registeredKeysContext[key]
            if !box.isEmpty {
                return box
            }
        }
        
        switch type {
        case .Root:
            return Box()
        case .BoxType(box: let box, parent: let parent):
            let innerBox = box[key]
            if innerBox.isEmpty {
                return parent[key]
            } else {
                return innerBox
            }
        case .InheritedPartialType(inheritedPartial: _, parent: let parent):
            return parent[key]
        }
    }
    
    /**
    Evaluates a Mustache expression such as `name`, or `uppercase(user.name)`.
    
    ::
    
      let data = ["person": ["name": "Albert Einstein"]]
      let context = Context(Box(data))
      
      // "Albert Einstein"
      context.boxForMustacheExpression("person.name")!.value as String
    
    :param: string The expression string
    :param: error  If there is a problem parsing or evaluating the expression,
                   upon return contains an NSError object that describes the
                   problem.
    
    :returns: The value of the expression
    */
    public func boxForMustacheExpression(string: String, error: NSErrorPointer = nil) -> MustacheBox? {
        let parser = ExpressionParser()
        var empty = false
        if let expression = parser.parse(string, empty: &empty, error: error) {
            let invocation = ExpressionInvocation(expression: expression)
            let invocationResult = invocation.invokeWithContext(self)
            switch invocationResult {
            case .Error(let invocationError):
                if error != nil {
                    error.memory = invocationError
                }
                return nil
            case .Success(let box):
                return box
            }
        }
        return nil
    }
    
    
    // =========================================================================
    // MARK: - Not public
    
    var willRenderStack: [WillRenderFunction] {
        switch type {
        case .Root:
            return []
        case .BoxType(box: let box, parent: let parent):
            if let willRender = box.willRender {
                return [willRender] + parent.willRenderStack
            } else {
                return parent.willRenderStack
            }
        case .InheritedPartialType(inheritedPartial: _, parent: let parent):
            return parent.willRenderStack
        }
    }
    
    var didRenderStack: [DidRenderFunction] {
        switch type {
        case .Root:
            return []
        case .BoxType(box: let box, parent: let parent):
            if let didRender = box.didRender {
                return parent.didRenderStack + [didRender]
            } else {
                return parent.didRenderStack
            }
        case .InheritedPartialType(inheritedPartial: _, parent: let parent):
            return parent.didRenderStack
        }
    }
    
    private init(type: Type, registeredKeysContext: Context? = nil) {
        self.type = type
        self.registeredKeysContext = registeredKeysContext
    }
    
    func extendedContext(# inheritedPartial: TemplateASTNode.InheritedPartialDescriptor) -> Context {
        return Context(type: .InheritedPartialType(inheritedPartial: inheritedPartial, parent: self), registeredKeysContext: registeredKeysContext)
    }
    
    func resolveTemplateASTNode(var node: TemplateASTNode) -> TemplateASTNode {
        var usedTemplateASTs: [TemplateAST] = []
        var context = self
        while true {
            switch context.type {
            case .Root:
                return node
            case .BoxType(box: _, parent: let parent):
                context = parent
            case .InheritedPartialType(inheritedPartial: let inheritedPartial, parent: let parent):
                let templateAST = inheritedPartial.partial.templateAST
                var used = false
                for usedTemplateAST in usedTemplateASTs {
                    if usedTemplateAST === templateAST {
                        used = true
                        break
                    }
                }
                if !used {
                    let (resolvedNode, modified) = resolveInheritedPartial(inheritedPartial, node: node)
                    if modified {
                        usedTemplateASTs.append(templateAST)
                    }
                    node = resolvedNode
                }
                context = parent
            }
        }
    }
    
    private func resolve(# inheritedNode: TemplateASTNode, node: TemplateASTNode) -> (TemplateASTNode, Bool) {
        switch inheritedNode {
        case .InheritableSection(let inheritableSection):
            return resolveInheritableSection(inheritableSection, node: node)
        case .InheritedPartial(let inheritedPartial):
            return resolveInheritedPartial(inheritedPartial, node: node)
        case .Partial(let partial):
            return resolvePartial(partial, node: node)
        case .Section, .Text, .Variable:
            return (node, false)
        }
    }
    
    private func resolveInheritableSection(inheritableSection: TemplateASTNode.InheritableSectionDescriptor, node: TemplateASTNode) -> (TemplateASTNode, Bool) {
        switch node {
        case .InheritableSection(let otherInheritableSection) where otherInheritableSection.name == inheritableSection.name:
            return (.InheritableSection(inheritableSection), true)
        default:
            return (node, false)
        }
    }
    
    private func resolveInheritedPartial(inheritedPartial: TemplateASTNode.InheritedPartialDescriptor, var node: TemplateASTNode) -> (TemplateASTNode, Bool) {
        return reduce(inheritedPartial.templateAST.nodes, (node, false)) { (pair, inheritedNode) in
            let (node, modified) = pair
            let (resolvedNode, resolvedModified) = resolve(inheritedNode: inheritedNode, node: node)
            return (resolvedNode, modified || resolvedModified)
        }
    }
    
    private func resolvePartial(partial: TemplateASTNode.PartialDescriptor, var node: TemplateASTNode) -> (TemplateASTNode, Bool) {
        return reduce(partial.templateAST.nodes, (node, false)) { (pair, inheritedNode) in
            let (node, modified) = pair
            let (resolvedNode, resolvedModified) = resolve(inheritedNode: inheritedNode, node: node)
            return (resolvedNode, modified || resolvedModified)
        }
    }
}

extension Context: DebugPrintable {
    public var debugDescription: String {
        switch type {
        case .Root:
            return "Context.Root"
        case .BoxType(box: let box, parent: let parent):
            return "Context.BoxType(\(box)):\(parent.debugDescription)"
        case .InheritedPartialType(inheritedPartial: let inheritedPartial, parent: let parent):
            return "Context.InheritedPartialType(\(inheritedPartial)):\(parent.debugDescription)"
        }
    }
}