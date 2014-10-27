//
//  TemplateParser.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

protocol TemplateTokenConsumer {
    func parser(parser:TemplateParser, shouldContinueAfterParsingToken token:TemplateToken) -> Bool
    func parser(parser:TemplateParser, didFailWithError error:NSError)
}

enum TemplateParserState {
    case Start
    case Text
    case Tag
    case UnescapedTag
    case SetDelimiterTag
}

class TemplateParser {
    let tokenConsumer: TemplateTokenConsumer
    let tagStartDelimiter: String
    let tagEndDelimiter: String
    
    init(tokenConsumer: TemplateTokenConsumer, configuration: Configuration) {
        self.tokenConsumer = tokenConsumer
        self.tagStartDelimiter = configuration.tagStartDelimiter
        self.tagEndDelimiter = configuration.tagEndDelimiter
    }
    
    func parse(templateString:String) {
        var tagStartDelimiter = self.tagStartDelimiter
        var tagStartDelimiterLength = distance(tagStartDelimiter.startIndex, tagStartDelimiter.endIndex)
        var tagEndDelimiter = self.tagEndDelimiter
        var tagEndDelimiterLength = distance(tagEndDelimiter.startIndex, tagEndDelimiter.endIndex)
        var usesStandardDelimiters = (tagStartDelimiter == "{{") && (tagStartDelimiter == "{{")
        var unescapedTagStartDelimiter: String? = usesStandardDelimiters ? "{{{" : nil
        var unescapedTagStartDelimiterLength = unescapedTagStartDelimiter != nil ? distance(unescapedTagStartDelimiter!.startIndex, unescapedTagStartDelimiter!.endIndex) : 0
        var unescapedTagEndDelimiter: String? = usesStandardDelimiters ? "}}}" : nil
        var unescapedTagEndDelimiterLength = unescapedTagEndDelimiter != nil ? distance(unescapedTagEndDelimiter!.startIndex, unescapedTagEndDelimiter!.endIndex) : 0
        var setDelimitersTagStartDelimiter = "\(tagStartDelimiter)="
        var setDelimitersTagStartDelimiterLength = distance(setDelimitersTagStartDelimiter.startIndex, setDelimitersTagStartDelimiter.endIndex)
        var setDelimitersTagEndDelimiter = "=\(tagEndDelimiter)"
        
        var state: TemplateParserState = .Start
        var lineNumber = 0
        var i = templateString.startIndex
        let end = templateString.endIndex
        var start = i
        var tagStartLineNumber = lineNumber
        while i < end {
            let c = templateString[i]
            
            switch state {
            case .Start:
                if c == "\n" {
                    ++lineNumber
                    start = i
                    state = .Text
                } else if unescapedTagStartDelimiter != nil && templateString.substringFromIndex(i).hasPrefix(unescapedTagStartDelimiter!) {
                    tagStartLineNumber = lineNumber
                    start = i
                    state = .UnescapedTag
                    i = advance(i, unescapedTagStartDelimiterLength).predecessor()
                } else if templateString.substringFromIndex(i).hasPrefix(setDelimitersTagStartDelimiter) {
                    tagStartLineNumber = lineNumber
                    start = i
                    state = .SetDelimiterTag
                    i = advance(i, setDelimitersTagStartDelimiterLength).predecessor()
                } else if templateString.substringFromIndex(i).hasPrefix(tagStartDelimiter) {
                    tagStartLineNumber = lineNumber
                    start = i
                    state = .Tag
                    i = advance(i, tagStartDelimiterLength).predecessor()
                } else {
                    start = i
                    state = .Text
                }
            case .Text:
                if c == "\n" {
                    ++lineNumber
                } else if unescapedTagStartDelimiter != nil && templateString.substringFromIndex(i).hasPrefix(unescapedTagStartDelimiter!) {
                    if start != i {
                        let token = TemplateToken(type: .Text(text: templateString.substringWithRange(start..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    tagStartLineNumber = lineNumber
                    start = i
                    state = .UnescapedTag
                    i = advance(i, unescapedTagStartDelimiterLength).predecessor()
                } else if templateString.substringFromIndex(i).hasPrefix(setDelimitersTagStartDelimiter) {
                    if start != i {
                        let token = TemplateToken(type: .Text(text: templateString.substringWithRange(start..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    tagStartLineNumber = lineNumber
                    start = i
                    state = .SetDelimiterTag
                    i = advance(i, setDelimitersTagStartDelimiterLength).predecessor()
                } else if templateString.substringFromIndex(i).hasPrefix(tagStartDelimiter) {
                    if start != i {
                        let token = TemplateToken(type: .Text(text: templateString.substringWithRange(start..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    tagStartLineNumber = lineNumber
                    start = i
                    state = .Tag
                    i = advance(i, tagStartDelimiterLength).predecessor()
                }
            case .Tag:
                if c == "\n" {
                    ++lineNumber
                } else if templateString.substringFromIndex(i).hasPrefix(tagEndDelimiter) {
                    let tagInitialIndex = advance(start, tagStartDelimiterLength)
                    let tagInitial = templateString[tagInitialIndex]
                    switch tagInitial {
                    case "!":
                        let token = TemplateToken(type: .Comment)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "#":
                        let token = TemplateToken(type: .Section(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "^":
                        let token = TemplateToken(type: .InvertedSection(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "$":
                        let token = TemplateToken(type: .InheritableSection(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "/":
                        let token = TemplateToken(type: .Close(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case ">":
                        let token = TemplateToken(type: .Partial(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "<":
                        let token = TemplateToken(type: .InheritablePartial(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "{":
                        let token = TemplateToken(type: .UnescapedVariable(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "&":
                        let token = TemplateToken(type: .UnescapedVariable(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "%":
                        let token = TemplateToken(type: .Pragma(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    default:
                        let token = TemplateToken(type: .EscapedVariable(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    start = advance(i, tagEndDelimiterLength)
                    state = .Start
                    i = advance(i, tagEndDelimiterLength).predecessor()
                }
                break
            case .UnescapedTag:
                if c == "\n" {
                    ++lineNumber
                } else if unescapedTagEndDelimiter != nil && templateString.substringFromIndex(i).hasPrefix(unescapedTagEndDelimiter!) {
                    let tagInitialIndex = advance(start, unescapedTagStartDelimiterLength)
                    let token = TemplateToken(type: .EscapedVariable(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                    if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                        return
                    }
                    start = advance(i, unescapedTagEndDelimiterLength)
                    state = .Start
                    i = advance(i, unescapedTagEndDelimiterLength).predecessor()
                }
            case .SetDelimiterTag:
            }
            
            i = i.successor()
        }
        tokenConsumer.parser(self, shouldContinueAfterParsingToken: TemplateToken(type: .Text(text: "<")))
        tokenConsumer.parser(self, shouldContinueAfterParsingToken: TemplateToken(type: .EscapedVariable(content: "name")))
        tokenConsumer.parser(self, shouldContinueAfterParsingToken: TemplateToken(type: .Text(text: ">")))
    }
}
