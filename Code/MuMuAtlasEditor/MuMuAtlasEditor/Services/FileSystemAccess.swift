//
//  FileSystemAccess.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/25.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Returns `true` if running unit tests or UI tests, `false` otherwise.
 */
public var isTesting: Bool {
    return ProcessInfo().arguments.contains("-Testing")
}

/**
 When testing, `completionHandler` is executed right away with the URLs of the
 bundled dummy source images. Otherwise, it runs an `NSOpenPanel` modally that
 is configured to allow selecting multiple files and/or directories (but not
 create new directories).
 */
public func promptImportInput(completionHandler: @escaping (([URL]) -> Void)) {
    guard isTesting == false else {
        let fileURLs = (1 ... 5).compactMap { (index) -> URL? in
            let fileName = String(format: "%02d", index) + "@2x"
            return Bundle.main.url(forResource: fileName, withExtension: "png")
        }

        let fileURL8 = Bundle.main.url(forResource: "08@2x", withExtension: "png", subdirectory: "Folder_1", localization: nil)!
        let folderURL1 = fileURL8.deletingLastPathComponent()

        let fileURL6 = Bundle.main.url(forResource: "06@2x", withExtension: "png", subdirectory: "Folder_2", localization: nil)!
        let folderURL2 = fileURL6.deletingLastPathComponent()

        let folderURLs = [folderURL1, folderURL2]
        return completionHandler(fileURLs + folderURLs)
    }

    // (The code below can not be covered during automated testing)

    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = true
    panel.canCreateDirectories = false
    panel.allowsMultipleSelection = true

    let response = panel.runModal()

    switch response {
    case NSApplication.ModalResponse.OK:
        completionHandler(panel.urls)
    default:
        completionHandler([])
    }
}

/**
 - note: When testing, `completionHandler` is executed right away with the URL
 of the current user's temporary directory. Otherwise, it runds an NSOpenPanel
 modally configured to create directories and select at most a single directory
 (not files).
 */
public func promptExportDestination(completionHandler: @escaping((URL?) -> Void)) {
    guard isTesting == false else {
        let tempPath = NSTemporaryDirectory()
        return completionHandler(URL(fileURLWithPath: tempPath))
    }
    // (The code below can not be covered during automated testing)

    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.allowsMultipleSelection = false

    let response = panel.runModal()

    switch response {
    case NSApplication.ModalResponse.OK:
        completionHandler(panel.urls.first)
    default:
        completionHandler(nil)
    }
}
