//
//  TemplateAST.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class TemplateAST {
    enum Type {
        case Undefined
        case Defined(nodes: [TemplateASTNode], contentType: ContentType)
    }
    var type: Type
    
    init(type: Type) {
        self.type = type
    }
    
    convenience init() {
        self.init(type: Type.Undefined)
    }
    
    convenience init(nodes: [TemplateASTNode], contentType: ContentType) {
        self.init(type: Type.Defined(nodes: nodes, contentType: contentType))
    }

    var nodes: [TemplateASTNode] {
        switch type {
        case .Undefined:
            return []
        case .Defined(let nodes, let _):
            return nodes
        }
    }

    var contentType: ContentType {
        switch type {
        case .Undefined:
            return .HTML
        case .Defined(let _, let contentType):
            return contentType
        }
    }

    func updateFromTemplateAST(templateAST: TemplateAST) {
        self.type = templateAST.type
    }
}
