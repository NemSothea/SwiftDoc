//
//  Untitled.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        // Handle both color names and hex values
        let colorMap: [String: String] = [
            "blue": "007AFF",
            "green": "34C759",
            "red": "FF3B30",
            "orange": "FF9500",
            "purple": "AF52DE",
            "pink": "FC0FC0",
            "yellow": "FFCC00"
        ]
        
        let hexValue = colorMap[hex] ?? hex
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
