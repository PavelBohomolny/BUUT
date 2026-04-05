//
//  LocationsAPIClient.swift
//  BUUT
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import Foundation

protocol LocationsFetching {
    func fetchLocations() async throws -> [Location]
}

struct LocationsAPIClient: LocationsFetching {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func fetchLocations() async throws -> [Location] {
        guard let url = URL(string: Constants.urlString) else {
            throw LocationsAPIClientError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LocationsAPIClientError.invalidResponse
        }

        let statusCode = httpResponse.statusCode

        guard statusCode >= 200 && statusCode < 300 else {
            throw LocationsAPIClientError.requestFailed(statusCode: statusCode)
        }

        let locationsResponse = try decoder.decode(LocationsResponse.self, from: data)

        return locationsResponse.locations
    }
}

enum LocationsAPIClientError: Error, Equatable {
    case invalidResponse
    case requestFailed(statusCode: Int)
}

extension LocationsAPIClient {
    enum Constants {
        static let urlString = "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json"
    }
}
