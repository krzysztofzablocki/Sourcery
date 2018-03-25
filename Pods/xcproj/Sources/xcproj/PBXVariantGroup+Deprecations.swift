public extension PBXVariantGroup {

    /// Initializes the PBXVariantGroup with its values.
    ///
    /// - Parameters:
    ///   - children: group children references.
    ///   - path: path of the variant group
    ///   - name: name of the variant group
    ///   - sourceTree: the group source tree.
    @available(*, deprecated, message: "use the initializer inherited from PBXGroup instead")
    convenience init(children: [String] = [],
                path: String? = nil,
                name: String? = nil,
                sourceTree: PBXSourceTree? = nil) {
        self.init(children: children,
                  sourceTree: sourceTree,
                  name: name,
                  path: path)
    }

}
