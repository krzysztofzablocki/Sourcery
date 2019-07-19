//
//  XcodeBuildSetting.swift
//  SourceKittenFramework
//
//  Created by Chris Zielinski on 2/23/19.
//  Copyright © 2019 SourceKitten. All rights reserved.
//

@dynamicMemberLookup
struct XcodeBuildSetting: Codable {

    /// The build action.
    let action: String
    /// The build settings.
    let buildSettings: [String: String]
    /// The target name.
    let target: String

    subscript(dynamicMember member: String) -> String? {
        return buildSettings[member]
    }
}
