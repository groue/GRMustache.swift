//
//  MustacheFilter.swift
//  GRMustache
//
//  Created by Gwendal Roué on 28/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol Filter {
    func filterByCurryingArgument(argument: MustacheValue) -> Filter
    func transformedValue(value: MustacheValue) -> MustacheValue
}