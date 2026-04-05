//
//  LocationsViewModel.swift
//  BUUT
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import Foundation

@MainActor
final class LocationsViewModel {
    private let locationsFetcher: LocationsFetching

    init(locationsFetcher: LocationsFetching = LocationsAPIClient()) {
        self.locationsFetcher = locationsFetcher
    }

    func loadLocations() async throws -> [LocationRowViewModel] {
        let locations = try await locationsFetcher.fetchLocations()

        return locations.map {
            LocationRowViewModel(title: $0.displayName, subtitle: $0.formattedCoordinates)
        }
    }
}
