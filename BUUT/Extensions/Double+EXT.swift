//
//  Double+EXT.swift
//  BUUT
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import Foundation

extension Location {
    var formattedCoordinates: String {
        String(format: "%.4f, %.4f", latitude, longitude)
    }
}
