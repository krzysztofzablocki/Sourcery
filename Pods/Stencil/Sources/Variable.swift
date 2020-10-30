import Foundation

typealias Number = Float

class FilterExpression: Resolvable {
  let filters: [(FilterType, [Variable])]
  let variable: Variable

  init(token: String, environment: Environment) throws {
    let bits = token.smartSplit(separator: "|").map { String($0).trim(character: " ") }
    if bits.isEmpty {
      throw TemplateSyntaxError("Variable tags must include at least 1 argument")
    }

    variable = Variable(bits[0])
    let filterBits = bits[bits.indices.suffix(from: 1)]

    do {
      filters = try filterBits.map {
        let (name, arguments) = parseFilterComponents(token: $0)
        let filter = try environment.findFilter(name)
        return (filter, arguments)
      }
    } catch {
      filters = []
      throw error
    }
  }

  func resolve(_ context: Context) throws -> Any? {
    let result = try variable.resolve(context)

    return try filters.reduce(result) { value, filter in
      let arguments = try filter.1.map { try $0.resolve(context) }
      return try filter.0.invoke(value: value, arguments: arguments, context: context)
    }
  }
}

/// A structure used to represent a template variable, and to resolve it in a given context.
public struct Variable: Equatable, Resolvable {
  public let variable: String

  /// Create a variable with a string representing the variable
  public init(_ variable: String) {
    self.variable = variable
  }

  /// Resolve the variable in the given context
  public func resolve(_ context: Context) throws -> Any? {
    if (variable.hasPrefix("'") && variable.hasSuffix("'")) || (variable.hasPrefix("\"") && variable.hasSuffix("\"")) {
      // String literal
      return String(variable[variable.index(after: variable.startIndex) ..< variable.index(before: variable.endIndex)])
    }

    // Number literal
    if let int = Int(variable) {
      return int
    }
    if let number = Number(variable) {
      return number
    }
    // Boolean literal
    if let bool = Bool(variable) {
      return bool
    }

    var current: Any? = context
    for bit in try lookup(context) {
      current = resolve(bit: bit, context: current)

      if current == nil {
        return nil
      }
    }

    if let resolvable = current as? Resolvable {
      current = try resolvable.resolve(context)
    } else if let node = current as? NodeType {
      current = try node.render(context)
    }

    return normalize(current)
  }

  // Split the lookup string and resolve references if possible
  private func lookup(_ context: Context) throws -> [String] {
    let keyPath = KeyPath(variable, in: context)
    return try keyPath.parse()
  }

  // Try to resolve a partial keypath for the given context
  private func resolve(bit: String, context: Any?) -> Any? {
    let context = normalize(context)

    if let context = context as? Context {
      return context[bit]
    } else if let dictionary = context as? [String: Any] {
      return resolve(bit: bit, dictionary: dictionary)
    } else if let array = context as? [Any] {
      return resolve(bit: bit, collection: array)
    } else if let string = context as? String {
      return resolve(bit: bit, collection: string)
    } else if let object = context as? NSObject {  // NSKeyValueCoding
      #if os(Linux)
        return nil
      #else
        if object.responds(to: Selector(bit)) {
          return object.value(forKey: bit)
        }
      #endif
    } else if let value = context {
      return Mirror(reflecting: value).getValue(for: bit)
    }

    return nil
  }

  // Try to resolve a partial keypath for the given dictionary
  private func resolve(bit: String, dictionary: [String: Any]) -> Any? {
    if bit == "count" {
      return dictionary.count
    } else {
      return dictionary[bit]
    }
  }

  // Try to resolve a partial keypath for the given collection
  private func resolve<T: Collection>(bit: String, collection: T) -> Any? {
    if let index = Int(bit) {
      if index >= 0 && index < collection.count {
        return collection[collection.index(collection.startIndex, offsetBy: index)]
      } else {
        return nil
      }
    } else if bit == "first" {
      return collection.first
    } else if bit == "last" {
      return collection[collection.index(collection.endIndex, offsetBy: -1)]
    } else if bit == "count" {
      return collection.count
    } else {
      return nil
    }
  }
}

/// A structure used to represet range of two integer values expressed as `from...to`.
/// Values should be numbers (they will be converted to integers).
/// Rendering this variable produces array from range `from...to`.
/// If `from` is more than `to` array will contain values of reversed range.
public struct RangeVariable: Resolvable {
  public let from: Resolvable
  // swiftlint:disable:next identifier_name
  public let to: Resolvable

  public init?(_ token: String, environment: Environment) throws {
    let components = token.components(separatedBy: "...")
    guard components.count == 2 else {
      return nil
    }

    self.from = try environment.compileFilter(components[0])
    self.to = try environment.compileFilter(components[1])
  }

  public init?(_ token: String, environment: Environment, containedIn containingToken: Token) throws {
    let components = token.components(separatedBy: "...")
    guard components.count == 2 else {
      return nil
    }

    self.from = try environment.compileFilter(components[0], containedIn: containingToken)
    self.to = try environment.compileFilter(components[1], containedIn: containingToken)
  }

  public func resolve(_ context: Context) throws -> Any? {
    let lowerResolved = try from.resolve(context)
    let upperResolved = try to.resolve(context)

    guard let lower = lowerResolved.flatMap(toNumber(value:)).flatMap(Int.init) else {
      throw TemplateSyntaxError("'from' value is not an Integer (\(lowerResolved ?? "nil"))")
    }

    guard let upper = upperResolved.flatMap(toNumber(value:)).flatMap(Int.init) else {
      throw TemplateSyntaxError("'to' value is not an Integer (\(upperResolved ?? "nil") )")
    }

    let range = min(lower, upper)...max(lower, upper)
    return lower > upper ? Array(range.reversed()) : Array(range)
  }
}

func normalize(_ current: Any?) -> Any? {
  if let current = current as? Normalizable {
    return current.normalize()
  }

  return current
}

protocol Normalizable {
  func normalize() -> Any?
}

extension Array: Normalizable {
  func normalize() -> Any? {
    return map { $0 as Any }
  }
}

extension NSArray: Normalizable {
  func normalize() -> Any? {
    return map { $0 as Any }
  }
}

extension Dictionary: Normalizable {
  func normalize() -> Any? {
    var dictionary: [String: Any] = [:]

    for (key, value) in self {
      if let key = key as? String {
        dictionary[key] = Stencil.normalize(value)
      } else if let key = key as? CustomStringConvertible {
        dictionary[key.description] = Stencil.normalize(value)
      }
    }

    return dictionary
  }
}

func parseFilterComponents(token: String) -> (String, [Variable]) {
  var components = token.smartSplit(separator: ":")
  let name = components.removeFirst().trim(character: " ")
  let variables = components
    .joined(separator: ":")
    .smartSplit(separator: ",")
    .map { Variable($0.trim(character: " ")) }
  return (name, variables)
}

extension Mirror {
  func getValue(for key: String) -> Any? {
    let result = descendant(key) ?? Int(key).flatMap { descendant($0) }
    if result == nil {
      // go through inheritance chain to reach superclass properties
      return superclassMirror?.getValue(for: key)
    } else if let result = result {
      guard String(describing: result) != "nil" else {
        // mirror returns non-nil value even for nil-containing properties
        // so we have to check if its value is actually nil or not
        return nil
      }
      if let result = (result as? AnyOptional)?.wrapped {
        return result
      } else {
        return result
      }
    }
    return result
  }
}

protocol AnyOptional {
  var wrapped: Any? { get }
}

extension Optional: AnyOptional {
  var wrapped: Any? {
    switch self {
    case let .some(value): return value
    case .none: return nil
    }
  }
}
