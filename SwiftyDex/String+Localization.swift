//
//  String+Localization.swift
//  SwiftyDex
//
//  Created by Jason Pierna on 31/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
