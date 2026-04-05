//
//  LocationsViewController.swift
//  BUUT
//
//  Created by Pavel Bohomolnyi on 05/04/2026.
//

import UIKit

@MainActor
final class LocationsViewController: UIViewController {
    private let viewModel: LocationsViewModel
    private var rows: [LocationRowViewModel] = []

    private var locationsView: LocationsView {
        guard let view = view as? LocationsView else {
            fatalError("Expected LocationsView")
        }

        return view
    }

    init(viewModel: LocationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = LocationsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Locations"
        navigationItem.largeTitleDisplayMode = .always

        locationsView.tableView.dataSource = self

        loadLocations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func loadLocations() {
        locationsView.activityIndicatorView.startAnimating()
        locationsView.messageLabel.isHidden = false
        locationsView.tableView.isHidden = true

        Task {
            do {
                let locations = try await viewModel.loadLocations()
                showLocations(locations)
            } catch {
                showError(error)
            }
        }
    }

    private func showLocations(_ rows: [LocationRowViewModel]) {
        self.rows = rows
        locationsView.activityIndicatorView.stopAnimating()
        locationsView.messageLabel.isHidden = !rows.isEmpty
        locationsView.messageLabel.text = rows.isEmpty ? "No locations found." : nil
        locationsView.tableView.isHidden = rows.isEmpty
        locationsView.tableView.reloadData()
    }

    private func showError(_ error: Error) {
        locationsView.activityIndicatorView.stopAnimating()
        locationsView.tableView.isHidden = true
        locationsView.messageLabel.isHidden = false
        locationsView.messageLabel.text = errorMessage(for: error)
    }

    private func errorMessage(for error: Error) -> String {
        (error as? LocationsAPIClientError)?.message ?? "Could not load locations."
    }
}

extension LocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseIdentifier, for: indexPath) as? LocationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: row)
        return cell
    }
}
