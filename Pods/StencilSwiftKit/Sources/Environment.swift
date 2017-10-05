//
// StencilSwiftKit
// Copyright (c) 2017 SwiftGen
// MIT Licence
//

import Stencil

public extension Extension {
  public func registerStencilSwiftExtensions() {
    registerTags()
    registerStringsFilters()
    registerNumbersFilters()
  }

  // MARK: - Private

  private func registerBooleanFilterWithArguments(_ name: String, filter: @escaping Filters.BooleanWithArguments) {
    registerFilter(name, filter: filter)
    registerFilter("!\(name)", filter: { value, arguments in try !filter(value, arguments)})
  }

  private func registerNumbersFilters() {
    registerFilter("hexToInt", filter: Filters.Numbers.hexToInt)
    registerFilter("int255toFloat", filter: Filters.Numbers.int255toFloat)
    registerFilter("percent", filter: Filters.Numbers.percent)
  }

  private func registerStringsFilters() {
    registerFilter("basename", filter: Filters.Strings.basename)
    registerFilter("camelToSnakeCase", filter: Filters.Strings.camelToSnakeCase)
    registerFilter("dirname", filter: Filters.Strings.dirname)
    registerFilter("escapeReservedKeywords", filter: Filters.Strings.escapeReservedKeywords)
    registerFilter("lowerFirstLetter", filter: Filters.Strings.lowerFirstLetter)
    registerFilter("lowerFirstWord", filter: Filters.Strings.lowerFirstWord)
    registerFilter("removeNewlines", filter: Filters.Strings.removeNewlines)
    registerFilter("replace", filter: Filters.Strings.replace)
    registerFilter("snakeToCamelCase", filter: Filters.Strings.snakeToCamelCase)
    registerFilter("swiftIdentifier", filter: Filters.Strings.swiftIdentifier)
    registerFilter("titlecase", filter: Filters.Strings.upperFirstLetter)
    registerFilter("upperFirstLetter", filter: Filters.Strings.upperFirstLetter)

    registerBooleanFilterWithArguments("contains", filter: Filters.Strings.contains)
    registerBooleanFilterWithArguments("hasPrefix", filter: Filters.Strings.hasPrefix)
    registerBooleanFilterWithArguments("hasSuffix", filter: Filters.Strings.hasSuffix)
  }

  private func registerTags() {
    registerTag("set", parser: SetNode.parse)
    registerTag("macro", parser: MacroNode.parse)
    registerTag("call", parser: CallNode.parse)
    registerTag("map", parser: MapNode.parse)
  }
}

public func stencilSwiftEnvironment() -> Environment {
  let ext = Extension()
  ext.registerStencilSwiftExtensions()

  return Environment(extensions: [ext], templateClass: StencilSwiftTemplate.self)
}
