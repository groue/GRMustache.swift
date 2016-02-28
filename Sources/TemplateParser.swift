// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

protocol TemplateTokenConsumer {
    func parser(parser:TemplateParser, shouldContinueAfterParsingToken token:TemplateToken) -> Bool
    func parser(parser:TemplateParser, didFailWithError error:ErrorType)
}

final class TemplateParser {
    let tokenConsumer: TemplateTokenConsumer
    private let tagDelimiterPair: TagDelimiterPair
    
    init(tokenConsumer: TemplateTokenConsumer, tagDelimiterPair: TagDelimiterPair) {
        self.tokenConsumer = tokenConsumer
        self.tagDelimiterPair = tagDelimiterPair
    }
    
    func parse(templateString:String, templateID: TemplateID?) {
        var currentDelimiters = ParserTagDelimiters(tagDelimiterPair: tagDelimiterPair)
        let templateCharacters = templateString.characters
        
        let atString = { (index: String.Index, string: String?) -> Bool in
            guard let string = string else {
                return false
            }
            let endIndex = index.advancedBy(string.characters.count, limit: templateCharacters.endIndex)
            return templateCharacters[index..<endIndex].startsWith(string.characters)
        }
        
        var state: State = .Start
        var lineNumber = 1
        var i = templateString.startIndex
        let end = templateString.endIndex
        
        while i < end {
            let c = templateString[i]
            
            switch state {
            case .Start:
                if c == "\n" {
                    state = .Text(startIndex: i, startLineNumber: lineNumber)
                    lineNumber += 1
                } else if atString(i, currentDelimiters.unescapedTagStart) {
                    state = .UnescapedTag(startIndex: i, startLineNumber: lineNumber)
                    i = i.advancedBy(currentDelimiters.unescapedTagStartLength).predecessor()
                } else if atString(i, currentDelimiters.setDelimitersStart) {
                    state = .SetDelimitersTag(startIndex: i, startLineNumber: lineNumber)
                    i = i.advancedBy(currentDelimiters.setDelimitersStartLength).predecessor()
                } else if atString(i, currentDelimiters.tagDelimiterPair.0) {
                    state = .Tag(startIndex: i, startLineNumber: lineNumber)
                    i = i.advancedBy(currentDelimiters.tagStartLength).predecessor()
                } else {
                    state = .Text(startIndex: i, startLineNumber: lineNumber)
                }
            case .Text(let startIndex, let startLineNumber):
                if c == "\n" {
                    lineNumber += 1
                } else if atString(i, currentDelimiters.unescapedTagStart) {
                    if startIndex != i {
                        let range = startIndex..<i
                        let token = TemplateToken(
                            type: .Text(text: templateString[range]),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: startIndex..<i)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    state = .UnescapedTag(startIndex: i, startLineNumber: lineNumber)
                    i = i.advancedBy(currentDelimiters.unescapedTagStartLength).predecessor()
                } else if atString(i, currentDelimiters.setDelimitersStart) {
                    if startIndex != i {
                        let range = startIndex..<i
                        let token = TemplateToken(
                            type: .Text(text: templateString[range]),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: startIndex..<i)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    state = .SetDelimitersTag(startIndex: i, startLineNumber: lineNumber)
                    i = i.advancedBy(currentDelimiters.setDelimitersStartLength).predecessor()
                } else if atString(i, currentDelimiters.tagDelimiterPair.0) {
                    if startIndex != i {
                        let range = startIndex..<i
                        let token = TemplateToken(
                            type: .Text(text: templateString[range]),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: startIndex..<i)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    state = .Tag(startIndex: i, startLineNumber: lineNumber)
                    i = i.advancedBy(currentDelimiters.tagStartLength).predecessor()
                }
            case .Tag(let startIndex, let startLineNumber):
                if c == "\n" {
                    lineNumber += 1
                } else if atString(i, currentDelimiters.tagDelimiterPair.1) {
                    let tagInitialIndex = startIndex.advancedBy(currentDelimiters.tagStartLength)
                    let tagInitial = templateString[tagInitialIndex]
                    let tokenRange = startIndex..<i.advancedBy(currentDelimiters.tagEndLength)
                    switch tagInitial {
                    case "!":
                        let token = TemplateToken(
                            type: .Comment,
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "#":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .Section(content: content, tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "^":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .InvertedSection(content: content, tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "$":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .Block(content: content),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "/":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .Close(content: content),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case ">":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .Partial(content: content),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "<":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .PartialOverride(content: content),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "&":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .UnescapedVariable(content: content, tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "%":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            type: .Pragma(content: content),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    default:
                        let content = templateString.substringWithRange(tagInitialIndex..<i)
                        let token = TemplateToken(
                            type: .EscapedVariable(content: content, tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            lineNumber: startLineNumber,
                            templateID: templateID,
                            templateString: templateString,
                            range: tokenRange)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    state = .Start
                    i = i.advancedBy(currentDelimiters.tagEndLength).predecessor()
                }
                break
            case .UnescapedTag(let startIndex, let startLineNumber):
                if c == "\n" {
                    lineNumber += 1
                } else if atString(i, currentDelimiters.unescapedTagEnd) {
                    let tagInitialIndex = startIndex.advancedBy(currentDelimiters.unescapedTagStartLength)
                    let content = templateString.substringWithRange(tagInitialIndex..<i)
                    let token = TemplateToken(
                        type: .UnescapedVariable(content: content, tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                        lineNumber: startLineNumber,
                        templateID: templateID,
                        templateString: templateString,
                        range: startIndex..<i.advancedBy(currentDelimiters.unescapedTagEndLength))
                    if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                        return
                    }
                    state = .Start
                    i = i.advancedBy(currentDelimiters.unescapedTagEndLength).predecessor()
                }
            case .SetDelimitersTag(let startIndex, let startLineNumber):
                if c == "\n" {
                    lineNumber += 1
                } else if atString(i, currentDelimiters.setDelimitersEnd) {
                    let tagInitialIndex = startIndex.advancedBy(currentDelimiters.setDelimitersStartLength)
                    let content = templateString.substringWithRange(tagInitialIndex..<i)
                    let newDelimiters = content.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter { $0.characters.count > 0 }
                    if (newDelimiters.count != 2) {
                        let error = MustacheError(kind: .ParseError, message: "Invalid set delimiters tag", templateID: templateID, lineNumber: startLineNumber)
                        tokenConsumer.parser(self, didFailWithError: error)
                        return;
                    }
                    
                    let token = TemplateToken(
                        type: .SetDelimiters,
                        lineNumber: startLineNumber,
                        templateID: templateID,
                        templateString: templateString,
                        range: startIndex..<i.advancedBy(currentDelimiters.setDelimitersEndLength))
                    if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                        return
                    }
                    
                    state = .Start
                    i = i.advancedBy(currentDelimiters.setDelimitersEndLength).predecessor()
                    
                    currentDelimiters = ParserTagDelimiters(tagDelimiterPair: (newDelimiters[0], newDelimiters[1]))
                }
            }
            
            i = i.successor()
        }
        
        
        // EOF
        
        switch state {
        case .Start:
            break
        case .Text(let startIndex, let startLineNumber):
            let range = startIndex..<end
            let token = TemplateToken(
                type: .Text(text: templateString[range]),
                lineNumber: startLineNumber,
                templateID: templateID,
                templateString: templateString,
                range: range)
            tokenConsumer.parser(self, shouldContinueAfterParsingToken: token)
        case .Tag(_, let startLineNumber):
            let error = MustacheError(kind: .ParseError, message: "Unclosed Mustache tag", templateID: templateID, lineNumber: startLineNumber)
            tokenConsumer.parser(self, didFailWithError: error)
        case .UnescapedTag(_, let startLineNumber):
            let error = MustacheError(kind: .ParseError, message: "Unclosed Mustache tag", templateID: templateID, lineNumber: startLineNumber)
            tokenConsumer.parser(self, didFailWithError: error)
        case .SetDelimitersTag(_, let startLineNumber):
            let error = MustacheError(kind: .ParseError, message: "Unclosed Mustache tag", templateID: templateID, lineNumber: startLineNumber)
            tokenConsumer.parser(self, didFailWithError: error)
        }
    }
    
    
    // MARK: - Private
    
    private enum State {
        case Start
        case Text(startIndex: String.Index, startLineNumber: Int)
        case Tag(startIndex: String.Index, startLineNumber: Int)
        case UnescapedTag(startIndex: String.Index, startLineNumber: Int)
        case SetDelimitersTag(startIndex: String.Index, startLineNumber: Int)
    }
    
    private struct ParserTagDelimiters {
        let tagDelimiterPair : TagDelimiterPair
        let tagStartLength: Int
        let tagEndLength: Int
        let unescapedTagStart: String?
        let unescapedTagStartLength: Int
        let unescapedTagEnd: String?
        let unescapedTagEndLength: Int
        let setDelimitersStart: String
        let setDelimitersStartLength: Int
        let setDelimitersEnd: String
        let setDelimitersEndLength: Int
        
        init(tagDelimiterPair : TagDelimiterPair) {
            self.tagDelimiterPair = tagDelimiterPair
            
            tagStartLength = tagDelimiterPair.0.startIndex.distanceTo(tagDelimiterPair.0.endIndex)
            tagEndLength = tagDelimiterPair.1.startIndex.distanceTo(tagDelimiterPair.1.endIndex)
            
            let usesStandardDelimiters = (tagDelimiterPair.0 == "{{") && (tagDelimiterPair.1 == "}}")
            unescapedTagStart = usesStandardDelimiters ? "{{{" : nil
            unescapedTagStartLength = unescapedTagStart != nil ? unescapedTagStart!.startIndex.distanceTo(unescapedTagStart!.endIndex) : 0
            unescapedTagEnd = usesStandardDelimiters ? "}}}" : nil
            unescapedTagEndLength = unescapedTagEnd != nil ? unescapedTagEnd!.startIndex.distanceTo(unescapedTagEnd!.endIndex) : 0
            
            setDelimitersStart = "\(tagDelimiterPair.0)="
            setDelimitersStartLength = setDelimitersStart.startIndex.distanceTo(setDelimitersStart.endIndex)
            setDelimitersEnd = "=\(tagDelimiterPair.1)"
            setDelimitersEndLength = setDelimitersEnd.startIndex.distanceTo(setDelimitersEnd.endIndex)
        }
    }
}
