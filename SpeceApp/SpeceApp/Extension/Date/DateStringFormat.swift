//
//  DateStringFormat.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import Foundation

enum DateFormat: String {
    case ddMMYYYY = "dd.MM.YYYY"
}

extension Date {
    func string(format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
