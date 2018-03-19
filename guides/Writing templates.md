## Writing templates

Sourcery supports templates written in Stencil, Swift and even JavaScript.

Dicsovered types can be accessed in templates via global context with following properties:

 - `types: Types` - access collections of types, i.e. `types.implementing.AutoCoding` (`types.implementing["AutoCoding"]` in swift templates). See [Types](https://cdn.rawgit.com/krzysztofzablocki/Sourcery/master/docs/Classes/Types.html).
 - `type: [String: Type]` - access types by their names, i.e. `type.MyType` (`type["MyType"]` in swift templates)
 - `arguments: [String: NSObject]` - access additional parameters passed with `--args` command line flag or set in `.sourcery.yml` file

> Tip: Make sure you leverage Sourcery built-in daemon to make writing templates a pleasure:
you can open template side-by-side with generated code and see it change live.

## What are _known_ and _unknown_ types

Currently Sourcery only scans files from paths or targets that you tell it to scan. This way it can get full information about types _defined_ in these sources. These types are considered _known_ types. For each of known types Sourcery provides `Type` object. You can get it for example by its name from `types` collection. `Type` object contains information about whether type that it describes is a struct, enum, class or a protocol, what are its properties and methods, what protocols it implements and so on. This is done recursively, so if you have a class that inherits from another class (or struct that implements a protocol) and they are both known types you will have information about both of them and you will be able to access parent type's `Type` object using `type.inherits.TypeName` (or `type.implements.ProtocolName`).

Everything _defined_ outside of scanned sources is considered as _unknown_ types. For such types Sourcery doesn't provide `Type` object. For that reason variables (and other "typed" types, like method parameters etc.) of such types will only contain `typeName` property, but their `type` property will be `nil`.

If you have an extension of unknown type defined in scanned sources Sourcery will create `Type` for it (it's `kind` property will be `extension`). But this object will contain only declarations defined in this extension. Several extensions of unknown type will be merged into one `Type` object the same way as extensions of known types.

See [#87](https://github.com/krzysztofzablocki/Sourcery/issues/87) for details.

## Stencil templates

[Stencil](http://stencil.fuller.li/en/latest/) is a simple and powerful template language for Swift. It provides a syntax similar to Django and Mustache.
Sourcery also uses its extension [StencilSwiftKit](https://github.com/SwiftGen/StencilSwiftKit) so you have access to additional nodes and filteres defined there.

**Example**: [Equality.stencil](https://github.com/krzysztofzablocki/Sourcery/blob/master/Sourcery/Templates/Equality.stencil)

### Custom Stencil tags and filters

- `{{ name|upperFirstLetter }}` - makes first letter in `name` uppercase
- `{{ name|lowerFirstLetter }}` - makes first letter in `name` lowercase
- `{{ name|replace:"substring","replacement" }}` - replaces occurances of `substring` with `replacement` in `name` (case sensitive)
- `{% if name|contains:"Foo" %}` - check if `name` contains arbitrary substring, can be negated with `!` prefix.
- `{% if name|hasPrefix:"Foo" %}`- check if `name` starts with arbitrary substring, can be negated with `!` prefix.
- `{% if name|hasSuffix:"Foo" %}`- check if `name` ends with arbitrary substring, can be negated with `!` prefix.
- `static`, `instance`, `computed`, `stored`, `tuple` - can be used on Variable[s] as filter e.g. `{% for var in variables|instance %}`, can be negated with `!` prefix.
- `static`, `instance`, `class`, `initializer` - can be used on Method[s] as filter e.g. `{% for method in allMethods|instance %}`, can be negated with `!` prefix.
- `enum`, `class`, `struct`, `protocol` - can be used for Type[s] as filter, can be negated with `!` prefix.
- `based`, `implements`, `inherits` - can be used for Type[s], Variable[s], Associated value[s], can be negated with `!` prefix.
- `count` - can be used to get count of filtered array
- `annotated` - can be used on Type[s], Variable[s], Method[s] and Enum Case[s] to filter by annotation, e.g. `{% for var in variable|annotated:"skipDescription" %}`, can be negated with `!` prefix.
- `public`, `open`, `internal`, `private`, `fileprivate` - can be used on Type[s] and Method[s] to filter by access level, can be negated with `!` prefix.
- `publicGet`, `publicSet`, .etc - can be used on Variable[s] to filter by getter or setter access level, can be nagated with `!` prefix

You can also use partial templates using `include` tag. Partial template is loaded from the path of a template that inculdes it. `include` tags also supports loading templates from relative path, i.e. `{% include "partials/MyPartial.stencil"%}` used in the template located in `templates` directory will load template from `templates/partials` directory.

> Note: You can only load partial templates from child directories of the including template directory, so `{% include "../MyPartial.stencil"%}` is not supported.

Sourcery treat all the templates as independent and so will generate files based on partial templates too. To avoid that use `exclude` in [configuration file](usage.html#configuration-file).

## Swift templates

Swift templates syntax is very similar to EJS:

- Control flow with `<% %>`
- Output value with `<%= %>`
- Trim extra new line after control flow tag with `-%>`
- Trim _all_ whitespaces before/after control flow tag with `<%_` and `_%>`
- Use `<%# %>` for comments
- Use `<%- include("relative_path_to_template.swifttemplate") %>` to include another template. The `swifttemplate` extension can be omitted. The path is relative to the including template.

**Example**: [Equality.swifttemplate](https://github.com/krzysztofzablocki/Sourcery/blob/master/SourceryTests/Stub/SwiftTemplates/Equality.swifttemplate)

Template:

```swift
<% for type in types.all { -%>
  <%_ %><%= type.name %>
<% } %>
```

Output:

```swift
Foo
Bar
```

## JavaScript templates

JavaScript templates are powered by [EJS](http://ejs.co) and support all the features available in this template engine.

**Example**: [JSExport.ejs](https://github.com/krzysztofzablocki/Sourcery/blob/master/Sourcery/Templates/JSExport.ejs)

> Note: when using JavaScript templates with Sourcery built using Swift Package Manager you must provide path to EJS source code using `--ejsPath` command line argument. Download EJS source code [here](https://github.com/krzysztofzablocki/Sourcery/blob/master/SourceryJS/Sources/ejs.js), put it in some path and pass it when running Sourcery. Otherwise JavaScript templates will be ignored (you will see a warning in the console output).

You can also use `SourceryJS` framework independently of Sourcery. You can add it as a Carthge or SPM dependency.

## Using Source Annotations

Sourcery supports annotating your classes and variables with special annotations, similar to how attributes work in Rust / Java

```swift
// sourcery: skipPersistence
// sourcery: anotherAnnotation = 232, yetAnotherAnnotation = "value"
/// Some documentation comment
var precomputedHash: Int
```

If you want to attribute multiple items with same attributes, you can use section annotations `sourcery:begin` and `sourcery:end`:

```swift
// sourcery:begin: skipEquality, skipPersistence
  var firstVariable: Int
  var secondVariable: Int
// sourcery:end
```

To attribute any declaration in the file use `sourcery:file` at the top of the file:

```swift
// sourcery:file: skipEquality
  var firstVariable: Int
  var secondVariable: Int
```
To group annotations of the same domain you can use annotation namespcases:

```swift
// sourcery:decoding: key="first", default=0
  var firstVariable: Int
```
This will effectively annotate with `decoding.key` and `decoding.default` annotations

#### Rules:

- Multiple annotations can occur on the same line, separated with `,`
- You can add multiline annotations
- Multiple annotations values with the same key are merged into array
- You can interleave annotations with documentation
- Sourcery scans all `sourcery:` annotations in the given comment block above the source until first non-comment/doc line
- Using `/*` and `*/` for annotation comment you can put it on the same line with your code. This is usefull for annotating methods parameters and enum case associated values. All such annotations should be placed in one comment block. Do not mix inline and regular annotations for the same declaration (usin inline and block annotations is fine)!

#### Format:

- simple entry, e.g. `sourcery: skipPersistence`
- key = number, e.g. `sourcery: another = 123`
- key = string, e.g. `sourcery: jsonKey = "json_key"`

#### Accessing in templates:

```swift
{% if variable|!annotated:"skipPersistence" %}
  var local{{ variable.name|capitalize }} = json["{{ variable.annotations.jsonKey }}"] as? {{ variable.typeName }}
{% endif %}
```

#### Checking for existance of at least one annotation:

Sometimes it is desirable to only generate code if there's at least one field annotated.

```swift
{% if type.variables|annotated:"jsonKey" %}{% for var in type.variables|instance|annotated:"jsonKey" %}
  var local{{ var.name|capitalize }} = json["{{ var.annotations.jsonKey }}"] as? {{ var.typeName }}
{% endfor %}{% endif %}
```

## Inline code generation

Sourcery supports inline code generation, you just need to put same markup in your code and template, e.g.

```swift
// in template:

{% for type in types.all %}
// sourcery:inline:{{ type.name }}.TemplateName
// sourcery:end
{% endfor %}

// in source code:

class MyType {

// sourcery:inline:MyType.TemplateName
// sourcery:end

}
```

Sourcery will generate the template code and then perform replacement in your source file by matching annotation comments. Inlined generated code is not parsed to avoid chicken-egg problem.

#### Automatic inline code generation

To avoid having to place the markup in your source files, you can use `inline:auto:{{ type.name }}.TemplateName`:

```swift
// in template:

{% for type in types.all %}
// sourcery:inline:auto:{{ type.name }}.TemplateName
// sourcery:end
{% endfor %}

// in source code:

class MyType {}

// after running Sourcery:

class MyType {
// sourcery:inline:auto:MyType.TemplateName
// sourcery:end
}
```

The needed markup will be automatically added at the end of the type declaration body. After first parse Sourcery will work with generated code annotated with `inline:auto` the same way as annotated with `inline`, so you can even move these blocks of code anywhere in the same file.

## Per file code generation

Sourcery supports generating code in a separate file per type, you just need to put `file` annotation in a template, e.g.

```swift
{% for type in types.all %}
// sourcery:file:Generated/{{ type.name}}+TemplateName
// sourcery:end
{% endfor %}
```

Sourcery will generate the template code and then write its annotated parts to corresponding files. In example above it will create `Generated/<type name>+TemplateName.generated.swift` file for each of scanned types.

If you add an extension to the file name Sourcery will not append `generated.swift` extension.
