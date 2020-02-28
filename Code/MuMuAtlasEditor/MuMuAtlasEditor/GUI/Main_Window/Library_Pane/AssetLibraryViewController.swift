//
//  AssetLibraryViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

final class AssetLibraryViewController: NSViewController {

    // MARK: - GUI

    @IBOutlet weak var collectionView: ContextMenuCollectionView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var sortPopupButton: NSPopUpButton!

    var infoWindowControllers: [NSWindowController] = []

    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        configureCollectionView()
        updateRemoveButton()

        collectionView.contextMenuHandler = { [unowned self](indexPath) -> NSMenu? in
            return self.menu(forItemAt: indexPath)
        }
        removeButton.keyEquivalent = "\(NSDeleteFunctionKey)"

        // Subscribe so we can refresh the collection view:
        NotificationCenter.default.addObserver(self, selector: #selector(didAddSources(_:)), name: .documentDidModifyLibrary, object: nil)
    }

    override var representedObject: Any? {
        didSet {
            collectionView.reloadData()
            updateRemoveButton()

            let index: Int = {
                guard let criterion = document?.librarySortCriterion else {
                    return 0
                }
                return criterion.rawValue
            }()
            sortPopupButton.selectItem(at: index)
        }
    }

    // MARK: -

    private var document: Document? {
        return (representedObject as? Document)
    }

    private var selectedItems: [LibraryCollectionViewItem] {
        return collectionView.selectionIndexPaths.compactMap { (indexPath) -> LibraryCollectionViewItem? in
            return collectionView.item(at: indexPath) as? LibraryCollectionViewItem
        }
    }

    private func menu(forItemAt indexPath: IndexPath) -> NSMenu? {
        let menu = NSMenu(title: "Context")

        var selectedIndexPaths = collectionView.selectionIndexPaths

        selectedIndexPaths.insert(indexPath)

        // 1. "Include/Exclude" Menu Item:
        let items: [LibraryCollectionViewItem] = selectedIndexPaths.compactMap { (indexPath) -> LibraryCollectionViewItem? in
            return collectionView.item(at: indexPath) as? LibraryCollectionViewItem
        }
        let includedItems = items.filter { (item) -> Bool in
            return item.source?.isIncluded ?? false
        }

        if includedItems.count == items.count {
            // All included. Add option to exclude:
            let excludeMenuItem = NSMenuItem(title: "Exclude from Atlas", action: #selector(exclude(_:)), keyEquivalent: "")
            excludeMenuItem.target = self
            menu.addItem(excludeMenuItem)

        } else if includedItems.count == 0 {
            // All excluded. Add option to include:
            let includeMenuItem = NSMenuItem(title: "Include in Atlas", action: #selector(include(_:)), keyEquivalent: "")
            includeMenuItem.target = self
            menu.addItem(includeMenuItem)
        }

        // 2. "Delete" and "Info" Menu Items

        if items.count > 0 {
            let infoMenuItem = NSMenuItem(title: "Info...", action: #selector(info(_:)), keyEquivalent: "")
            infoMenuItem.isEnabled = items.count == 1
            menu.addItem(infoMenuItem)

            menu.addItem(NSMenuItem.separator())

            let deleteMenuItem = NSMenuItem(title: "Remove from Library", action: #selector(delete(_:)), keyEquivalent: "")
            deleteMenuItem.target = self
            menu.addItem(deleteMenuItem)
        }
        return menu
    }

    private func configureCollectionView() {
        let flowLayout = CollectionViewLeftFlowLayout()
        flowLayout.itemSize = NSSize(width: 120, height: 120)
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = flowLayout

        let nib = NSNib(nibNamed: LibraryCollectionViewItem.nibName, bundle: nil)
        let identifier = LibraryCollectionViewItem.identifier
        collectionView.register(nib, forItemWithIdentifier: identifier)

        view.wantsLayer = true
        collectionView.layer?.backgroundColor = NSColor.white.cgColor

        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.URL])
        collectionView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
    }

    // MARK: - Collection View Item Context Menu Actions

    @objc func include(_ sender: NSMenuItem) {
        selectedItems.forEach { (item) in
            item.source?.isIncluded = true
        }
        collectionView.reloadItems(at: collectionView.selectionIndexPaths)
        document?.refreshComposition()
    }

    @objc func exclude(_ sender: NSMenuItem) {
        selectedItems.forEach { (item) in
            item.source?.isIncluded = false
        }
        collectionView.reloadItems(at: collectionView.selectionIndexPaths)
        document?.refreshComposition()
    }

    @objc func delete(_ sender: NSMenuItem) {
        removeSelected()
    }

    @objc func info(_ sender: NSMenuItem) {
        let indexPaths = collectionView.selectionIndexPaths
        guard indexPaths.count == 1, let indexPath = indexPaths.first else {
            return
        }
        guard let item = collectionView.item(at: indexPath) as? LibraryCollectionViewItem else {
            return
        }

        let storyboard = NSStoryboard(name: "SourceInfo", bundle: nil)
        guard let windowController = storyboard.instantiateInitialController() as? SourceInfoWindowController else {
            fatalError("!!!")
        }
        infoWindowControllers.append(windowController)
        windowController.closeHandler = {[unowned self] in
            guard let index = self.infoWindowControllers.firstIndex(of: windowController) else {
                return
            }
            self.infoWindowControllers.remove(at: index)
        }

        (windowController.contentViewController as? SourceInfoViewController)?.source = item.source
        windowController.showWindow(self)
        windowController.window?.center()
    }

    // MARK: - Control Actions

    @IBAction func addItems(_ sender: NSButton) {
        document?.importSources(sender)
    }

    @IBAction func deleteSelectedItems(_ sender: NSButton) {
        removeSelected()
    }

    @IBAction func sortCriterionChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        guard let criterion = SortCriterion(rawValue: index) else {
            fatalError("Storyboard Inconsistency")
        }

        document?.librarySortCriterion = criterion

        collectionView.reloadData()
    }

    // MARK: - Notification Handlers

    @objc func didAddSources(_ notification: Notification) {
        collectionView.reloadData()
    }

    // MARK: -

    fileprivate func updateRemoveButton() {
        let numberOfItems = collectionView.selectionIndexes.count
        removeButton.isEnabled = numberOfItems > 0
    }

    fileprivate func removeSelected() {
        guard selectedItems.count > 0 else {
            return
        }
        let selected = selectedItems

        let sourcesToRemove = selected.compactMap { (item) -> Source? in
            return item.source
        }
        document?.removeSources(sourcesToRemove)
        collectionView.reloadData()
        updateRemoveButton()
    }
}

// MARK: -

extension AssetLibraryViewController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(delete(_:)) {
            return selectedItems.count > 0
        }
        return true
    }
}

// MARK: - NSCollectionView Delegate

extension AssetLibraryViewController: NSCollectionViewDelegate {

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        updateRemoveButton()
    }

    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        updateRemoveButton()
    }

    // Drag and Drop

    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt index: Int) -> NSPasteboardWriting? {
        return nil
    }
}

// MARK: - NSCollectionView Data Source

extension AssetLibraryViewController: NSCollectionViewDataSource {

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return document?.numberOfSources ?? 0
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: LibraryCollectionViewItem.identifier, for: indexPath)

        guard let libraryItem = item as? LibraryCollectionViewItem else {
            return item
        }

        // Configure...
        libraryItem.source = document?.source(at: indexPath.item)

        return libraryItem
    }
}
