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
        var delimiters = Delimiters(tagStart: tagStartDelimiter, tagEnd: tagEndDelimiter)
        
        var i = templateString.startIndex
        let end = templateString.endIndex
        
        var state: State = .Start
        var stateStart = i
        
        var lineNumber = 0
        var tagLineNumber = lineNumber
        
        var atString = { (string: String?) -> Bool in
            return string != nil && templateString.substringFromIndex(i).hasPrefix(string!)
        }
        
        while i < end {
            let c = templateString[i]
            
            switch state {
            case .Start:
                if c == "\n" {
                    ++lineNumber
                    stateStart = i
                    state = .Text
                } else if atString(delimiters.unescapedTagStart) {
                    tagLineNumber = lineNumber
                    stateStart = i
                    state = .UnescapedTag
                    i = advance(i, delimiters.unescapedTagStartLength).predecessor()
                } else if atString(delimiters.setDelimitersStart) {
                    tagLineNumber = lineNumber
                    stateStart = i
                    state = .SetDelimitersTag
                    i = advance(i, delimiters.setDelimitersStartLength).predecessor()
                } else if atString(delimiters.tagStart) {
                    tagLineNumber = lineNumber
                    stateStart = i
                    state = .Tag
                    i = advance(i, delimiters.tagStartLength).predecessor()
                } else {
                    stateStart = i
                    state = .Text
                }
            case .Text:
                if c == "\n" {
                    ++lineNumber
                } else if atString(delimiters.unescapedTagStart) {
                    if stateStart != i {
                        let token = TemplateToken(type: .Text(text: templateString.substringWithRange(stateStart..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    tagLineNumber = lineNumber
                    stateStart = i
                    state = .UnescapedTag
                    i = advance(i, delimiters.unescapedTagStartLength).predecessor()
                } else if atString(delimiters.setDelimitersStart) {
                    if stateStart != i {
                        let token = TemplateToken(type: .Text(text: templateString.substringWithRange(stateStart..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    tagLineNumber = lineNumber
                    stateStart = i
                    state = .SetDelimitersTag
                    i = advance(i, delimiters.setDelimitersStartLength).predecessor()
                } else if atString(delimiters.tagStart) {
                    if stateStart != i {
                        let token = TemplateToken(type: .Text(text: templateString.substringWithRange(stateStart..<i)))
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    tagLineNumber = lineNumber
                    stateStart = i
                    state = .Tag
                    i = advance(i, delimiters.tagStartLength).predecessor()
                }
            case .Tag:
                if c == "\n" {
                    ++lineNumber
                } else if atString(tagEndDelimiter) {
                    let tagInitialIndex = advance(stateStart, delimiters.tagStartLength)
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
                    stateStart = advance(i, delimiters.tagEndLength)
                    state = .Start
                    i = advance(i, delimiters.tagEndLength).predecessor()
                }
                break
            case .UnescapedTag:
                if c == "\n" {
                    ++lineNumber
                } else if atString(delimiters.unescapedTagEnd) {
                    let tagInitialIndex = advance(stateStart, delimiters.unescapedTagStartLength)
                    let token = TemplateToken(type: .EscapedVariable(content: templateString.substringWithRange(tagInitialIndex.successor()..<i)))
                    if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                        return
                    }
                    stateStart = advance(i, delimiters.unescapedTagEndLength)
                    state = .Start
                    i = advance(i, delimiters.unescapedTagEndLength).predecessor()
                }
            case .SetDelimitersTag:
                if c == "\n" {
                    ++lineNumber
                } else if atString(delimiters.setDelimitersEnd) {
                    let tagInitialIndex = advance(stateStart, delimiters.setDelimitersStartLength)
                    let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                    let newDelimiters = content.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter { countElements($0) > 0 }
                    if (newDelimiters.count != 2) {
                        failWithParseError(lineNumber: lineNumber, description: "Invalid set delimiters tag")
                        return;
                    }
                    
                    let token = TemplateToken(type: .SetDelimiters)
                    if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                        return
                    }
                    
                    stateStart = advance(i, delimiters.setDelimitersEndLength)
                    state = .Start;
                    i = advance(i, delimiters.setDelimitersEndLength).predecessor()
                    
                    delimiters = Delimiters(tagStart: newDelimiters[0], tagEnd: newDelimiters[1])
                }
            }
            
            i = i.successor()
        }
        
        
        // EOF
        
        switch state {
        case .Start:
            break
        case .Text:
            let token = TemplateToken(type: .Text(text: templateString.substringWithRange(stateStart..<end)))
            if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                return
            }
        case .Tag, .UnescapedTag, .SetDelimitersTag:
            failWithParseError(lineNumber: lineNumber, description: "Unclosed Mustache tag")
            return
        }
    }
    
    
    // MARK: - Private
    
    enum State {
        case Start
        case Text
        case Tag
        case UnescapedTag
        case SetDelimitersTag
    }
    
    struct Delimiters {
        let tagStart: String
        let tagStartLength: Int
        let tagEnd: String
        let tagEndLength: Int
        let unescapedTagStart: String?
        let unescapedTagStartLength: Int
        let unescapedTagEnd: String?
        let unescapedTagEndLength: Int
        let setDelimitersStart: String
        let setDelimitersStartLength: Int
        let setDelimitersEnd: String
        let setDelimitersEndLength: Int
        
        init(tagStart: String, tagEnd: String) {
            self.tagStart = tagStart
            self.tagEnd = tagEnd
            
            tagStartLength = distance(tagStart.startIndex, tagStart.endIndex)
            tagEndLength = distance(tagEnd.startIndex, tagEnd.endIndex)
            
            let usesStandardDelimiters = (tagStart == "{{") && (tagEnd == "{{")
            unescapedTagStart = usesStandardDelimiters ? "{{{" : nil
            unescapedTagStartLength = unescapedTagStart != nil ? distance(unescapedTagStart!.startIndex, unescapedTagStart!.endIndex) : 0
            unescapedTagEnd = usesStandardDelimiters ? "}}}" : nil
            unescapedTagEndLength = unescapedTagEnd != nil ? distance(unescapedTagEnd!.startIndex, unescapedTagEnd!.endIndex) : 0
            
            setDelimitersStart = "\(tagStart)="
            setDelimitersStartLength = distance(setDelimitersStart.startIndex, setDelimitersStart.endIndex)
            setDelimitersEnd = "=\(tagEnd)"
            setDelimitersEndLength = distance(setDelimitersEnd.startIndex, setDelimitersEnd.endIndex)
        }
    }
    
    func failWithParseError(#lineNumber: Int, description: String) {
        let userInfo = [NSLocalizedDescriptionKey: "Parse error at line \(lineNumber): \(description)"]
        var error = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: userInfo)
        tokenConsumer.parser(self, didFailWithError: error)
    }
}
