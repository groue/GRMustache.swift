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
        case ValueType(value: Value, parent: Context)
        case InheritablePartialNodeType(inheritablePartialNode: InheritablePartialNode, parent: Context)
        case TagObserverType(tagObserver: MustacheTagObserver, parent: Context)
    }
    
    private let type: Type
    
    public var topMustacheValue: Value {
        switch type {
        case .Root:
            return Value()
        case .ValueType(value: let value, parent: _):
            return value
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent.topMustacheValue
        case .TagObserverType(tagObserver: _, parent: let parent):
            return parent.topMustacheValue
        }
    }
    
    var tagObserverStack: [MustacheTagObserver] {
        switch type {
        case .Root:
            return []
        case .ValueType(value: let value, parent: let parent):
            if let tagObserver: MustacheTagObserver = value.object() {
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
    
    public convenience init(_ value: Value) {
        self.init(type: .ValueType(value: value, parent: Context()))
    }
    
    public convenience init(_ tagObserver: MustacheTagObserver) {
        self.init(type: .TagObserverType(tagObserver: tagObserver, parent: Context()))
    }
    
    public func contextByAddingValue(value: Value) -> Context {
        if value.isEmpty {
            return self
        } else {
            return Context(type: .ValueType(value: value, parent: self))
        }
    }
    
    func contextByAddingInheritablePartialNode(inheritablePartialNode: InheritablePartialNode) -> Context {
        return Context(type: .InheritablePartialNodeType(inheritablePartialNode: inheritablePartialNode, parent: self))
    }
    
    public func contextByAddingTagObserver(tagObserver: MustacheTagObserver) -> Context {
        return Context(type: .TagObserverType(tagObserver: tagObserver, parent: self))
    }
    
    func resolveTemplateASTNode(var node: TemplateASTNode) -> TemplateASTNode {
        var usedTemplateASTs: [TemplateAST] = []
        var context = self
        while true {
            switch context.type {
            case .Root:
                return node
            case .ValueType(value: _, parent: let parent):
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
    
    public subscript(identifier: String) -> Value {
        switch type {
        case .Root:
            return Value()
        case .ValueType(value: let value, parent: let parent):
            let innerValue = value[identifier]
            if innerValue.isEmpty {
                return parent[identifier]
            } else {
                return innerValue
            }
        case .InheritablePartialNodeType(inheritablePartialNode: _, parent: let parent):
            return parent[identifier]
        case .TagObserverType(tagObserver: _, parent: let parent):
            return parent[identifier]
        }
    }
    
    public func valueForMustacheExpression(string: String, error outError: NSErrorPointer = nil) -> Value? {
        let parser = ExpressionParser()
        var empty = false
        if let expression = parser.parse(string, token: nil, empty: &empty, error: outError) {
            let invocation = ExpressionInvocation(expression: expression)
            if invocation.invokeWithContext(self, error: outError) {
                return invocation.value
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
        case .ValueType(value: let value, parent: let parent):
            return "Context.ValueType(\(value)):\(parent.debugDescription)"
        case .InheritablePartialNodeType(inheritablePartialNode: let node, parent: let parent):
            return "Context.InheritablePartialNodeType(\(node)):\(parent.debugDescription)"
        case .TagObserverType(tagObserver: let tagObserver, parent: let parent):
            return "Context.TagObserverType(\(tagObserver)):\(parent.debugDescription)"
        }
    }
}