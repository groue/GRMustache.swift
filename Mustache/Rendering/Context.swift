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

// Context is an immutable value.
// However, it can not be a struct because it is recursive.
// So it only exposes immutable APIs.
public class Context {
    private enum Type {
        case Root
        case BoxType(box: MustacheBox, parent: Context)
        case InheritablePartialNodeType(inheritablePartialNode: InheritablePartialNode, parent: Context)
    }
    
    private var registeredKeysContext: Context?
    private let type: Type
    
    public var topBox: MustacheBox {
        switch type {
        case .Root:
            return Box()
        case .BoxType(box: let box, parent: _):
            return box
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent.topBox
        }
    }
    
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
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
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
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent.didRenderStack
        }
    }
    
    private init(type: Type, registeredKeysContext: Context? = nil) {
        self.type = type
        self.registeredKeysContext = registeredKeysContext
    }
    
    public convenience init() {
        self.init(type: .Root)
    }
    
    public convenience init(_ box: MustacheBox) {
        self.init(type: .BoxType(box: box, parent: Context()))
    }
    
    public func contextWithRegisteredKey(key: String, box: MustacheBox) -> Context {
        var registeredKeysContext = self.registeredKeysContext ?? Context()
        registeredKeysContext = registeredKeysContext.extendedContext(Box([key: box]))
        return Context(type: self.type, registeredKeysContext: registeredKeysContext)
    }
    
    public func extendedContext(box: MustacheBox) -> Context {
        return Context(type: .BoxType(box: box, parent: self), registeredKeysContext: registeredKeysContext)
    }
    
    func extendedContext(# inheritablePartialNode: InheritablePartialNode) -> Context {
        return Context(type: .InheritablePartialNodeType(inheritablePartialNode: inheritablePartialNode, parent: self), registeredKeysContext: registeredKeysContext)
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
            case .InheritablePartialNodeType(inheritablePartialNode: let inheritablePartialNode, parent: let parent):
                let templateAST = inheritablePartialNode.partialNode.templateAST
                var used = false
                for usedTemplateAST in usedTemplateASTs {
                    if usedTemplateAST === templateAST {
                        used = true
                        break
                    }
                }
                if !used {
                    let resolvedNode = inheritablePartialNode.resolveTemplateASTNode(node)
                    if resolvedNode !== node {
                        usedTemplateASTs.append(templateAST)
                    }
                    node = resolvedNode
                }
                context = parent
            }
        }
    }
    
    public subscript(key: String) -> MustacheBox {
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
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent[key]
        }
    }
    
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
}

extension Context: DebugPrintable {
    public var debugDescription: String {
        switch type {
        case .Root:
            return "Context.Root"
        case .BoxType(box: let box, parent: let parent):
            return "Context.BoxType(\(box)):\(parent.debugDescription)"
        case .InheritablePartialNodeType(inheritablePartialNode: let node, parent: let parent):
            return "Context.InheritablePartialNodeType(\(node)):\(parent.debugDescription)"
        }
    }
}