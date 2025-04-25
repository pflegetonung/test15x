//
//  WeatherViewModel.swift
//  MonoWeather
//
//  Created by Phillip on 25.04.2025.
//

import Foundation
import CoreLocation

final class WeatherViewModel: NSObject {
    private let session = URLSession.shared
    private let apiKey = "92087b1e019c21a37c5a047cef5e0b57"
    
    private var locationManager: CLLocationManager?
    private var locationCompletion: ((CLLocationCoordinate2D) -> Void)?
    
    private let cityKey = "saved_city"
    private let tempKey = "saved_temp"
    private let manualFlagKey = "is_manual_location"

    func saveWeatherToCache(city: String, temp: Int, isManual: Bool) {
        let weatherData: [String: Any] = ["city": city, "temperature": temp]
        UserDefaults.standard.set(weatherData, forKey: "cachedWeatherData")
        UserDefaults.standard.set(isManual, forKey: manualFlagKey)
    }

    func loadWeatherFromCache() -> (String, Int)? {
        if let cachedData = UserDefaults.standard.dictionary(forKey: "cachedWeatherData"),
           let city = cachedData["city"] as? String,
           let temperature = cachedData["temperature"] as? Int {
            return (city, temperature)
        }
        return nil
    }
    
    func wasManualLocationSelected() -> Bool {
        return UserDefaults.standard.bool(forKey: manualFlagKey)
    }

    func clearManualFlag() {
        UserDefaults.standard.set(false, forKey: manualFlagKey)
    }

    func fetchWeather(isMetric: Bool, completion: @escaping (String, Int) -> Void) {
            getLocation { [weak self] coordinate in
                guard let self = self else { return }

                let units = isMetric ? "metric" : "imperial"
                let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(self.apiKey)&units=\(units)&lang=ru"

                guard let url = URL(string: urlString) else { return }

                self.session.dataTask(with: url) { data, _, error in
                    guard let data = data else { return }

                    do {
                        let weather = try JSONDecoder().decode(Weather.self, from: data)
                        let city = weather.name
                        let temperature = Int(weather.main.temp)
                        completion(city, temperature)
                    } catch {
                        print("Ошибка парсинга (гео): \(error.localizedDescription)")
                    }
                }.resume()
            }
        }

    func fetchWeather(for city: String, isMetric: Bool, completion: @escaping (String, Int) -> Void) {
            let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
            let units = isMetric ? "metric" : "imperial"  
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityEncoded)&appid=\(self.apiKey)&units=\(units)&lang=ru"

            guard let url = URL(string: urlString) else { return }

            session.dataTask(with: url) { data, _, error in
                guard let data = data else { return }

                do {
                    let weather = try JSONDecoder().decode(Weather.self, from: data)
                    let city = weather.name
                    let temperature = Int(weather.main.temp)
                    completion(city, temperature)
                } catch {
                    print("Ошибка парсинга (город): \(error.localizedDescription)")
                }
            }.resume()
        }

    private func getLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        locationCompletion = completion
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationCompletion?(location.coordinate)
        }
        locationManager = nil
        locationCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка геолокации: \(error.localizedDescription)")
        locationManager = nil
        locationCompletion = nil
    }
}
