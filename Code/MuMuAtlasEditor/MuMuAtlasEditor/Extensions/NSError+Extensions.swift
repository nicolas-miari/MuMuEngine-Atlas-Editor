//
//  NSError+Extensions.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/14.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

extension NSError {
    convenience init(localizedDescription: String) {
        self.init(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
    }
}
