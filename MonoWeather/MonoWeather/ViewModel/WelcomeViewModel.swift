//
//  WelcomeViewModel.swift
//  MonoWeather
//
//  Created by Phillip on 25.04.2025.
//

import Foundation

final class WelcomeViewModel {
    private let locationService = LocationService()

    enum LocationStatus {
        case authorized
        case denied
        case notDetermined
    }

    func requestLocationPermission(completion: @escaping (LocationStatus) -> Void) {
        locationService.requestAuthorization { status in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                completion(.authorized)
            case .denied, .restricted:
                completion(.denied)
            case .notDetermined:
                completion(.notDetermined)
            @unknown default:
                completion(.denied)
            }
        }
    }
}
