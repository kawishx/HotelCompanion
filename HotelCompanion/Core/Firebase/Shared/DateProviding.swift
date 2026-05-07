//
//  DateProviding.swift
//  HotelCompanion
//
//  File: Core/Firebase/Shared/DateProviding.swift
//

import Foundation

protocol DateProviding {
    var now: Date { get }
}

struct SystemDateProvider: DateProviding {
    var now: Date {
        Date()
    }
}
