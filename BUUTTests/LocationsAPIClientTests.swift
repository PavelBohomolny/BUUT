//
//  LocationsAPIClientTests.swift
//  BUUTTests
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import XCTest
@testable import BUUT

@MainActor
final class LocationsAPIClientTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.requestHandler = nil
    }

    func testFetchLocationsReturnsDecodedLocations() async throws {
        let session = makeSession()
        let sut = LocationsAPIClient(session: session)
        let expectedURLString = "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json"

        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            XCTAssertEqual(url.absoluteString, expectedURLString)

            let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
            let data = """
            {
              "locations": [
                { "name": "Amsterdam", "lat": 52.3676, "long": 4.9041 },
                { "name": null, "lat": 51.9244, "long": 4.4777 }
              ]
            }
            """.data(using: .utf8) ?? Data()

            return (response, data)
        }

        let locations = try await sut.fetchLocations()

        XCTAssertEqual(locations.count, 2)
        XCTAssertEqual(locations[0].name, "Amsterdam")
        XCTAssertEqual(locations[0].latitude, 52.3676)
        XCTAssertEqual(locations[0].longitude, 4.9041)
        XCTAssertNil(locations[1].name)
    }

    func testFetchLocationsThrowsRequestFailedForNonSuccessStatusCode() async {
        let session = makeSession()
        let sut = LocationsAPIClient(session: session)

        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 503, httpVersion: nil, headerFields: nil))
            return (response, Data())
        }

        do {
            _ = try await sut.fetchLocations()
            XCTFail("Expected fetchLocations() to throw")
        } catch let error as LocationsAPIClientError {
            XCTAssertEqual(error, .requestFailed(statusCode: 503))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchLocationsThrowsDecodingFailedForInvalidPayload() async {
        let session = makeSession()
        let sut = LocationsAPIClient(session: session)

        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
            let data = """
            {
              "items": []
            }
            """.data(using: .utf8) ?? Data()

            return (response, data)
        }

        do {
            _ = try await sut.fetchLocations()
            XCTFail("Expected fetchLocations() to throw")
        } catch let error as LocationsAPIClientError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchLocationsThrowsInvalidResponseForNonHTTPResponse() async {
        let session = makeSession()
        let sut = LocationsAPIClient(session: session)

        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let response = URLResponse(url: url, mimeType: "application/json", expectedContentLength: 0, textEncodingName: nil)
            return (response, Data())
        }

        do {
            _ = try await sut.fetchLocations()
            XCTFail("Expected fetchLocations() to throw")
        } catch let error as LocationsAPIClientError {
            XCTAssertEqual(error, .invalidResponse)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchLocationsMapsURLErrorToNetworkError() async {
        let session = makeSession()
        let sut = LocationsAPIClient(session: session)

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            _ = try await sut.fetchLocations()
            XCTFail("Expected fetchLocations() to throw")
        } catch let error as LocationsAPIClientError {
            XCTAssertEqual(error, .network(.notConnectedToInternet))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
