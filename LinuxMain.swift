import XCTest
import Quick

@testable import SourceryLibTests
@testable import TemplatesTests
@testable import CodableContextTests

@main struct Main {
    static func main() {
        Quick.QCKMain([
            ActorSpec.self,
            AnnotationsParserSpec.self,
            ClassSpec.self,
            ConfigurationSpec.self,
            DiffableSpec.self,
            DryOutputSpec.self,
            EnumSpec.self,
            FileParserAssociatedTypeSpec.self,
            FileParserAttributesSpec.self,
            FileParserMethodsSpec.self,
            FileParserProtocolCompositionSpec.self,
            FileParserSpec.self,
            FileParserSubscriptsSpec.self,
            FileParserVariableSpec.self,
            GeneratorSpec.self,
            MethodSpec.self,
            ParserComposerSpec.self,
            ProtocolSpec.self,
            SourcerySpecTests.self,
            StencilTemplateSpec.self,
            StringViewSpec.self,
            StructSpec.self,
            SwiftTemplateTests.self,
            TemplateAnnotationsParserSpec.self,
            TemplatesAnnotationParserPassInlineCodeSpec.self,
            TypeNameSpec.self,
            TypeSpec.self,
            TypealiasSpec.self,
            TypedSpec.self,
            VariableSpec.self,
            VerifierSpec.self,
            CodableContextTests.self,
            TemplatesTests.self
        ],
        configurations: [],
        testCases: [
            testCase(ActorSpec.allTests),
            testCase(AnnotationsParserSpec.allTests),
            testCase(ClassSpec.allTests),
            testCase(ConfigurationSpec.allTests),
            testCase(DiffableSpec.allTests),
            testCase(DryOutputSpec.allTests),
            testCase(EnumSpec.allTests),
            testCase(FileParserAssociatedTypeSpec.allTests),
            testCase(FileParserAttributesSpec.allTests),
            testCase(FileParserMethodsSpec.allTests),
            testCase(FileParserProtocolCompositionSpec.allTests),
            testCase(FileParserSpec.allTests),
            testCase(FileParserSubscriptsSpec.allTests),
            testCase(FileParserVariableSpec.allTests),
            testCase(GeneratorSpec.allTests),
            testCase(MethodSpec.allTests),
            testCase(ParserComposerSpec.allTests),
            testCase(ProtocolSpec.allTests),
            testCase(SourcerySpecTests.allTests),
            testCase(StencilTemplateSpec.allTests),
            testCase(StringViewSpec.allTests),
            testCase(StructSpec.allTests),
            testCase(SwiftTemplateTests.allTests),
            testCase(TemplateAnnotationsParserSpec.allTests),
            testCase(TemplatesAnnotationParserPassInlineCodeSpec.allTests),
            testCase(TypeNameSpec.allTests),
            testCase(TypeSpec.allTests),
            testCase(TypealiasSpec.allTests),
            testCase(TypedSpec.allTests),
            testCase(VariableSpec.allTests),
            testCase(VerifierSpec.allTests),
            testCase(CodableContextTests.allTests),
            testCase(TemplatesTests.allTests)
        ])
    }
}