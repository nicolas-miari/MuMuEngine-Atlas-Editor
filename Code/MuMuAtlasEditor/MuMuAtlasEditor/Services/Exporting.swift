//
//  TextureExport.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/27.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

/**
 Exports a `.textureset` directory for use within Xcode asset catalogs.
 */
func exportTextureSet(
    name: String,
    for sprites: [Sprite],
    inCanvasSize canvasSize: CGSize,
    atScaleFactors scaleFactors: Set<CGFloat>,
    to baseDirectory: URL) throws {

    let fileManager = FileManager.default

    // 1. Create .textureset directory (asset catalog entry)
    //
    let textureSetFolderName = name + ".textureset"
    let textureSetFolderURL = baseDirectory.appendingPathComponent(textureSetFolderName)

    if fileManager.fileExists(atPath: textureSetFolderURL.path, isDirectory: nil) {
        try fileManager.removeItem(at: textureSetFolderURL)
    }

    try fileManager.createDirectory(at: textureSetFolderURL, withIntermediateDirectories: false, attributes: nil)

    // 2. Create top-level Contents.json file:
    //
    let infoDictionary: [String: Any] = ["version": 1, "author": "xcode"]
    let propertiesDictionary: [String: Any] = ["interpretation": "non-premultiplied-colors"]
    let textureDictionaries = scaleFactors.map { (scaleFactor) -> [String: Any] in
        return [
            "idiom": "universal",
            "filename": "Universal \(Int(scaleFactor))x.mipmapset",
            "scale": "\(Int(scaleFactor))x"
        ]
    }
    let topDictionary: [String: Any] = [
        "properties": propertiesDictionary,
        "info": infoDictionary,
        "textures": textureDictionaries
    ]

    let topJSONURL = textureSetFolderURL.appendingPathComponent("Contents.json")
    let topJSONData = try JSONSerialization.data(withJSONObject: topDictionary, options: .prettyPrinted)
    try topJSONData.write(to: topJSONURL)

    // 3. Create mipmaps subdirectory for each scale factor:
    //
    try scaleFactors.forEach({ (scaleFactor) in
        // 3.1 Create Directory
        //
        let directoryURL = textureSetFolderURL.appendingPathComponent("Universal \(Int(scaleFactor))x.mipmapset")
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)

        // 3.2 Write Contents.json file:
        //
        let imageFileName = name + "@\(Int(scaleFactor))x.png"
        let json: [String: Any] = [
            "info": infoDictionary,
            "levels": [["filename": imageFileName, "mipmap-level": "base"]]
        ]
        let jsonURL = directoryURL.appendingPathComponent("Contents.json")
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        try jsonData.write(to: jsonURL)

        // 3.3 Render texture image and write as .png file:
        //
        let image = try renderTexture(sprites: sprites, canvasSize: canvasSize, scaleFactor: scaleFactor)
        let imageData = try image.pngData()
        let imageFileURL = directoryURL.appendingPathComponent(imageFileName)
        try imageData.write(to: imageFileURL)
    })
}

/**
 Exports a JSON file containing the information about the location of each name
 subimage (sprite) within the atlas's texture.
 */
func exportMetadata(
    name: String,
    for sprites: [Sprite],
    inCanvasSize canvasSize: CGSize,
    to baseDirectory: URL) throws {

    let entries = sprites.map { MetadataSprite(name: $0.name.removingScaleFactorSpecifier, rotated: $0.rotated, opaque: $0.isOpaque, rect: $0.targetRect) }
    let metadata = Metadata(sprites: entries)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try encoder.encode(metadata)
    let fileName = name + ".json"
    let fileURL = baseDirectory.appendingPathComponent(fileName)
    try jsonData.write(to: fileURL)
}

private struct MetadataSprite: Codable {
    let name: String
    let rotated: Bool
    let opaque: Bool
    let rect: CGRect
}

private struct Metadata: Codable {
    let sprites: [MetadataSprite]
}

extension String {
    var removingScaleFactorSpecifier: String {
        return self.components(separatedBy: "@").first ?? self
    }
}
