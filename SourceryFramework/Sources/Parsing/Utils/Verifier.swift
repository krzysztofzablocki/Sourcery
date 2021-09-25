//
// Created by Krzysztof Zablocki on 23/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation
import PathKit
import SourceryUtils

public enum Verifier {

    // swiftlint:disable:next force_try
    private static let conflictRegex = try! NSRegularExpression(pattern: "^\\s+?(<<<<<|>>>>>)")

    public enum Result {
        case isCodeGenerated
        case containsConflictMarkers
        case approved
    }

    public static func canParse(content: String,
                                path: Path,
                                generationMarker: String,
                                forceParse: [String] = []) -> Result {
        guard !content.isEmpty else { return .approved }

        let shouldForceParse = forceParse.contains { name in
            return path.hasExtension(as: name)
        }

        if content.hasPrefix(generationMarker) && shouldForceParse == false {
            return .isCodeGenerated
        }

        if conflictRegex.numberOfMatches(in: content, options: .anchored, range: content.bridge().entireRange) > 0 {
            return .containsConflictMarkers
        }

        return .approved
    }
}
