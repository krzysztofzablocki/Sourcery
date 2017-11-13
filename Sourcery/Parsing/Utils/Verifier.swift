//
// Created by Krzysztof Zablocki on 23/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

enum Verifier {

    // swiftlint:disable:next force_try
    private static let conflictRegex = try! NSRegularExpression(pattern: "^\\s+?(<<<<<|>>>>>)")

    enum Result {
        case isCodeGenerated
        case containsConflictMarkers
        case approved
    }

    public static func canParse(content: String,
                                path: Path,
                                forceParse: [String] = []) -> Result {
        guard !content.isEmpty else { return .approved }

        let hasParsableExtension = (forceParse.filter({ (ext) -> Bool in
            return path.hasExtension(as: ext)
        }).isEmpty == false)

        if content.hasPrefix(Sourcery.generationMarker) && hasParsableExtension == false {
            return .isCodeGenerated
        }

        if conflictRegex.numberOfMatches(in: content, options: .anchored, range: content.bridge().entireRange) > 0 {
            return .containsConflictMarkers
        }

        return .approved
    }
}
