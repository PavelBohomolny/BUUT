//
//  Location.swift
//  BUUT
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import Foundation

struct Location: Codable {
    let name: String?
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "long"
    }
}

extension Location {
    var displayName: String {
        let locationName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (locationName?.isEmpty == false ? locationName : nil) ?? "Unknown location"
    }
}
