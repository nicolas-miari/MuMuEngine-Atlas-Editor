//
//  AnchorPointEditorViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/04/26.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 */
class AnchorPointEditorViewController: NSViewController {

    // MARK: - GUI

    @IBOutlet private(set) weak var scrollView: NSScrollView!

    // MARK: -

    var source: Source! {
        didSet {
            newAnchorPoint = source.anchorPoint
        }
    }

    var newAnchorPoint: CGPoint = .zero

    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        // See this:
        // https://stackoverflow.com/a/35242351/433373
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        let trackingRect = scrollView.frame
        let trackingArea = NSTrackingArea(rect: trackingRect, options: [.activeAlways, .inVisibleRect, .mouseMoved, .mouseEnteredAndExited], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let locationInView = view.convert(locationInWindow, from: nil)
        print("Location: \(locationInView)")

    }

    override func mouseDown(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let locationInView = view.convert(locationInWindow, from: nil)
        print("Location: \(locationInView)")
    }

    override func mouseMoved(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let locationInView = view.convert(locationInWindow, from: nil)
        print("Location: \(locationInView)")
    }

    // MARK: - Control Actions

    @IBAction func set(_ sender: Any) {
        source.anchorPoint = newAnchorPoint
        view.window?.close()
    }

    @IBAction func cancel(_ sender: Any) {
        view.window?.close()
    }
}

class ImageView: NSView {
    var image: NSImage! {
        didSet {
            self.needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
    }
}
