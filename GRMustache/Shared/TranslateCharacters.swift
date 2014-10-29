//
//  TranslateCharacters.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

func TranslateHTMLCharacters(string: String) -> String {
    var escaped = ""
    for c in string {
        switch c {
        case "<":
            escaped = escaped + "&lt;"
        case ">":
            escaped = escaped + "&gt;"
        case "&":
            escaped = escaped + "&amp;"
        case "\"":
            escaped = escaped + "&quot;"
        case "'":
            escaped = escaped + "&apos;"
        default:
            escaped.append(c)
       }
    }
    return escaped
}
