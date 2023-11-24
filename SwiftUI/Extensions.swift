//
//  Extensions.swift
//  Card Tracker
//
//  Created by Michael Rowe on 9/22/23.
//  Copyright © 2023 Michael Rowe. All rights reserved.
//

import SwiftUI

// Extension to safely access array elements
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
