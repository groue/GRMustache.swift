//
//  TemplateRepository.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

public typealias TemplateID = String

public protocol TemplateRepositoryDataSource {
    func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID?
    func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String?
}

public class TemplateRepository {
    public var configuration: Configuration
    public let dataSource: TemplateRepositoryDataSource?
    private var templateASTForTemplateID: [TemplateID: TemplateAST]
    
    public init(dataSource: TemplateRepositoryDataSource? = nil) {
        configuration = Configuration.defaultConfiguration
        templateASTForTemplateID = [:]
        self.dataSource = dataSource
    }
    
    convenience public init(templates: [String: String]) {
        self.init(dataSource: DictionaryDataSource(templates: templates))
    }
    
    convenience public init(directoryPath: String, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init(dataSource: DirectoryDataSource(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding))
    }
    
    convenience public init(baseURL: NSURL, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init(dataSource: URLDataSource(baseURL: baseURL, templateExtension: templateExtension, encoding: encoding))
    }
    
    convenience public init(bundle: NSBundle?, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init(dataSource: BundleDataSource(bundle: bundle ?? NSBundle.mainBundle(), templateExtension: templateExtension, encoding: encoding))
    }
    
    public func template(#string: String, error: NSErrorPointer = nil) -> Template? {
        return self.template(string: string, contentType: configuration.contentType, error: error)
    }
    
    public func template(named name: String, error: NSErrorPointer = nil) -> Template? {
        if let templateAST = templateAST(named: name, relativeToTemplateID: nil, error: error) {
            return Template(repository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    public func reloadTemplates() {
        templateASTForTemplateID.removeAll()
    }
    
    func template(#string: String, contentType: ContentType, error: NSErrorPointer) -> Template? {
        if let templateAST = self.templateAST(string: string, contentType: contentType, templateID: nil, error: error) {
            return Template(repository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    func templateAST(named name: String, relativeToTemplateID templateID: TemplateID?, error: NSErrorPointer) -> TemplateAST? {
        if let templateID = dataSource?.templateIDForName(name, relativeToTemplateID: templateID, inRepository: self) {
            if let templateAST = templateASTForTemplateID[templateID] {
                return templateAST
            } else {
                var dataSourceError: NSError?
                if let templateString = dataSource?.templateStringForTemplateID(templateID, error: &dataSourceError) {
                    let templateAST = TemplateAST()
                    templateASTForTemplateID[templateID] = templateAST
                    if let compiledAST = self.templateAST(string: templateString, contentType: configuration.contentType, templateID: templateID, error: error) {
                        templateAST.updateFromTemplateAST(compiledAST)
                        return templateAST
                    } else {
                        templateASTForTemplateID.removeValueForKey(templateID)
                        return nil
                    }
                } else {
                    if dataSourceError == nil {
                        dataSourceError = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
                    }
                    if error != nil {
                        error.memory = dataSourceError
                    }
                    return nil
                }
            }
        } else {
            if error != nil {
                error.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
            }
            return nil
        }
    }
    
    func templateAST(#string: String, contentType: ContentType, templateID: TemplateID?, error: NSErrorPointer) -> TemplateAST? {
        let compiler = TemplateCompiler(contentType: contentType, repository: self, templateID: templateID)
        let parser = TemplateParser(tokenConsumer: compiler, configuration: configuration)
        parser.parse(string, templateID: templateID)
        return compiler.templateAST(error: error)
    }
    
    
    // MARK: - Private
    
    private class DictionaryDataSource: TemplateRepositoryDataSource {
        let templates: [String: String]
        
        init(templates: [String: String]) {
            self.templates = templates
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            return name
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return templates[templateID]
        }
    }
    
    private class DirectoryDataSource: TemplateRepositoryDataSource {
        let directoryPath: String
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(directoryPath: String, templateExtension: String, encoding: NSStringEncoding) {
            self.directoryPath = directoryPath
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            let templateFilename: String = {
                if self.templateExtension.isEmpty {
                    return normalizedName
                } else {
                    return normalizedName.stringByAppendingPathExtension(self.templateExtension)!
                }
            }()
            
            let templateDirectoryPath: String = {
                if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                    return normalizedBaseTemplateID.stringByDeletingLastPathComponent
                } else {
                    return self.directoryPath
                }
            }()
            
            return templateDirectoryPath.stringByAppendingPathComponent(templateFilename).stringByStandardizingPath
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return NSString(contentsOfFile: templateID, encoding: encoding, error: error)
        }
    }
    
    private class URLDataSource: TemplateRepositoryDataSource {
        let baseURL: NSURL
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(baseURL: NSURL, templateExtension: String, encoding: NSStringEncoding) {
            self.baseURL = baseURL
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            let templateFilename: String = {
                if self.templateExtension.isEmpty {
                    return normalizedName
                } else {
                    return normalizedName.stringByAppendingPathExtension(self.templateExtension)!
                }
                }()
            
            let templateBaseURL: NSURL = {
                if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                    return NSURL(string: normalizedBaseTemplateID)!
                } else {
                    return self.baseURL
                }
            }()
            
            return NSURL(string: templateFilename, relativeToURL: templateBaseURL)!.URLByStandardizingPath!.absoluteString
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return NSString(contentsOfURL: NSURL(string: templateID)!, encoding: encoding, error: error)
        }
    }
    
    private class BundleDataSource: TemplateRepositoryDataSource {
        let bundle: NSBundle
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(bundle: NSBundle, templateExtension: String, encoding: NSStringEncoding) {
            self.bundle = bundle
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository: TemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                var relativePath = normalizedBaseTemplateID.stringByDeletingLastPathComponent
                relativePath = relativePath.stringByReplacingOccurrencesOfString(bundle.resourcePath!, withString:"")
                return bundle.pathForResource(normalizedName, ofType: templateExtension, inDirectory: relativePath)
            } else {
                return bundle.pathForResource(normalizedName, ofType: templateExtension)
            }
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error: NSErrorPointer) -> String? {
            return NSString(contentsOfFile: templateID, encoding: encoding, error: error)
        }
    }
}
