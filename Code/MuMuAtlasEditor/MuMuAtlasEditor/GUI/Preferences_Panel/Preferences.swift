//
//  Preferences.swift
//  AtlasEditor
//
//  Created by Nicolás Miari on 2019/03/13.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

/**
 By default, scale factor of source images is determined by specifiers included
 in the file name (e.g., @3x, @2x, @1x or null), which are automatically
 stripped to produce the initial name of the source (which can be changed in the
 editor).

 Supported output scale factors are configurable, but if a source was imported
 in a scale factor smaller than the maximum target, upsampling occurs (and
 warnings are emitted).
 */
class Preferences {

}
