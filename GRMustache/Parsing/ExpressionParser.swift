//
//  ExpressionParser.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class ExpressionParser {
    
    func parse(string: String, inout empty: Bool, error: NSErrorPointer) -> Expression? {
        return IdentifierExpression(identifier: "name")
    }
}
