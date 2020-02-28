//
//  SourceInfoWindowController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/11.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

class SourceInfoWindowController: NSWindowController, NSWindowDelegate {

    var closeHandler: (() -> Void)?

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.delegate = self
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    func windowWillClose(_ notification: Notification) {
        closeHandler?()
    }
}
