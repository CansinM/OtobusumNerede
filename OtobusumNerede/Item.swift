//
//  Item.swift
//  OtobusumNerede
//
//  Created by Cansın Memiş on 23.09.2024.
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
