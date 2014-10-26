//
//  TemplateRepository.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

public class TemplateRepository {
    var configuration: Configuration
    
    public init() {
        self.configuration = Configuration.defaultConfiguration
    }
    
    public func templateFromString(string: String, error outError: NSErrorPointer) -> Template? {
        return self.templateFromString(string, contentType: configuration.contentType, error: outError)
    }
    
    func templateFromString(string: String, contentType: ContentType, error outError: NSErrorPointer) -> Template? {
        if let templateAST = self.templateASTFromString(string, contentType: contentType, error: outError) {
            return Template(templateRepository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    
    // MARK: - Private
    
    private func templateASTFromString(string: String, contentType: ContentType, error outError: NSErrorPointer) -> TemplateAST? {
        let compiler = TemplateCompiler(contentType: contentType)
        let parser = TemplateParser(tokenConsumer: compiler, configuration: configuration)
        parser.parse(string)
        return compiler.templateAST(error: outError)
    }
}
