#!/bin/zsh

if which swiftlint >/dev/null; then
    swiftlint autocorrect
    swiftlint
else
    echo "warning: SwiftLint not installed. Install using brew update && brew install swiftlint or download from https://github.com/realm/SwiftLint."
fi
