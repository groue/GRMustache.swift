//
//  escapeHTML.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

func escapeHTML(string: String) -> String {
    let escapeTable: [Character: String] = [
        "<": "&lt;",
        ">": "&gt;",
        "&": "&amp;",
        "'": "&apos;",
        "\"": "&quot;",
    ]
    var escaped = ""
    for c in string {
        if let escapedString = escapeTable[c] {
            escaped += escapedString
        } else {
            escaped.append(c)
        }
    }
    return escaped
}
