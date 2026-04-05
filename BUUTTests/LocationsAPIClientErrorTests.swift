//
//  LocationsAPIClientErrorTests.swift
//  BUUTTests
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import XCTest
@testable import BUUT

final class LocationsAPIClientErrorTests: XCTestCase {
    func testMessageForNoInternetConnection() {
        let error = LocationsAPIClientError.network(.notConnectedToInternet)

        XCTAssertEqual(error.message, "No internet connection. Please check your network settings.")
    }

    func testMessageForTimedOutRequest() {
        let error = LocationsAPIClientError.network(.timedOut)

        XCTAssertEqual(error.message, "The request timed out. Please try again.")
    }

    func testMessageForRequestFailureStatusCode() {
        let error = LocationsAPIClientError.requestFailed(statusCode: 500)

        XCTAssertEqual(error.message, "The request failed with status code 500.")
    }

    func testMessageForDecodingFailure() {
        let error = LocationsAPIClientError.decodingFailed

        XCTAssertEqual(error.message, "Could not read the locations data.")
    }
}
