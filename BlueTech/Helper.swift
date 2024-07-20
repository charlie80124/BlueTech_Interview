//
//  Helper.swift
//  BlueTech
//
//  Created by Lan on 2024/7/20.
//

import Foundation


extension DateFormatter {
    static let quoteTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

extension Decimal {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 4
        formatter.groupingSeparator = ""
        return formatter
    }()
    var formattedString: String {
        return Decimal.formatter.string(from: self as NSNumber) ?? "0.0000"
    }
}
