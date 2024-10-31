//
//  FormHelper.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import Foundation

typealias FH = FormHelper

struct FormHelper {

    static func fill<T>(_ entity: Entity?, to: inout T, using fillMethod: (Entity, inout T) -> Void) {
        guard let entity = entity else { return }
        fillMethod(entity, &to)
    }

    static func fillDate(_ dateEntity: Entity, _ date: inout Date) {
        guard case let .datetime(datetime) = dateEntity,
              let month = datetime.month,
              let day = datetime.day else { return }
        
        let calendar = Calendar.current
        // NOTE: this might result in unexpected behavior around New Year's Eve
        let year = datetime.year ?? calendar.component(.year, from: Date())
        let components = DateComponents(year: year, month: month, day: day)
        if let newDate = calendar.date(from: components) {
            date = newDate
        }
    }

    static func fillTime(_ timeEntity: Entity, _ time: inout Date) {
        guard case let .datetime(datetime) = timeEntity,
              let hour = datetime.hour,
              let minute = datetime.minute else { return }
        
        let calendar = Calendar.current
        let components = DateComponents(hour: hour, minute: minute)
        if let newTime = calendar.date(from: components) {
            time = newTime
        }
    }

    static func fillText(_ textEntity: Entity, _ text: inout String) {
        guard case let .text(simpleText) = textEntity else { return }
        text = simpleText.text.isEmpty || simpleText.text == "löschen" ? "" : simpleText.text
    }

    static func fillNumber(_ numberEntity: Entity, _ number: inout Int) {
        guard case let .number(simpleNumber) = numberEntity else { return }
        number = Int(simpleNumber.number)
    }

    static func capitalizeWords(_ text: String) -> String {
        return text
            .split(separator: " ")
            .map { $0.prefix(1).capitalized + $0.dropFirst() }
            .joined(separator: " ")
    }

    static func formatPhone(_ phone: String) -> String {
        return phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "plus", with: "+")
            // add whitespace after 5 digit vorwahl
            .replacingOccurrences(of: "(^0\\d{4})", with: "$1 ", options: .regularExpression)
    }
}
