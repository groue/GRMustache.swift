//
//  TemplateAST.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

enum TemplateAST {
    case None
    case Some(nodes: [TemplateASTNode], contentType: ContentType)
    
    var nodes: [TemplateASTNode] {
        switch self {
        case None:
            return []
        case Some(let nodes, let _):
            return nodes
        }
    }
    
    var contentType: ContentType {
        switch self {
        case None:
            return .HTML
        case Some(let _, let contentType):
            return contentType
        }
    }
    
    mutating func realize(nodes: [TemplateASTNode], contentType: ContentType) {
        self = Some(nodes: nodes, contentType: contentType)
    }
}
