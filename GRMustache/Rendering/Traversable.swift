//
//  Traversable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 04/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public protocol Traversable {
    func valueForMustacheIdentifier(identifier: String) -> Value?
}
