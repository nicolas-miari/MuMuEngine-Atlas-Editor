//
//  CanvasViewController.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Cocoa

/**
 Manages the view that displays the preview of the fitted atlas that will be
 exported.
 */
final class CanvasViewController: NSViewController {

    @IBOutlet private(set) weak var scrollView: NSScrollView!
    @IBOutlet weak var zoomComboBox: NSComboBox!
    @IBOutlet weak var outlinesCheckbox: NSButton!

    private var contentImageView: NSImageView!

    var document: Document? {
        return (representedObject as? Document)
    }

    override var representedObject: Any? {
        didSet {
            updateUI()
        }
    }

    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        NotificationCenter.default.addObserver(self, selector: #selector(didRefreshComposition(_:)), name: .documentDidRefreshComposition, object: nil)
    }

    private func updateUI() {
        outlinesCheckbox?.state = document?.showsOutlines == true ? .on : .off
        zoomComboBox?.stringValue = "100%"
    }

    // MARK: -

    @objc func didRefreshComposition(_ notification: Notification) {
        guard let image = document?.previewImage else {
            return
        }
        self.setImage(image)
    }

    private func setImage(_ image: CGImage) {
        let content = NSImage(cgImage: image, size: .zero)
        let imageView = NSImageView(image: content)
        imageView.frame = NSRect(origin: .zero, size: content.size)

        // Preserve scrolling position while we update the content:

        let offset = scrollView.documentVisibleRect.origin
        scrollView.documentView = imageView
        scrollView.scroll(offset)
    }

    // MARK: - Control Actions

    @IBAction func zoomChanged(_ sender: Any) {
        let text = zoomComboBox.stringValue.replacingOccurrences(of: "%", with: "")
        guard let percentage = Float(text) else {
            return
        }
        let scale = percentage / 100.0

        scrollView.setMagnification(CGFloat(scale), centeredAt: .zero)
    }
}
