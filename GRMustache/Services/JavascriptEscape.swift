//
//  JavascriptEscape.swift
//  GRMustache
//
//  Created by Gwendal Roué on 01/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

class JavascriptEscape: MustacheRenderable, MustacheFilter, MustacheTagObserver {
    
    
    // MARK: - MustacheRenderable
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        switch renderingInfo.tag.type {
        case .Variable:
            return "\(self)"
        case .Section, .InvertedSection:
            let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
            return renderingInfo.tag.mustacheRendering(renderingInfo, contentType: outContentType, error: outError)
        }
    }

    
    // MARK: - MustacheFilter
    
    func filterByCurryingArgument(argument: MustacheValue) -> MustacheFilter? {
        return nil
    }
    
    func transformedValue(value: MustacheValue, error outError: NSErrorPointer) -> MustacheValue? {
        switch value.type {
        case .None:
            return value
        default:
            if let string = value.asString() {
                return MustacheValue(escapeJavascript(string))
            } else {
                if outError != nil {
                    outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeRenderingError, userInfo: [NSLocalizedDescriptionKey: "filter argument error: not a string"])
                }
                return nil
            }
        }
    }
    
    
    // MARK: - MustacheTagObserver
    
    func mustacheTag(tag: Tag, willRenderValue value: MustacheValue) -> MustacheValue {
        switch tag.type {
        case .Variable:
            if let string = value.asString() {
                return MustacheValue(escapeJavascript(string))
            } else {
                return value
            }
        case .Section, .InvertedSection:
            return value
        }
    }
    
    func mustacheTag(tag: Tag, didRender rendering: String?, forValue: MustacheValue) {
    }
    
    
    // MARK: - private
    
    func escapeJavascript(string: String) -> String {
        // This table comes from https://github.com/django/django/commit/8c4a525871df19163d5bfdf5939eff33b544c2e2#django/template/defaultfilters.py
        //
        // Quoting Malcolm Tredinnick:
        // > Added extra robustness to the escapejs filter so that all invalid
        // > characters are correctly escaped. This avoids any chance to inject
        // > raw HTML inside <script> tags. Thanks to Mike Wiacek for the patch
        // > and Collin Grady for the tests.
        //
        // Quoting Mike Wiacek from https://code.djangoproject.com/ticket/7177
        // > The escapejs filter currently escapes a small subset of characters
        // > to prevent JavaScript injection. However, the resulting strings can
        // > still contain valid HTML, leading to XSS vulnerabilities. Using hex
        // > encoding as opposed to backslash escaping, effectively prevents
        // > Javascript injection and also helps prevent XSS. Attached is a
        // > small patch that modifies the _js_escapes tuple to use hex encoding
        // > on an expanded set of characters.
        //
        // The initial django commit used `\xNN` syntax. The \u syntax was
        // introduced later for JSON compatibility.
        
        let escapeTable: [Character: String] = [
            "\0": "\\u0000",
            "\u{01}": "\\u0001",
            "\u{02}": "\\u0002",
            "\u{03}": "\\u0003",
            "\u{04}": "\\u0004",
            "\u{05}": "\\u0005",
            "\u{06}": "\\u0006",
            "\u{07}": "\\u0007",
            "\u{08}": "\\u0008",
            "\u{09}": "\\u0009",
            "\u{0A}": "\\u000A",
            "\u{0B}": "\\u000B",
            "\u{0C}": "\\u000C",
            "\u{0D}": "\\u000D",
            "\u{0E}": "\\u000E",
            "\u{0F}": "\\u000F",
            "\u{10}": "\\u0010",
            "\u{11}": "\\u0011",
            "\u{12}": "\\u0012",
            "\u{13}": "\\u0013",
            "\u{14}": "\\u0014",
            "\u{15}": "\\u0015",
            "\u{16}": "\\u0016",
            "\u{17}": "\\u0017",
            "\u{18}": "\\u0018",
            "\u{19}": "\\u0019",
            "\u{1A}": "\\u001A",
            "\u{1B}": "\\u001B",
            "\u{1C}": "\\u001C",
            "\u{1D}": "\\u001D",
            "\u{1E}": "\\u001E",
            "\u{1F}": "\\u001F",
            "\\": "\\u005C",
            "'": "\\u0027",
            "\"": "\\u0022",
            ">": "\\u003E",
            "<": "\\u003C",
            "&": "\\u0026",
            "=": "\\u003D",
            "-": "\\u002D",
            ";": "\\u003B",
            "\u{2028}": "\\u2028",
            "\u{2029}": "\\u2029",
            // Required to pass GRMustache suite test "`javascript.escape` escapes control characters"
            "\r\n": "\\u000D\\u000A",
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
}
