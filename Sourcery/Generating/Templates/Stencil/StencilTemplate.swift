import Foundation
import SourceryFramework
import SourceryRuntime
import SourceryStencil

extension StencilTemplate: SourceryFramework.Template {
    public func render(_ context: TemplateContext) throws -> String {
        do {
            return try self.render(context.stencilContext)
        } catch {
            throw "\(sourcePath): \(error)"
        }
    }
}
