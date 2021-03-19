import Foundation
import SourceryFramework
import SourceryRuntime
import SourceryStencil
import SourceryFramework

extension StencilTemplate: SourceryFramework.Template {
    public func render(_ context: TemplateContext) throws -> String {
        do {
            return try super.render(context.stencilContext)
        } catch {
            throw "\(sourcePath): \(error)"
        }
    }
}
