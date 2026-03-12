//
//  Date+Khmer.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//

// Utilities/Extensions/Date+Khmer.swift
import Foundation

extension Date {
    func khmerFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "km-KH")
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
}
