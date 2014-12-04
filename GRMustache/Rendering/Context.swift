//
//  Context.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

// Context is an immutable value.
// However, it can not be a struct because it is recursive.
// So it only exposes immutable APIs.
public class Context {
    private enum Type {
        case Root
        case BoxType(box: Box, parent: Context)
        case InheritablePartialNodeType(inheritablePartialNode: InheritablePartialNode, parent: Context)
        case TagObserverType(tagObserver: MustacheTagObserver, parent: Context)
    }
    
    private let type: Type
    
    public var topBoxedValue: Box {
        switch type {
        case .Root:
            return Box()
        case .BoxType(box: let box, parent: _):
            return box
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent.topBoxedValue
        case .TagObserverType(tagObserver: _, parent: let parent):
            return parent.topBoxedValue
        }
    }
    
    var tagObserverStack: [MustacheTagObserver] {
        switch type {
        case .Root:
            return []
        case .BoxType(box: let box, parent: let parent):
            if let tagObserver: MustacheTagObserver = box.value() {
                return [tagObserver] + parent.tagObserverStack
            } else {
                return parent.tagObserverStack
            }
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent.tagObserverStack
        case .TagObserverType(tagObserver: let tagObserver, parent: let parent):
            return [tagObserver] + parent.tagObserverStack
        }
    }
    
    private init(type: Type) {
        self.type = type
    }
    
    public convenience init() {
        self.init(type: .Root)
    }
    
    public convenience init(_ box: Box) {
        self.init(type: .BoxType(box: box, parent: Context()))
    }
    
    public convenience init(_ tagObserver: MustacheTagObserver) {
        self.init(type: .TagObserverType(tagObserver: tagObserver, parent: Context()))
    }
    
    public func extendedContext(# box: Box) -> Context {
        if box.isEmpty {
            return self
        } else {
            return Context(type: .BoxType(box: box, parent: self))
        }
    }
    
    func extendedContext(# inheritablePartialNode: InheritablePartialNode) -> Context {
        return Context(type: .InheritablePartialNodeType(inheritablePartialNode: inheritablePartialNode, parent: self))
    }
    
    public func extendedContext(# tagObserver: MustacheTagObserver) -> Context {
        return Context(type: .TagObserverType(tagObserver: tagObserver, parent: self))
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
            case .TagObserverType(tagObserver: _, parent: let parent):
                context = parent
            }
        }
    }
    
    public subscript(identifier: String) -> Box {
        switch type {
        case .Root:
            return Box()
        case .BoxType(box: let box, parent: let parent):
            let innerBox = box[identifier]
            if innerBox.isEmpty {
                return parent[identifier]
            } else {
                return innerBox
            }
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent[identifier]
        case .TagObserverType(tagObserver: _, parent: let parent):
            return parent[identifier]
        }
    }
    
    public func boxedValueForMustacheExpression(string: String, error: NSErrorPointer = nil) -> Box? {
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
        case .TagObserverType(tagObserver: let tagObserver, parent: let parent):
            return "Context.TagObserverType(\(tagObserver)):\(parent.debugDescription)"
        }
    }
}