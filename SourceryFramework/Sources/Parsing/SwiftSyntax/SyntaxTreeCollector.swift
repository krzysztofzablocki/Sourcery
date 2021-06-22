import SwiftSyntax
import SourceryRuntime
import SourceryUtils
import Foundation

class SyntaxTreeCollector: SyntaxVisitor {
    var types = [Type]()
    var typealiases = [Typealias]()
    var methods = [SourceryMethod]()
    var imports = [Import]()
    private var visitingType: Type?

    let annotationsParser: AnnotationsParser
    let sourceLocationConverter: SourceLocationConverter
    let module: String?
    let file: String

    init(file: String, module: String?, annotations: AnnotationsParser, sourceLocationConverter: SourceLocationConverter) {
        self.annotationsParser = annotations
        self.file = file
        self.module = module
        self.sourceLocationConverter = sourceLocationConverter
    }

    private func startVisitingType(_ node: DeclSyntaxProtocol, _ builder: (_ parent: Type?) -> Type) {
        let type = builder(visitingType)

        if let open = node.tokens.first(where: { $0.tokenKind == .leftBrace }),
           let close = node.tokens
             .reversed()
             .first(where: { $0.tokenKind == .rightBrace }) {
            let startLocation = open.endLocation(converter: sourceLocationConverter)
            let endLocation = close.startLocation(converter: sourceLocationConverter)
            type.bodyBytesRange = SourceryRuntime.BytesRange(offset: Int64(startLocation.offset), length: Int64(endLocation.offset - startLocation.offset))
        } else {
            logError("Unable to find bodyRange for \(type.name)")
        }

        let startLocation = node.startLocation(converter: sourceLocationConverter, afterLeadingTrivia: true)
        let endLocation = node.endLocation(converter: sourceLocationConverter, afterTrailingTrivia: false)
        type.completeDeclarationRange = SourceryRuntime.BytesRange(offset: Int64(startLocation.offset), length: Int64(endLocation.offset - startLocation.offset))

        visitingType?.containedTypes.append(type)
        visitingType = type
        types.append(type)
    }

    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        startVisitingType(node) { parent in
            Struct(node, parent: parent, annotationsParser: annotationsParser)
        }
        return .visitChildren
    }

    public override func visitPost(_ node: StructDeclSyntax) {
        visitingType = visitingType?.parent
    }

    public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        startVisitingType(node) { parent in
            Class(node, parent: parent, annotationsParser: annotationsParser)
        }
        return .visitChildren
    }

    public override func visitPost(_ node: ClassDeclSyntax) {
        visitingType = visitingType?.parent
    }

    public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        startVisitingType(node) { parent in
            Enum(node, parent: parent, annotationsParser: annotationsParser)
        }

        return .visitChildren
    }

    public override func visitPost(_ node: EnumDeclSyntax) {
        visitingType = visitingType?.parent
    }

    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        let variables = Variable.from(node, visitingType: visitingType, annotationParser: annotationsParser)
        if let visitingType = visitingType {
            visitingType.rawVariables.append(contentsOf: variables)
        }

        return .skipChildren
    }

    public override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let enumeration = visitingType as? Enum else {
            logError("EnumCase shouldn't appear outside of enum declaration \(node.description.trimmed)")
            return .skipChildren
        }

        enumeration.cases.append(contentsOf: EnumCase.from(node, annotationsParser: annotationsParser))
        return .skipChildren
    }

    public override func visit(_ node: DeinitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let visitingType = visitingType else {
            logError("deinit shouldn't appear outside of type declaration \(node.description.trimmed)")
            return .skipChildren
        }
        visitingType.rawMethods.append(
            SourceryMethod(node, parent: visitingType, typeName: TypeName(visitingType.name), annotationsParser: annotationsParser)
        )
        return .skipChildren
    }

    public override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        startVisitingType(node) { parent in
            let modifiers = node.modifiers?.map(Modifier.init) ?? []
            let base = modifiers.baseModifiers(parent: nil)

            return Type(
              name: node.extendedType.description.trimmingCharacters(in: .whitespaces),
              parent: parent,
              accessLevel: base.readAccess,
              isExtension: true,
              variables: [],
              methods: [],
              subscripts: [],
              inheritedTypes: node.inheritanceClause?.inheritedTypeCollection.map { $0.typeName.description.trimmed } ?? [],
              containedTypes: [],
              typealiases: [],
              attributes: Attribute.from(node.attributes),
              modifiers: modifiers.map(SourceryModifier.init),
              annotations: annotationsParser.annotations(fromToken: node.extensionKeyword),
              documentation: annotationsParser.documentation(fromToken: node.extensionKeyword),
              isGeneric: false
            )
        }
        return .visitChildren
    }

    public override func visitPost(_ node: ExtensionDeclSyntax) {
        visitingType = visitingType?.parent
    }

    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let method = SourceryMethod(node, parent: visitingType, typeName: visitingType.map { TypeName($0.name) }, annotationsParser: annotationsParser)
        if let visitingType = visitingType {
            visitingType.rawMethods.append(method)
        } else {
            methods.append(method)
        }

        return .skipChildren
    }

    public override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        imports.append(Import(path: node.path.description.trimmed, kind: node.importKind?.text.trimmed))
        return .skipChildren
    }

    public override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let visitingType = visitingType else {
            logError("init shouldn't appear outside of type declaration \(node.description.trimmed)")
            return .skipChildren
        }
        let method = SourceryMethod(node, parent: visitingType, typeName: TypeName(visitingType.name), annotationsParser: annotationsParser)
        visitingType.rawMethods.append(method)
        return .skipChildren
    }

    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        startVisitingType(node) { parent in
            SourceryProtocol(node, parent: parent, annotationsParser: annotationsParser)
        }
        return .visitChildren
    }

    public override func visitPost(_ node: ProtocolDeclSyntax) {
        visitingType = visitingType?.parent
    }

    public override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let visitingType = visitingType else {
            logError("subscript shouldn't appear outside of type declaration \(node.description.trimmed)")
            return .skipChildren
        }

        visitingType.rawSubscripts.append(
          Subscript(node, parent: visitingType, annotationsParser: annotationsParser)
        )

        return .skipChildren
    }

    public override func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
        let localName = node.identifier.text.trimmed
        let typeName = node.initializer.map { TypeName($0.value) } ?? TypeName.unknown(description: node.description.trimmed)
        let modifiers = node.modifiers?.map(Modifier.init) ?? []
        let baseModifiers = modifiers.baseModifiers(parent: visitingType)
        let annotations = annotationsParser.annotations(from: node)

        if let composition = processPossibleProtocolComposition(for: typeName.name, localName: localName, annotations: annotations, accessLevel: baseModifiers.readAccess) {
            if let visitingType = visitingType {
                visitingType.containedTypes.append(composition)
            } else {
                types.append(composition)
            }

            return .skipChildren
        }

        let alias = Typealias(
          aliasName: localName,
          typeName: typeName,
          accessLevel: baseModifiers.readAccess,
          parent: visitingType,
          module: module
        )

        // TODO: add generic requirements
        if let visitingType = visitingType {
            visitingType.typealiases[localName] = alias
        } else {
            // global typealias
            typealiases.append(alias)
        }
        return .skipChildren
    }

    public override func visit(_ node: AssociatedtypeDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let sourceryProtocol = visitingType as? SourceryProtocol else {
            return .skipChildren
        }

        let name = node.identifier.text.trimmed
        var typeName: TypeName?
        var type: Type?
        if let possibleTypeName = node.inheritanceClause?.inheritedTypeCollection.description.trimmed {
            type = processPossibleProtocolComposition(for: possibleTypeName, localName: "")
            typeName = TypeName(possibleTypeName)
        }

        sourceryProtocol.associatedTypes[name] = AssociatedType(name: name, typeName: typeName, type: type)
        return .skipChildren
    }


    public override func visit(_ node: OperatorDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    public override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    public override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }

    private func processPossibleProtocolComposition(for typeName: String, localName: String, annotations: [String: NSObject] = [:], accessLevel: AccessLevel = .internal) -> Type? {
        if let composedTypeNames = extractComposedTypeNames(from: typeName, trimmingCharacterSet: .whitespaces), composedTypeNames.count > 1 {
            let inheritedTypes = composedTypeNames.map { $0.name }
            let composition = ProtocolComposition(
                name: localName,
                parent: visitingType,
                accessLevel: accessLevel,
                inheritedTypes: inheritedTypes,
                annotations: annotations,
                composedTypeNames: composedTypeNames
            )
            return composition
        }

        return nil
    }

    /// Extracts list of type names from composition e.g. `ProtocolA & ProtocolB`
    internal func extractComposedTypeNames(from value: String, trimmingCharacterSet: CharacterSet? = nil) -> [TypeName]? {
        guard case let closureComponents = value.components(separatedBy: "->"),
              closureComponents.count <= 1 else { return nil }
        guard case let components = value.components(separatedBy: CharacterSet(charactersIn: "&")),
              components.count > 1 else { return nil }

        var characterSet: CharacterSet = .whitespacesAndNewlines
        if let trimmingCharacterSet = trimmingCharacterSet {
            characterSet = characterSet.union(trimmingCharacterSet)
        }

        let suffixes = components.map { source in
            source.trimmingCharacters(in: characterSet)
        }
        return suffixes.map { TypeName($0) }
    }

    private func logError(_ message: Any) {
        let prefix = file + ": "
        if let module = module {
            Log.astError("\(prefix) \(message) in module \(module)")
        } else {
            Log.astError("\(prefix) \(message)")
        }
    }
}
