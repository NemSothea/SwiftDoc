//
//  ActivityType.swift
//  SmartFarmerAssistantExample
//
//  Created by sothea007 on 1/3/26.
//


// Models/FarmActivity.swift
import Foundation
import SwiftData

enum ActivityType: String, CaseIterable {
    case planting = "ដាំ"           // Planting
    case watering = "ស្រោចទឹក"     // Watering
    case fertilizing = "ដាក់ជី"     // Fertilizing
    case harvesting = "ប្រមូលផល"   // Harvesting
    case pesticide = "បាញ់ថ្នាំ"    // Pesticide
    case other = "ផ្សេងៗ"           // Other
}

@Model
class FarmActivity {
    var title: String
    var activityType: String
    var date: Date
    var notes: String
    var isCompleted: Bool
    var reminderEnabled: Bool
    
    init(title: String, activityType: String, date: Date, notes: String = "", isCompleted: Bool = false, reminderEnabled: Bool = true) {
        self.title = title
        self.activityType = activityType
        self.date = date
        self.notes = notes
        self.isCompleted = isCompleted
        self.reminderEnabled = reminderEnabled
    }
}