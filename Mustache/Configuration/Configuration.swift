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


/**
Configuration of GRMustache

You have three levels of configuration:

- global, through Mustache.DefaultConfiguration
- per template repository, through TemplateRepository.configuration
- per template, through Template properties

For example:

::

  // Have all templates render text, and avoid HTML-escaping:
  Mustache.DefaultConfiguration.contentType = .Text
  
  // Renders "make clean && make"
  let textTemplate = Template(string: "{{command}}")!
  textTemplate.render(Box(["command": "make clean && make"]))!

  // Have all templates of repository render HTML, and escape rendered values:
  let repository = TemplateRepository()
  repository.configuration.contentType = .HTML
  
  // Renders "&lt;br&gt;"
  let HTMLTemplate = repository.template(string: "{{string}}")!
  HTMLTemplate.render(Box(["string": "<br>"]))!
*/
public struct Configuration {
    
    // =========================================================================
    // MARK: - Creating Factory Configuration
    
    /**
    Returns a factory configuration.
    
    Its contentType is HTML, baseContext empty, tag delimiters "{{" and "}}".
    */
    public init() {
        contentType = .HTML
        baseContext = Context()
        tagStartDelimiter = "{{"
        tagEndDelimiter = "}}"
    }
    
    
    // =========================================================================
    // MARK: - Set Up Configuration
    
    /**
    The content type of strings rendered by templates.
    
    This property affects the HTML-escaping of your data, and the inclusion
    of templates in other templates.
    
    The `.HTML` content type has templates render HTML. This is the default
    behavior. HTML template escape the input of variable tags such as
    `{{name}}`. Use triple mustache tags `{{{content}}}` in order to avoid the
    HTML-escaping.
    
    The `.Text` content type has templates render text. They do not HTML-escape
    their input: `{{name}}` and `{{{name}}}` have identical, non-escaped,
    renderings.
    
    GRMustache safely keeps track of the content type of templates: should a
    HTML template embed a text template, the content of the text template would
    be HTML-escaped.
    
    There is no API to specify the content type of individual templates.
    However, you can use pragma tags right in the content of your templates:
    
    - `{{% CONTENT_TYPE:TEXT }}` turns a template into a text template.
    - `{{% CONTENT_TYPE:HTML }}` turns a template into a HTML template.
    
    Insert those pragma tags early in your templates. For example:
    
    ::
    
      {{! This template renders a bash script. }}
      {{% CONTENT_TYPE:TEXT }}
      export LANG={{ENV.LANG}}
      ...
    
    Should two such pragmas be found in a template content, the last one wins.
    */
    public var contentType: ContentType
    
    /**
    The base context for templates rendering. All templates built with this
    configuration can access values stored in the base context.
    
    The default one is empty.
    
    You can set the base context to some custom context, or extend it with the
    extendBaseContext and registerInBaseContext methods.
    
    ::
    
      Mustache.DefaultConfiguration.baseContext = Context(Box(["foo": "bar"]))
    
      // Renders "bar"
      let template = Template(string: "{{foo}}")!
      template.render()!
    
    :see: extendBaseContext
    :see: registerInBaseContext
    */
    public var baseContext: Context
    
    /**
    Extends the base context with the provided boxed value. All templates built
    with this configuration can access its keys.
    
    ::
    
      Mustache.DefaultConfiguration.extendBaseContext(Box(["foo": "bar"]))
    
      // Renders "bar"
      let template = Template(string: "{{foo}}")!
      template.render()!
    
    :see: baseContext
    :see: registerInBaseContext
    :see: Context.extendedContext
    */
    public mutating func extendBaseContext(box: MustacheBox) {
        baseContext = baseContext.extendedContext(box)
    }
    
    /**
    Registers a key in the base context. All templates built with this
    configuration can access the provided box through this key.
    
    The registered key can not be shadowed by rendered data: it will always
    evaluate to the same value.
    
    ::
    
      Mustache.DefaultConfiguration.registerInBaseContext("foo", Box("bar"))
    
      // Renders "bar"
      let template = Template(string: "{{foo}}")!
      template.render()!
    
      // Renders "bar" again, because the registered key "foo" can not be
      // shadowed.
      template.render(Box(["foo": "qux"]))!
    
    :see: baseContext
    :see: extendBaseContext
    :see: Context.contextWithRegisteredKey
    */
    public mutating func registerInBaseContext(key: String, _ box: MustacheBox) {
        baseContext = baseContext.contextWithRegisteredKey(key, box: box)
    }
    
    /**
    The opening delimiter for Mustache tags. Its default value is `{{`.
    
    You can also change the delimiters right in your templates using a "Set
    Delimiter tag": {{=[[ ]]=}} changes start and end delimiters to [[ and ]].
    */
    public var tagStartDelimiter: String
    
    /**
    The closing delimiter for Mustache tags. Its default value is `}}`.
    
    You can also change the delimiters right in your templates using a "Set
    Delimiter tag": {{=[[ ]]=}} changes start and end delimiters to [[ and ]].
    */
    public var tagEndDelimiter: String
    
}

/**
The default configuration that is used unless specified otherwise by a template
repository.

:see: Configuration
:see: TemplateRepository
*/
public var DefaultConfiguration = Configuration()
