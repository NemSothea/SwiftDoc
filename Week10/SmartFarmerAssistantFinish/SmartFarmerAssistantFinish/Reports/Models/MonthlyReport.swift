// Reports/Models/MonthlyReport.swift
import Foundation

struct MonthlyReport: Identifiable {
    let id      = UUID()
    let month:   Date
    let income:  Double
    let expense: Double

    var profit: Double { income - expense }

    var monthLabel: String {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df.string(from: month)
    }

    var monthYearLabel: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df.string(from: month)
    }
}
