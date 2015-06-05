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
    func parser(parser:TemplateParser, didFailWithError error:NSError)
}

final class TemplateParser {
    let tokenConsumer: TemplateTokenConsumer
    private let tagDelimiterPair: TagDelimiterPair
    
    init(tokenConsumer: TemplateTokenConsumer, configuration: Configuration) {
        self.tokenConsumer = tokenConsumer
        self.tagDelimiterPair = configuration.tagDelimiterPair
    }
    
    func parse(templateString:String, templateID: TemplateID?) {
        var currentDelimiters = ParserTagDelimiters(tagDelimiterPair: tagDelimiterPair)
        
        var i = templateString.startIndex
        let end = templateString.endIndex
        
        var state: State = .Start
        var stateStart = i
        
        var lineNumber = 1
        var startLineNumber = lineNumber
        
        let atString = { (string: String?) -> Bool in
            return string != nil && templateString.substringFromIndex(i).hasPrefix(string!)
        }
        
        while i < end {
            let c = templateString[i]
            
            switch state {
            case .Start:
                if c == "\n" {
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .Text
                    
                    ++lineNumber
                } else if atString(currentDelimiters.unescapedTagStart) {
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .UnescapedTag
                    i = advance(i, currentDelimiters.unescapedTagStartLength).predecessor()
                } else if atString(currentDelimiters.setDelimitersStart) {
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .SetDelimitersTag
                    i = advance(i, currentDelimiters.setDelimitersStartLength).predecessor()
                } else if atString(currentDelimiters.tagDelimiterPair.0) {
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .Tag
                    i = advance(i, currentDelimiters.tagStartLength).predecessor()
                } else {
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .Text
                }
            case .Text:
                if c == "\n" {
                    ++lineNumber
                } else if atString(currentDelimiters.unescapedTagStart) {
                    if stateStart != i {
                        let range = stateStart..<i
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: stateStart..<i,
                            type: .Text(text: templateString[range]),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .UnescapedTag
                    i = advance(i, currentDelimiters.unescapedTagStartLength).predecessor()
                } else if atString(currentDelimiters.setDelimitersStart) {
                    if stateStart != i {
                        let range = stateStart..<i
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: stateStart..<i,
                            type: .Text(text: templateString[range]),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .SetDelimitersTag
                    i = advance(i, currentDelimiters.setDelimitersStartLength).predecessor()
                } else if atString(currentDelimiters.tagDelimiterPair.0) {
                    if stateStart != i {
                        let range = stateStart..<i
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: stateStart..<i,
                            type: .Text(text: templateString[range]),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    startLineNumber = lineNumber
                    stateStart = i
                    state = .Tag
                    i = advance(i, currentDelimiters.tagStartLength).predecessor()
                }
            case .Tag:
                if c == "\n" {
                    ++lineNumber
                } else if atString(currentDelimiters.tagDelimiterPair.1) {
                    let tagInitialIndex = advance(stateStart, currentDelimiters.tagStartLength)
                    let tagInitial = templateString[tagInitialIndex]
                    let tokenRange = stateStart..<advance(i, currentDelimiters.tagEndLength)
                    switch tagInitial {
                    case "!":
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .Comment,
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "#":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .Section(
                                content: content,
                                tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "^":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .InvertedSection(
                                content: content,
                                tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "$":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .InheritableSection(content: content),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "/":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .Close(content: content),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case ">":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .Partial(content: content),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "<":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .InheritedPartial(content: content),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "&":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .UnescapedVariable(
                                content: content,
                                tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    case "%":
                        let content = templateString.substringWithRange(tagInitialIndex.successor()..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .Pragma(content: content),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    default:
                        let content = templateString.substringWithRange(tagInitialIndex..<i)
                        let token = TemplateToken(
                            lineNumber: startLineNumber,
                            templateString: templateString,
                            range: tokenRange,
                            type: .EscapedVariable(
                                content: content,
                                tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                            templateID: templateID)
                        if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                            return
                        }
                    }
                    stateStart = advance(i, currentDelimiters.tagEndLength)
                    state = .Start
                    i = advance(i, currentDelimiters.tagEndLength).predecessor()
                }
                break
            case .UnescapedTag:
                if c == "\n" {
                    ++lineNumber
                } else if atString(currentDelimiters.unescapedTagEnd) {
                    let tagInitialIndex = advance(stateStart, currentDelimiters.unescapedTagStartLength)
                    let content = templateString.substringWithRange(tagInitialIndex..<i)
                    let token = TemplateToken(
                        lineNumber: startLineNumber,
                        templateString: templateString,
                        range: stateStart..<advance(i, currentDelimiters.unescapedTagEndLength),
                        type: .UnescapedVariable(
                            content: content,
                            tagDelimiterPair: currentDelimiters.tagDelimiterPair),
                        templateID: templateID)
                    if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                        return
                    }
                    stateStart = advance(i, currentDelimiters.unescapedTagEndLength)
                    state = .Start
                    i = advance(i, currentDelimiters.unescapedTagEndLength).predecessor()
                }
            case .SetDelimitersTag:
                if c == "\n" {
                    ++lineNumber
                } else if atString(currentDelimiters.setDelimitersEnd) {
                    let tagInitialIndex = advance(stateStart, currentDelimiters.setDelimitersStartLength)
                    let content = templateString.substringWithRange(tagInitialIndex..<i)
                    let newDelimiters = content.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter { count($0) > 0 }
                    if (newDelimiters.count != 2) {
                        failWithParseError(lineNumber: lineNumber, templateID: templateID, description: "Invalid set delimiters tag")
                        return;
                    }
                    
                    let token = TemplateToken(
                        lineNumber: startLineNumber,
                        templateString: templateString,
                        range: stateStart..<advance(i, currentDelimiters.setDelimitersEndLength),
                        type: .SetDelimiters,
                        templateID: templateID)
                    if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                        return
                    }
                    
                    stateStart = advance(i, currentDelimiters.setDelimitersEndLength)
                    state = .Start;
                    i = advance(i, currentDelimiters.setDelimitersEndLength).predecessor()
                    
                    currentDelimiters = ParserTagDelimiters(tagDelimiterPair: (newDelimiters[0], newDelimiters[1]))
                }
            }
            
            i = i.successor()
        }
        
        
        // EOF
        
        switch state {
        case .Start:
            break
        case .Text:
            let range = stateStart..<end
            let token = TemplateToken(
                lineNumber: startLineNumber,
                templateString: templateString,
                range: range,
                type: .Text(text: templateString[range]),
                templateID: templateID)
            if !tokenConsumer.parser(self, shouldContinueAfterParsingToken: token) {
                return
            }
        case .Tag, .UnescapedTag, .SetDelimitersTag:
            failWithParseError(lineNumber: startLineNumber, templateID: templateID, description: "Unclosed Mustache tag")
            return
        }
    }
    
    
    // MARK: - Private
    
    private enum State {
        case Start
        case Text
        case Tag
        case UnescapedTag
        case SetDelimitersTag
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
            
            tagStartLength = distance(tagDelimiterPair.0.startIndex, tagDelimiterPair.0.endIndex)
            tagEndLength = distance(tagDelimiterPair.1.startIndex, tagDelimiterPair.1.endIndex)
            
            let usesStandardDelimiters = (tagDelimiterPair.0 == "{{") && (tagDelimiterPair.1 == "}}")
            unescapedTagStart = usesStandardDelimiters ? "{{{" : nil
            unescapedTagStartLength = unescapedTagStart != nil ? distance(unescapedTagStart!.startIndex, unescapedTagStart!.endIndex) : 0
            unescapedTagEnd = usesStandardDelimiters ? "}}}" : nil
            unescapedTagEndLength = unescapedTagEnd != nil ? distance(unescapedTagEnd!.startIndex, unescapedTagEnd!.endIndex) : 0
            
            setDelimitersStart = "\(tagDelimiterPair.0)="
            setDelimitersStartLength = distance(setDelimitersStart.startIndex, setDelimitersStart.endIndex)
            setDelimitersEnd = "=\(tagDelimiterPair.1)"
            setDelimitersEndLength = distance(setDelimitersEnd.startIndex, setDelimitersEnd.endIndex)
        }
    }
    
    private func failWithParseError(#lineNumber: Int, templateID: TemplateID?, description: String) {
        let localizedDescription: String
        if let templateID = templateID {
            localizedDescription = "Parse error at line \(lineNumber) of template \(templateID): \(description)"
        } else {
            localizedDescription = "Parse error at line \(lineNumber): \(description)"
        }
        var error = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeParseError, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
        tokenConsumer.parser(self, didFailWithError: error)
    }
}
