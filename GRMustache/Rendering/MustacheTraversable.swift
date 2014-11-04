//
//  MustacheTraversable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 04/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol MustacheTraversable {
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue?
}
