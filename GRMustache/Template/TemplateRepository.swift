//
//  TemplateRepository.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

typealias TemplateID = String

protocol TemplateRepositoryDataSource: class {
    func templateIDForName(name: String, relativeToTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID?
    func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String?
}

public class TemplateRepository {
    var configuration: Configuration
    weak var dataSource: TemplateRepositoryDataSource?
    var templateASTForTemplateID: [TemplateID: TemplateAST]
    
    public init() {
        configuration = Configuration.defaultConfiguration
        templateASTForTemplateID = [:]
    }
    
    convenience public init(templates: [String: String]) {
        self.init()
        strongDataSource = DictionaryDataSource(templates: templates)
        dataSource = strongDataSource
    }
    
    public func templateFromString(string: String, error outError: NSErrorPointer) -> Template? {
        return self.templateFromString(string, contentType: configuration.contentType, error: outError)
    }
    
    func templateFromString(string: String, contentType: ContentType, error outError: NSErrorPointer) -> Template? {
        if let templateAST = self.templateASTFromString(string, contentType: contentType, templateID: nil, error: outError) {
            return Template(templateRepository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    func templateASTNamed(name: String, relativeToTemplateID templateID: TemplateID?, error outError: NSErrorPointer) -> TemplateAST? {
        if let templateID = dataSource?.templateIDForName(name, relativeToTemplateID: templateID, inRepository: self) {
            if let templateAST = templateASTForTemplateID[templateID] {
                return templateAST
            } else {
                var error: NSError?
                if let templateString = dataSource?.templateStringForTemplateID(templateID, error: &error) {
                    let templateAST = TemplateAST()
                    templateASTForTemplateID[templateID] = templateAST
                    if let compiledAST = templateASTFromString(templateString, contentType: configuration.contentType, templateID: templateID, error: outError) {
                        templateAST.updateFromTemplateAST(compiledAST)
                        return templateAST
                    } else {
                        templateASTForTemplateID.removeValueForKey(templateID)
                        return nil
                    }
                } else {
                    if error == nil {
                        error = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
                    }
                    if outError != nil {
                        outError.memory = error
                    }
                    return nil
                }
            }
        } else {
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
            }
            return nil
        }
    }
    
    
    // MARK: - Private
    
    private var strongDataSource: TemplateRepositoryDataSource?
    
    private func templateASTFromString(string: String, contentType: ContentType, templateID: TemplateID?, error outError: NSErrorPointer) -> TemplateAST? {
        let compiler = TemplateCompiler(contentType: contentType, templateRepository: self, templateID: templateID)
        let parser = TemplateParser(tokenConsumer: compiler, configuration: configuration)
        parser.parse(string)
        return compiler.templateAST(error: outError)
    }
    
    class DictionaryDataSource: TemplateRepositoryDataSource {
        let templates: [String: String]
        
        init(templates: [String: String]) {
            self.templates = templates
        }
        
        func templateIDForName(name: String, relativeToTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            return name
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String? {
            return templates[templateID]
        }
    }
}
