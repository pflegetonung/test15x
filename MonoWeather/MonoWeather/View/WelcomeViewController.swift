//
//  WelcomeViewController.swift
//  MonoWeather
//
//  Created by Phillip on 25.04.2025.
//

import UIKit
import CoreLocation

final class WelcomeViewController: UIViewController {
    private let viewModel = WelcomeViewModel()

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Разрешите доступ к геолокации"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Разрешить", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        checkLocationStatus()
        setupLayout()
        button.addTarget(self, action: #selector(handleRequest), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(label)
        view.addSubview(button)
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func handleRequest() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined, .authorizedWhenInUse, .authorizedAlways:
            viewModel.requestLocationPermission { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .authorized:
                        let weatherVC = WeatherViewController()
                        UIApplication.shared.windows.first?.rootViewController = weatherVC
                    case .denied:
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL)
                    case .notDetermined:
                        break
                    }
                }
            }
        case .denied, .restricted:
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        default:
            break
        }
    }

    private func checkLocationStatus() {
        let status = CLLocationManager.authorizationStatus()

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            let weatherVC = WeatherViewController()
            UIApplication.shared.windows.first?.rootViewController = weatherVC
        }
    }
}
