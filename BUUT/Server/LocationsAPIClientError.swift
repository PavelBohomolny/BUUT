//
//  LocationsAPIClientError.swift
//  BUUT
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import Foundation

enum LocationsAPIClientError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed
    case network(URLError.Code)
}

extension LocationsAPIClientError {
    var message: String {
        switch self {
        case .invalidURL:
            return "The locations URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case let .requestFailed(statusCode):
            return "The request failed with status code \(statusCode)."
        case .decodingFailed:
            return "Could not read the locations data."
        case let .network(code):
            switch code {
            case .notConnectedToInternet:
                return "No internet connection. Please check your network settings."
            case .timedOut:
                return "The request timed out. Please try again."
            case .badServerResponse:
                return "The server returned an unexpected response."
            case .cannotFindHost, .cannotConnectToHost:
                return "Could not connect to the server."
            default:
                return "A network error occurred. Please try again."
            }
        }
    }
}
