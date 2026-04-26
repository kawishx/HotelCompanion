//
//  QRPassViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/QRPassViewModel.swift
//

import SwiftUI

@MainActor
final class QRPassViewModel: ObservableObject {
    @Published private(set) var booking: BookingSummary
    @Published private(set) var qrImage: UIImage?

    private let qrCodeManager: QRCodeManager

    init(booking: BookingSummary, qrCodeManager: QRCodeManager = .shared) {
        self.booking = booking
        self.qrCodeManager = qrCodeManager
        self.qrImage = qrCodeManager.generateQRCodeImage(from: booking.qrPayload)
    }
}

