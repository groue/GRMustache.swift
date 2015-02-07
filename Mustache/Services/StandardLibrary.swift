//
//  StandardLibrary.swift
//
//  Created by Gwendal Roué on 30/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//


public struct StandardLibrary {
    public static let HTMLEscape: MustacheBoxable = Mustache.HTMLEscape()
    public static let URLEscape: MustacheBoxable = Mustache.URLEscape()
    public static let javascriptEscape: MustacheBoxable = Mustache.JavascriptEscape()
    public static let each = EachFilter
    public static let zip = ZipFilter
}
