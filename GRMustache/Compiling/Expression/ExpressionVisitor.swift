//
//  ExpressionVisitor.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol ExpressionVisitor {
    func visit(expression: IdentifierExpression, error outError: NSErrorPointer) -> Bool
}