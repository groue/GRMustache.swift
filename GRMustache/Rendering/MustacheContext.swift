//
//  MustacheContext.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

// MustacheContext is an immutable value.
// However, it can not be a struct because it is recursive.
// So it only exposes immutable APIs.
class MustacheContext {
    enum Type {
        case Root
        case Value(value: MustacheValue, parent: MustacheContext)
        case InheritablePartial(inheritablePartialNode: InheritablePartialNode, parent: MustacheContext)
        case TagObserver(tagObserver: MustacheTagObserver, parent: MustacheContext)
    }
    
    let type: Type
    
    var topMustacheValue: MustacheValue {
        switch type {
        case .Root:
            return MustacheValue()
        case .Value(value: let value, parent: _):
            return value
        case .InheritablePartial(inheritablePartialNode: _, parent: let parent):
            return parent.topMustacheValue
        case .TagObserver(tagObserver: _, parent: let parent):
            return parent.topMustacheValue
        }
    }
    
    var tagObserverStack: [MustacheTagObserver] {
        switch type {
        case .Root:
            return []
        case .Value(value: let value, parent: let parent):
            switch value.type {
            case .ClusterValue(let cluster):
                if let tagObserver = cluster.mustacheTagObserver {
                    return [tagObserver] + parent.tagObserverStack
                } else {
                    return parent.tagObserverStack
                }
            default:
                return parent.tagObserverStack
            }
        case .InheritablePartial(inheritablePartialNode: _, parent: let parent):
            return parent.tagObserverStack
        case .TagObserver(tagObserver: let tagObserver, parent: let parent):
            return [tagObserver] + parent.tagObserverStack
        }
    }
    
    private init(type: Type) {
        self.type = type
    }
    
    convenience init() {
        self.init(type: .Root)
    }
    
    convenience init(_ value: MustacheValue) {
        self.init(type: .Value(value: value, parent: MustacheContext()))
    }
    
    func contextByAddingValue(value: MustacheValue) -> MustacheContext {
        switch value.type {
        case .None:
            return self
        default:
            return MustacheContext(type: .Value(value: value, parent: self))
        }
    }
    
    func contextByAddingInheritablePartialNode(inheritablePartialNode: InheritablePartialNode) -> MustacheContext {
        return MustacheContext(type: .InheritablePartial(inheritablePartialNode: inheritablePartialNode, parent: self))
    }
    
    func contextByAddingTagObserver(tagObserver: MustacheTagObserver) -> MustacheContext {
        return MustacheContext(type: .TagObserver(tagObserver: tagObserver, parent: self))
    }
    
    func resolveTemplateASTNode(var node: TemplateASTNode) -> TemplateASTNode {
        var usedTemplateASTs: [TemplateAST] = []
        var context = self
        while true {
            switch context.type {
            case .Root:
                return node
            case .Value(value: _, parent: let parent):
                context = parent
            case .InheritablePartial(inheritablePartialNode: let inheritablePartialNode, parent: let parent):
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
            case .TagObserver(tagObserver: _, parent: let parent):
                context = parent
            }
        }
    }
    
    subscript(identifier: String) -> MustacheValue {
        switch type {
        case .Root:
            return MustacheValue()
        case .Value(value: let value, parent: let parent):
            let innerValue = value[identifier]
            switch innerValue.type {
            case .None:
                return parent[identifier]
            default:
                return innerValue
            }
        case .InheritablePartial(inheritablePartialNode: _, parent: let parent):
            return parent[identifier]
        case .TagObserver(tagObserver: _, parent: let parent):
            return parent[identifier]
        }
    }
}