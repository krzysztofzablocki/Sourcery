// Generated using Sourcery 0.5.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension NSCoder {

    @nonobjc func decode(forKey: String) -> String? {
        return self.maybeDecode(forKey: forKey) as String?
    }

    @nonobjc func decode(forKey: String) -> TypeName? {
        return self.maybeDecode(forKey: forKey) as TypeName?
    }

    @nonobjc func decode(forKey: String) -> AccessLevel? {
        return self.maybeDecode(forKey: forKey) as AccessLevel?
    }

    @nonobjc func decode(forKey: String) -> Bool {
        return self.decodeBool(forKey: forKey)
    }

    @nonobjc func decode(forKey: String) -> Int {
        return self.decodeInteger(forKey: forKey)
    }

    func decode<E>(forKey: String) -> E? {
        return maybeDecode(forKey: forKey) as E?
    }

    fileprivate func maybeDecode<E>(forKey: String) -> E? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? E
    }

}

extension ArrayType: NSCoding {}
    // sourcery:inline:ArrayType.AutoCoding
    // sourcery:end
extension AssociatedValue: NSCoding {}
    // sourcery:inline:AssociatedValue.AutoCoding
    // sourcery:end
extension Attribute: NSCoding {}
    // sourcery:inline:Attribute.AutoCoding
    // sourcery:end
    // sourcery:inline:Class.AutoCoding
    // sourcery:end
    // sourcery:inline:Enum.AutoCoding
    // sourcery:end
extension EnumCase: NSCoding {}
    // sourcery:inline:EnumCase.AutoCoding
    // sourcery:end
extension FileParserResult: NSCoding {}
    // sourcery:inline:FileParserResult.AutoCoding
    // sourcery:end
extension GenerationContext: NSCoding {}
    // sourcery:inline:GenerationContext.AutoCoding
    // sourcery:end
extension Method: NSCoding {}
    // sourcery:inline:Method.AutoCoding
    // sourcery:end
extension MethodParameter: NSCoding {}
    // sourcery:inline:MethodParameter.AutoCoding
    // sourcery:end
    // sourcery:inline:Protocol.AutoCoding
    // sourcery:end
    // sourcery:inline:Struct.AutoCoding
    // sourcery:end
extension TupleElement: NSCoding {}
    // sourcery:inline:TupleElement.AutoCoding
    // sourcery:end
extension TupleType: NSCoding {}
    // sourcery:inline:TupleType.AutoCoding
    // sourcery:end
extension Type: NSCoding {}
    // sourcery:inline:Type.AutoCoding
    // sourcery:end
extension TypeName: NSCoding {}
    // sourcery:inline:TypeName.AutoCoding
    // sourcery:end
extension Typealias: NSCoding {}
    // sourcery:inline:Typealias.AutoCoding
    // sourcery:end
extension Variable: NSCoding {}
    // sourcery:inline:Variable.AutoCoding
    // sourcery:end
