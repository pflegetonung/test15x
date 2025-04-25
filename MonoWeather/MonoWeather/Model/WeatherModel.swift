//
//  WeatherModel.swift
//  MonoWeather
//
//  Created by Phillip on 25.04.2025.
//

import Foundation

struct Weather: Decodable {
    let name: String
    let main: Main

    struct Main: Decodable {
        let temp: Double
    }
}
