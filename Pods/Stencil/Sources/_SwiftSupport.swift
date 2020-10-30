import Foundation

#if !swift(>=4.2)
extension ArraySlice where Element: Equatable {
    func firstIndex(of element: Element) -> Int? {
        return index(of: element)
    }
}
#endif
