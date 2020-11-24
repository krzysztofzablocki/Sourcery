import Foundation

/// Representation of a single line in a larger String.
public struct Line {
    /// origin = 0.
    public let index: Int
    /// Content.
    public let content: String
    /// UTF16 based range in entire String. Equivalent to `Range<UTF16Index>`.
    public let range: NSRange
    /// Byte based range in entire String. Equivalent to `Range<UTF8Index>`.
    public let byteRange: ByteRange
}
