//
//  ContentType.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public enum ContentType {
    case Text
    case HTML
}

public typealias ContentTypePointer = UnsafeMutablePointer<ContentType>