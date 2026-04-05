//
//  LocationsViewModelTests.swift
//  BUUTTests
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import XCTest
@testable import BUUT

@MainActor
final class LocationsViewModelTests: XCTestCase {
    func testLoadLocationsMapsFetchedLocationsIntoRows() async throws {
        let fetcher = MockLocationsFetcher(
            result: .success([
                Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041),
                Location(name: "Rotterdam", latitude: 51.9244, longitude: 4.4777)
            ])
        )
        
        let sut = LocationsViewModel(locationsFetcher: fetcher)
        let rows = try await sut.loadLocations()

        XCTAssertEqual(rows, [
            LocationRowViewModel(title: "Amsterdam", subtitle: "52.3676, 4.9041"),
            LocationRowViewModel(title: "Rotterdam", subtitle: "51.9244, 4.4777")
        ])
    }

    func testLoadLocationsUsesFallbackNameWhenNameIsMissingOrBlank() async throws {
        let fetcher = MockLocationsFetcher(
            result: .success([
                Location(name: nil, latitude: 52.3676, longitude: 4.9041),
                Location(name: "   ", latitude: 51.9244, longitude: 4.4777)
            ])
        )
        
        let sut = LocationsViewModel(locationsFetcher: fetcher)
        let rows = try await sut.loadLocations()

        XCTAssertEqual(rows[0].title, "Unknown location")
        XCTAssertEqual(rows[1].title, "Unknown location")
    }

    func testLoadLocationsFormatsCoordinatesToFourDecimalPlaces() async throws {
        let fetcher = MockLocationsFetcher(
            result: .success([
                Location(name: "New York", latitude: 40.712776, longitude: -74.005974)
            ])
        )
        
        let sut = LocationsViewModel(locationsFetcher: fetcher)
        let rows = try await sut.loadLocations()

        XCTAssertEqual(rows.first?.subtitle, "40.7128, -74.0060")
    }

    func testLoadLocationsPropagatesFetcherError() async {
        let fetcher = MockLocationsFetcher(result: .failure(LocationsAPIClientError.network(.timedOut)))
        let sut = LocationsViewModel(locationsFetcher: fetcher)

        do {
            _ = try await sut.loadLocations()
            XCTFail("Expected loadLocations() to throw")
        } catch let error as LocationsAPIClientError {
            XCTAssertEqual(error, .network(.timedOut))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private struct MockLocationsFetcher: LocationsFetching {
    let result: Result<[Location], Error>

    func fetchLocations() async throws -> [Location] {
        try result.get()
    }
}
