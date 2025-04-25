//
//  WeatherViewController.swift
//  MonoWeather
//
//  Created by Phillip on 25.04.2025.
//

import UIKit

final class WeatherViewController: UIViewController {
    private let viewModel = WeatherViewModel()

    private let label = UILabel()
    private let textField = UITextField()
    private let resetButton = UIButton(type: .system)
    private let measurementControl = UISegmentedControl(items: ["Celsius", "Fahrenheit"])

    private var isMetric = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()

        if viewModel.wasManualLocationSelected(),
           let cached = viewModel.loadWeatherFromCache() {
            textField.text = cached.0
            label.text = "\(cached.0): \(cached.1)°"
            fetchWeather(for: cached.0)
        } else {
            fetchWeatherByLocation()
        }
    }

    private func setupLayout() {
        label.text = "Загрузка погоды..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .medium)

        textField.placeholder = "Введите город"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.delegate = self

        resetButton.setTitle("Сброс", for: .normal)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)

        measurementControl.selectedSegmentIndex = 0
        measurementControl.addTarget(self, action: #selector(measurementChanged), for: .valueChanged)

        let hStack = UIStackView(arrangedSubviews: [textField, resetButton])
        hStack.axis = .horizontal
        hStack.spacing = 10

        let vStack = UIStackView(arrangedSubviews: [measurementControl, label, hStack])
        vStack.axis = .vertical
        vStack.spacing = 20

        view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textField.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc private func measurementChanged() {
        isMetric = measurementControl.selectedSegmentIndex == 0

        if viewModel.wasManualLocationSelected(),
           let cached = viewModel.loadWeatherFromCache() {
            fetchWeather(for: cached.0)
        } else {
            fetchWeatherByLocation()
        }
    }

    private func fetchWeatherByLocation() {
        viewModel.fetchWeather(isMetric: isMetric) { [weak self] city, temp in
            DispatchQueue.main.async {
                self?.label.text = "\(city): \(temp)°"
            }
        }
    }

    private func fetchWeather(for city: String) {
        viewModel.fetchWeather(for: city, isMetric: isMetric) { [weak self] city, temp in
            DispatchQueue.main.async {
                self?.label.text = "\(city): \(temp)°"
            }
        }
    }

    @objc private func resetTapped() {
        textField.text = ""
        viewModel.saveWeatherToCache(city: "", temp: 0, isManual: false)
        fetchWeatherByLocation()
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let city = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !city.isEmpty else {
            return false
        }

        textField.resignFirstResponder()
        viewModel.saveWeatherToCache(city: city, temp: 0, isManual: true)
        fetchWeather(for: city)
        return true
    }
}
