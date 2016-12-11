SwiftTryCatch
=============

Adds try/catch support for Swift.

Simple wrapper built around Objective-C `@try`/`@catch`/`@finally`.

**Note:** This repository was originally forked from [https://github.com/williamFalcon/SwiftTryCatch](https://github.com/williamFalcon/SwiftTryCatch) and updated to work with Swift 2.0, since the original API conflicted with new try/catch keywords introduced by new Swift version.

##Usage

### Install via Cocoapods

To use this specific repository version of SwiftTryCatch use the following pod definition:

    pod 'SwiftTryCatch', :git => 'https://github.com/ravero/SwiftTryCatch.git'

This will use the podspec from this forked repository with the API signature changes.

### Create bridging header

- When prompted with "Would you like to configure an Obj-C bridging header?", press "Yes".
- Go to bridging header and add:

        #import "SwiftTryCatch.h"

### Use

    SwiftTryCatch.tryBlock({
             // try something
         }, catchBlock: { (error) in
             println("\(error.description)")
         }, finallyBlock: {
             // close resources
    })
