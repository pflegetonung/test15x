//
//  LocationService.swift
//  MonoWeather
//
//  Created by Phillip on 25.04.2025.
//

import Foundation
import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var authCallback: ((CLAuthorizationStatus) -> Void)?

    func requestAuthorization(completion: @escaping (CLAuthorizationStatus) -> Void) {
        authCallback = completion
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        authCallback?(status)
        authCallback = nil
    }
}
