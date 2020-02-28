//
//  CenteredClipView.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/08.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 When used as the content view of an NSSCrollView instance, the document view
 will be dislpayed centered if the zoom scale is  such that it fully fits within
 the clip view (the default clip view pins it to the bottom-left corner).
 */
class CenteredClipView: NSClipView {

    // MARK: - NSClipView

    override var isFlipped: Bool {
        set {
            _ = newValue
        }
        get {
            return true
        }
    }

    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        /*
         documentView is optional, but is set to an actual value within
         super.init(coder:). Not sure how to cover the path after the '??'.
         */
        let documentBounds = documentView?.bounds ?? .zero

        let delta = NSPoint(
            x: documentBounds.width - proposedBounds.width,
            y: documentBounds.height - proposedBounds.height
        )

        let x = delta.x < 0 ? (delta.x / 2) : max(0, min(proposedBounds.origin.x, delta.x))
        let y = delta.y < 0 ? (delta.y / 2) : max(0, min(proposedBounds.origin.y, delta.y))

        let origin = NSPoint(x: floor(x), y: floor(y))
        return NSRect(origin: origin, size: proposedBounds.size)
    }
}
