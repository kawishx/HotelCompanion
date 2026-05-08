//
//  QRPassViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/QRPassViewModel.swift
//

import Combine
import SwiftUI

@MainActor
final class QRPassViewModel: ObservableObject {
    @Published private(set) var booking: BookingSummary
    @Published private(set) var qrImage: UIImage?

    private let qrCodeManager: QRCodeManager

    init(booking: BookingSummary, qrCodeManager: QRCodeManager? = nil) {
        let resolvedQRCodeManager = qrCodeManager ?? .shared

        self.booking = booking
        self.qrCodeManager = resolvedQRCodeManager
        self.qrImage = resolvedQRCodeManager.generateQRCodeImage(from: booking.qrPayload)
    }
}
