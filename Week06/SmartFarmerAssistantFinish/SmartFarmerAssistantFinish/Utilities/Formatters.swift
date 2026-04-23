//
//  Formatters.swift
//  SmartFarmerAssistantFinish
//
//  Stateless display helpers. Previously lived as methods on the shared
//  view model, which forced every view that wanted to format a date or
//  currency to inject the whole view model — extracted here so any view
//  can just call `date.formattedMedium` or `amount.formattedCurrency`.
//

import Foundation

extension Date {
    /// Medium-style date (e.g. "Apr 21, 2026"), no time component.
    var formattedMedium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

extension Double {
    /// USD-formatted currency (e.g. "$12.34"). Falls back to "$0.00".
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
