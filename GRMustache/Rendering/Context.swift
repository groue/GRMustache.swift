//
//  Context.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class Context {
    let value: MustacheValue
    let parent: Context?
    
    init() {
        self.value = .none
    }
    
    init(value: MustacheValue, parent: Context) {
        self.value = value
        self.parent = parent
    }
    
    func contextByAddingValue(value: MustacheValue) -> Context {
        switch value {
        case .none:
            return self
        default:
            return Context(value: value, parent: self)
        }
    }
    
    func resolveTemplateASTNode(node: TemplateASTNode) -> TemplateASTNode {
        return node
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue {
        let innerValue = value.valueForMustacheIdentifier(identifier)
        switch innerValue {
        case .none:
            if let parent = parent {
                return parent.valueForMustacheIdentifier(identifier)
            } else {
                return .none
            }
        default:
            return innerValue
        }
    }
}