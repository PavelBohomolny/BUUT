//
//  LocationsAPIClientError.swift
//  BUUT
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import Foundation

enum LocationsAPIClientError: Error, Equatable {
    case invalidResponse
    case requestFailed(statusCode: Int)
}
