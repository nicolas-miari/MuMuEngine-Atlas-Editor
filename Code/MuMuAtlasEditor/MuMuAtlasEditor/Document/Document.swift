//
//  Document.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Represents a single document of the app in memory (model controller).
 */
final class Document: NSDocument {

    private var resizeCanvasWindowController: NSWindowController?
    private var exportWindowController: NSWindowController?

    // MARK: - Project Data and Parameters

    /// The size of the canvas where all sprites are packed, and thus the size
    /// of the exported texture. Units are in **points**, _not_ pixels.
    private(set) public var canvasSize: CGSize = AppConfiguration.defaultCanvasSize

    /// Re-calculated everytime `refreshComposition()` is executed.
    private(set) public var previewImage: CGImage?

    // List of image assets imported for potential inclusion in the final atlas
    // to be exported.
    //
    private var assetLibrary: [Source] = []

    // List of elements from `assetLibrary` that are currently scheduled for
    // inclusion in the final atlas to be exported.
    //
    private var includedSources: [Source] {
        return assetLibrary.filter { $0.isIncluded }
    }

    //
    private var outputScaleFactors: Set<CGFloat> = [1.0, 2.0]

    // MARK: - NSDocument

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("MainWindow"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)

        refreshComposition()
    }

    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {

        // 1. Directory with all PNGs in the Asset Library

        var imageWrappersByName: [String: FileWrapper] = [:]

        try assetLibrary.forEach { (source) in
            let imageData = try source.image.pngData()
            imageWrappersByName[source.name] = FileWrapper(regularFileWithContents: imageData as Data)
        }
        let sourcesDirectoryWrapper = FileWrapper(directoryWithFileWrappers: imageWrappersByName)

        // 2. Metadata file with project and atlas configuration

        var projectDescriptor = ProjectDescriptor()
        projectDescriptor.canvasSize = canvasSize
        projectDescriptor.exportedScaleFactors = outputScaleFactors
        projectDescriptor.includedSourceNames = includedSources.map { $0.name }
        projectDescriptor.librarySortCriterion = librarySortCriterion
        projectDescriptor.showsOutlines = showsOutlines

        assetLibrary.forEach { (source) in
            if source.anchorPoint != .zero {
                projectDescriptor.anchorPointsBySourceName[source.name] = source.anchorPoint
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let metadata = try encoder.encode(projectDescriptor)
        let metadataWrapper = FileWrapper(regularFileWithContents: metadata)

        let rootWrapper = FileWrapper(directoryWithFileWrappers: [ "Sources": sourcesDirectoryWrapper, "Metadata.json": metadataWrapper])
        return rootWrapper
    }

    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        guard let children = fileWrapper.fileWrappers else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }

        if let imageWrappers = children["Sources"]?.fileWrappers {
            let sources: [Source] = imageWrappers.compactMap { (name, wrapper) -> Source? in
                guard let imageData = wrapper.regularFileContents else {
                    return nil
                }
                guard let bitmap = NSBitmapImageRep(data: imageData) else {
                    return nil
                }
                guard let image = bitmap.cgImage else {
                    return nil
                }
                return Source(name: name, image: image, scaleFactor: CGFloat(scaleFactorIn: name), isOpaque: bitmap.isOpaque)
            }
            addSources(sources)
        }

        if let metadata = children["Metadata.json"]?.regularFileContents {
            let projectDescriptor = try JSONDecoder().decode(ProjectDescriptor.self, from: metadata)
            let includeList = projectDescriptor.includedSourceNames
            assetLibrary.forEach { (source) in
                source.isIncluded = includeList.contains(source.name)
            }
            self.librarySortCriterion = projectDescriptor.librarySortCriterion
            self.showsOutlines = projectDescriptor.showsOutlines
            self.canvasSize = projectDescriptor.canvasSize
            self.outputScaleFactors = projectDescriptor.exportedScaleFactors

            let allAnchors = projectDescriptor.anchorPointsBySourceName
            assetLibrary.forEach { (source) in
                source.anchorPoint = allAnchors[source.name] ?? .zero
            }
        }
    }

    // MARK: - Asset Library Data Source

    var numberOfSources: Int {
        return assetLibrary.count
    }

    func source(at index: Int) -> Source {
        return assetLibrary[index]
    }

    // MARK: - Programmatic Operation

    private(set) public var showsOutlines: Bool = false

    public func showOutlines() {
        undoManager?.registerUndo(withTarget: self, handler: { (document) in
            document.hideOutlines()
        })
        if undoManager?.isUndoing == false {
            undoManager?.setActionName("Show outlines")
        }
        showsOutlines = true
        refreshComposition()
    }

    public func hideOutlines() {
        undoManager?.registerUndo(withTarget: self, handler: { (document) in
            document.showOutlines()
        })
        if undoManager?.isUndoing == false {
            undoManager?.setActionName("Hide outlines")
        }
        showsOutlines = false
        refreshComposition()
    }

    public func setCanvasSize(_ newSize: CGSize) {
        let oldSize = canvasSize
        undoManager?.registerUndo(withTarget: self, handler: { (document) in
            document.setCanvasSize(oldSize)
        })
        if undoManager?.isUndoing == false {
            undoManager?.setActionName("Set canvas size")
        }

        self.canvasSize = newSize
        refreshComposition()
    }

    public func addSources(_ newSources: [Source]) {
        undoManager?.registerUndo(withTarget: self, handler: { (document) in
            document.removeSources(newSources)
        })
        if undoManager?.isUndoing == false {
            undoManager?.setActionName("Add sources")
        }

        var duplicateNames: [String] = []
        newSources.forEach { (source) in
            if assetLibrary.contains(source) {
                duplicateNames.append(source.name)
            } else {
                assetLibrary.append(source)
            }
        }

        NotificationCenter.default.post(name: .documentDidModifyLibrary, object: self)
        refreshComposition()

        if duplicateNames.isEmpty == false {
            let list = duplicateNames.joined(separator: ", ")
            let error = NSError(localizedDescription: "Skipped duplicates: \(list).")
            NSAlert(error: error).runModal()
        }
    }

    public func removeSources(_ sourcesToRemove: [Source]) {
        undoManager?.registerUndo(withTarget: self, handler: { (document) in
            document.addSources(sourcesToRemove)
        })
        if undoManager?.isUndoing == false {
            undoManager?.setActionName("Remove Sources")
        }
        sourcesToRemove.forEach { (source) in
            if let index = assetLibrary.firstIndex(of: source) {
                assetLibrary.remove(at: index)
            }
        }

        NotificationCenter.default.post(name: .documentDidModifyLibrary, object: self)
        refreshComposition()
    }

    public func refreshComposition() {
        // Use resolution appropriate for the screen the main window is
        // currently being displayed at:
        guard let window = windowControllers.first?.window else {
            return
        }

        // Pack:
        let sprites = pack(sources: includedSources, in: canvasSize)

        // Attempt preview render:
        do {
            let image = try renderPreview(sprites: sprites, canvasSize: canvasSize, scaleFactor: window.backingScaleFactor, drawOutlines: showsOutlines)
            // Store image in property so notified objects can grab it:
            self.previewImage = image

            /*
             Broadcast completion. Canvas view controller can pick `previewImage`
             for display, and Library can update its collection view's contents to
             reflect the sources that didn't fit.
             */
            NotificationCenter.default.post(name: .documentDidRefreshComposition, object: self)

        } catch {
            NSAlert(error: error).runModal()
        }
    }

    public var librarySortCriterion: SortCriterion = .name {
        didSet {
            switch librarySortCriterion {
            case .name:
                assetLibrary.sort { return $0.name < $1.name }
            case .sizeAscending:
                assetLibrary.sort { return $0.pixelCount < $1.pixelCount }
            case .sizeDescending:
                assetLibrary.sort { return $0.pixelCount > $1.pixelCount }
            }
        }
    }

    // MARK: - Control Actions

    @IBAction func importSources(_ sender: Any) {
        promptImportInput { [unowned self](inputURLs) in

            let folderURLs = inputURLs.filter { $0.hasDirectoryPath }
            let fileURLs = inputURLs.filter { !$0.hasDirectoryPath}

            let added = folderURLs.flatMap { (folderURL) -> [URL] in
                do {
                    let urls = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [])
                    return urls
                } catch {
                    return []
                }
            }

            let urls = fileURLs + added

            let sources = urls.compactMap({ (url) -> Source? in
                guard let source = Source(contentsOfFile: url.path) else {
                    return nil
                }
                source.isIncluded = true
                return source
            })

            self.addSources(sources)
        }
    }

    @IBAction func changeCanvasSize(_ sender: NSMenu) {
        guard let resizeWindowController = NSStoryboard(name: "ResizeCanvas", bundle: nil).instantiateInitialController() as? NSWindowController else {
            fatalError("Storyboard Inconsistency")
        }
        guard let content = resizeWindowController.contentViewController as? ResizeCanvasViewController else {
            fatalError("Storyboard Inconsistency")
        }
        content.size = canvasSize
        content.closeHandler = { [unowned self](accepted) in
            if let newSize = content.size, newSize != self.canvasSize {
                self.setCanvasSize(newSize)
            }
            resizeWindowController.close()
            self.resizeCanvasWindowController = nil
        }
        self.resizeCanvasWindowController = resizeWindowController

        resizeWindowController.showWindow(self)
        resizeWindowController.window?.center()
    }

    @IBAction func outlineCheckboxChanged(_ sender: NSButton) {
        if sender.state == .on {
            showOutlines()
        } else {
            hideOutlines()
        }
    }

    @IBAction func export(_ sender: NSButton) {
        guard let exportWindowController = NSStoryboard(name: "Export", bundle: nil).instantiateInitialController() as? NSWindowController else {
            fatalError("Storyboard Inconsistency")
        }
        guard let content = exportWindowController.contentViewController as? ExportViewController else {
            fatalError("Storyboard Inconsistency")
        }
        content.sources = assetLibrary
        content.selectedScaleFactors = outputScaleFactors

        content.dismissHandler = { [unowned self](accepted) in
            defer {
                exportWindowController.close()
                self.exportWindowController = nil
            }
            guard accepted else {
                return
            }
            // Save scale factors to use in next presentation of the panel:
            self.outputScaleFactors = content.selectedScaleFactors

            // Ask user for a destination directory and proceed:
            promptExportDestination(completionHandler: { [unowned self](url) in
                guard let url = url else {
                    return // (user cancelled NSOpenPanel)
                }
                do {
                    try self.exportTexturesAndMetadata(to: url)
                } catch {
                    NSAlert(error: error).runModal()
                }
            })
        }
        self.exportWindowController = exportWindowController

        exportWindowController.showWindow(self)
        exportWindowController.window?.center()
    }

    // MARK: -

    private func exportTexturesAndMetadata(to rootDirectoryURL: URL) throws {
        let sprites = pack(sources: includedSources, in: canvasSize)

        let name = displayName.components(separatedBy: ".").first!
        try exportTextureSet(name: name, for: sprites, inCanvasSize: canvasSize, atScaleFactors: outputScaleFactors, to: rootDirectoryURL)
        try exportMetadata(name: name, for: sprites, inCanvasSize: canvasSize, to: rootDirectoryURL)
    }
}
