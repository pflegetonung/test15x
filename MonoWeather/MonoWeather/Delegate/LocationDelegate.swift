//
//  LocationDelegate.swift
//  MonoWeather
//
//  Created by Phillip on 25.04.2025.
//

import Foundation
import CoreLocation

final class LocationDelegate: NSObject, CLLocationManagerDelegate {
    private var completion: (CLLocationCoordinate2D) -> Void

    init(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        self.completion = completion
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            completion(location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения координат: \(error)")
    }
}
