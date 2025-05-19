//
//  DateStringFormat.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import Foundation

// MARK: - Date Format Enum

/// Predefined date formatting options.
enum DateFormat: String {
    case ddMMYYYY = "dd.MM.YYYY"
}

// MARK: - Date Formatting Extension

extension Date {
    /// Returns the date as a string formatted using the specified date format.
    /// - Parameter format: A custom-defined `DateFormat`.
    /// - Returns: A formatted date string.
    func string(format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
