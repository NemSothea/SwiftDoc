//
//  WeatherType.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//


// Models/JournalEntry.swift
import Foundation
import SwiftData

enum WeatherType: String, CaseIterable {
    case sunny = "ក្តៅហាប"      // Sunny
    case rainy = "ភ្លៀង"        // Rainy
    case cloudy = "ពពក"         // Cloudy
    case windy = "ខ្យល់"        // Windy
}

@Model
class JournalEntry {
    var date: Date
    var content: String
    var weather: String
    var photoData: Data?  // Store image as Data
    var location: String?
    
    init(date: Date = Date(), content: String, weather: String = "sunny", photoData: Data? = nil, location: String? = nil) {
        self.date = date
        self.content = content
        self.weather = weather
        self.photoData = photoData
        self.location = location
    }
}