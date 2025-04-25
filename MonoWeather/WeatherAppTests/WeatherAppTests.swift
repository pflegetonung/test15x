//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Phillip on 25.04.2025.
//

import Testing
import Foundation
@testable import MonoWeather

struct WeatherAppTests {
    @Test func testWeatherCache() throws {
        let viewModel = WeatherViewModel()
        viewModel.saveWeatherToCache(city: "TestCity", temp: 23, isManual: true)

        let result = viewModel.loadWeatherFromCache()

        #expect(result != nil)
        #expect(result?.0 == "TestCity")
        #expect(result?.1 == 23)
    }

    @Test func testWeatherParsing() throws {
        let json = """
        {
            "name": "Saint Petersburg",
            "main": {
                "temp": 11.3
            }
        }
        """.data(using: .utf8)!

        let weather = try JSONDecoder().decode(Weather.self, from: json)

        #expect(weather.name == "Saint Petersburg")
        #expect(Int(weather.main.temp) == 11)
    }
}
