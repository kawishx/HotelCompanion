//
//  HotelContextResolver.swift
//  HotelCompanion
//
//  File: Core/Firebase/Shared/HotelContextResolver.swift
//

import Foundation

struct HotelContext {
    let hotelID: String
    let stay: StayRecord?
}

protocol HotelContextResolving {
    func resolveCurrentHotelContext(defaultHotelID: String) async -> HotelContext
}

final class HotelContextResolver: HotelContextResolving {
    static let shared = HotelContextResolver()

    private let stayService: StayServicing

    init(stayService: StayServicing = StayService.shared) {
        self.stayService = stayService
    }

    func resolveCurrentHotelContext(defaultHotelID: String = "cinnamon-thiya") async -> HotelContext {
        let stay = try? await stayService.fetchCurrentStay()
        return HotelContext(
            hotelID: stay?.hotelID ?? defaultHotelID,
            stay: stay
        )
    }
}
