//
//  ProjectDescriptor.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/12.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

enum SortCriterion: Int, Codable {
    case name = 0
    case sizeDescending
    case sizeAscending
}

struct ProjectDescriptor: Codable {

    var includedSourceNames: [String]

    var librarySortCriterion: SortCriterion

    var canvasSize: CGSize

    var showsOutlines: Bool

    var exportedScaleFactors: Set<CGFloat>

    var anchorPointsBySourceName: [String: CGPoint] = [:]

    init() {
        self.includedSourceNames = []
        self.canvasSize = .zero
        self.showsOutlines = false
        self.librarySortCriterion = .name
        self.exportedScaleFactors = Set<CGFloat>()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.includedSourceNames = try container.decode([String].self, forKey: .includedSourceNames)
        self.canvasSize = try container.decode(CGSize.self, forKey: .canvasSize)
        self.showsOutlines = try container.decode(Bool.self, forKey: .showsOutlines)
        self.librarySortCriterion = try container.decode(SortCriterion.self, forKey: .librarySortCriterion)
        self.exportedScaleFactors = try container.decode(Set<CGFloat>.self, forKey: .exportedScaleFactors)
        self.anchorPointsBySourceName = try container.decodeIfPresent([String: CGPoint].self, forKey: .anchorPointsBySourceName) ?? [:]
    }
}
