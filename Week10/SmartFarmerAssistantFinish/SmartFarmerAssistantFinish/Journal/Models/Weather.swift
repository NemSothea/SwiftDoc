// Journal/Models/Weather.swift
import SwiftUI

enum Weather: String, CaseIterable, Identifiable {
    case sunny
    case rainy
    case cloudy
    case windy

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .sunny:  return "sun.max.fill"
        case .rainy:  return "cloud.rain.fill"
        case .cloudy: return "cloud.fill"
        case .windy:  return "wind"
        }
    }

    var label: String {
        switch self {
        case .sunny:  return "ថ្ងៃល្អ"
        case .rainy:  return "ភ្លៀង"
        case .cloudy: return "មានពពក"
        case .windy:  return "មានខ្យល់"
        }
    }

    /// Tint used for the detail-screen weather badge and timeline icons.
    var tint: Color {
        switch self {
        case .sunny:  return .yellow
        case .rainy:  return .blue
        case .cloudy: return .gray
        case .windy:  return .teal
        }
    }
}
