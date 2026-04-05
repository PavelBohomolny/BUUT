# BUUT

`BUUT` is a small UIKit-based iOS app that fetches a list of locations from a remote JSON endpoint and displays them in a list on launch.

This project was built as part of an iOS technical assignment. The app focuses on a clean UIKit foundation, simple structure, readable code, and testable components.

## Features

- Fetches locations from a remote JSON source
- Displays locations in a UIKit list screen
- Handles loading, empty, and error states
- Uses dependency injection for easier testing
- Includes unit tests for the data and view model layers
- Includes a basic UI smoke test

## Data Source

The app fetches data from:

[`https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json`](https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json)

## Requirements

- Xcode 26 or newer
- iOS Simulator
- iOS 18.0 deployment target

## Installation

1. Clone the repository:

```bash
git clone https://github.com/PavelBohomolny/BUUT
```

2. Open the project in Xcode:

```bash
open BUUT.xcodeproj
```

3. Select the `BUUT` scheme.

4. Run the app on an iPhone simulator.

## Project Structure

The project is intentionally small and split by responsibility:

```text
BUUT/
  App/
    SceneDelegate.swift
  Core/
    LocationsList/
      Model/
      View/
      ViewModel/
  Extensions/
  Server/
  Shared/
```

### Main folders

- `App`
  App entry and scene setup. The root `UINavigationController` is configured here.

- `Core/LocationsList/Model`
  Location models and response decoding types.

- `Core/LocationsList/View`
  UIKit views, view controller, and table view cell for the locations screen.

- `Core/LocationsList/ViewModel`
  View-model mapping between fetched data and UI row models.

- `Extensions`
  Small formatting helpers and lightweight extensions used by the feature.

- `Server`
  Networking layer, fetch protocol, API client, and API error definitions.

- `Shared`
  Shared app resources such as `Info.plist` and asset catalogs.

## Architecture Notes

The app uses a lightweight UIKit + MVVM-style structure:

- `LocationsAPIClient` handles remote fetching and decoding
- `LocationsViewModel` maps `Location` models into row view models
- `LocationsViewController` coordinates screen state and table updates
- `LocationsView` owns the screen UI components

The goal was to keep the code straightforward and easy to review, without adding unnecessary layers for a small assignment.

## Error Handling

The app includes explicit API error cases for:

- invalid URL
- invalid server response
- failed HTTP status code
- decoding failure
- network errors such as no internet or timeout

User-facing error messages are defined in the API error layer and presented by the screen when loading fails.

## Testing

The project includes both unit and UI tests.

### Unit tests

Unit tests cover:

- location mapping in the view model
- fallback naming for missing location names
- coordinate formatting
- API client error messages
- API client success and failure cases

### UI tests

UI tests cover:

- basic launch flow
- visibility of the `Locations` screen on app launch

### Running tests

In Xcode:

1. Open the project
2. Select the `BUUT` scheme
3. Press `Cmd + U`

From Terminal:

```bash
xcodebuild -project BUUT.xcodeproj -scheme BUUT -destination 'generic/platform=iOS Simulator' build-for-testing
```

## Design Decisions

- UIKit is used as the app foundation, as required by the assignment
- Navigation is configured in code with `UINavigationController`
- The app does not rely on a main storyboard for screen flow
- The launch screen is kept as a storyboard, which is standard for iOS apps
- Dependencies are injected explicitly to improve readability and testability

## License

This project is free to use for learning, review, and evaluation purposes.
