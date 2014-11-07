//
//  MustacheFilter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol MustacheFilter {
    func filterWithAppliedArgument(argument: MustacheValue) -> MustacheFilter?
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue?
}
