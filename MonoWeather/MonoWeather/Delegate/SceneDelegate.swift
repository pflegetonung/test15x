//
//  SceneDelegate.swift
//  MonoWeather
//
//  Created by Phillip on 24.04.2025.
//

import UIKit
import CoreLocation
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        checkLocationAccess()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        checkLocationAccess()
    }

    private func checkLocationAccess() {
        let status = CLLocationManager.authorizationStatus()

        if status == .notDetermined || status == .denied || status == .restricted {
            window?.rootViewController = WelcomeViewController()
            window?.makeKeyAndVisible()
            return
        }

        let monitor = NWPathMonitor()
        let semaphore = DispatchSemaphore(value: 0)
        var isConnected = false

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isConnected = true
            } else {
                isConnected = false
            }
            semaphore.signal()
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        semaphore.wait()
        monitor.cancel()

        let vc: UIViewController = isConnected ? WeatherViewController() : ConnectionViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}
