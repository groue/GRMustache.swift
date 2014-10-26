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
    let configuration: Configuration
    
    init(tokenConsumer: TemplateTokenConsumer, configuration: Configuration) {
        self.tokenConsumer = tokenConsumer
        self.configuration = configuration
    }
    
    func parse(templateString:String) {
        tokenConsumer.parser(self, shouldContinueAfterParsingToken: TemplateToken(type: .Text(text: "<")))
        tokenConsumer.parser(self, shouldContinueAfterParsingToken: TemplateToken(type: .EscapedVariable(content: "name")))
        tokenConsumer.parser(self, shouldContinueAfterParsingToken: TemplateToken(type: .Text(text: ">")))
    }
}
