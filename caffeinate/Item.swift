//
//  Item.swift
//  caffeinate
//
//  Created by Evgeny Abramovich on 2026-09-14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
