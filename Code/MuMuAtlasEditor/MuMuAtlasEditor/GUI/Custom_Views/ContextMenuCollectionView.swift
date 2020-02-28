//
//  ContextMenuCollectionView.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/08.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Accepts a closure to configure index path-specific context menues on right
 click.
 */
class ContextMenuCollectionView: NSCollectionView {

    /**
     A closure that is executed each time an item in the collection view
     receives a right click. Use it to generate a menu tailored to the item at
     the index path passed as the argument.
     */
    var contextMenuHandler: ((IndexPath) -> NSMenu?)?

    // MARK: - NSView

    override func menu(for event: NSEvent) -> NSMenu? {
        let location = convert(event.locationInWindow, from: nil)

        guard let targetIndexPath = indexPathForItem(at: location) else {
            return nil
        }
        selectionIndexPaths.insert(targetIndexPath)

        return contextMenuHandler?(targetIndexPath)
    }
}
