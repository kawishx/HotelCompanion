//
//  QRScannerViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/QRScannerViewModel.swift
//

import AVFoundation
import Foundation

@MainActor
final class QRScannerViewModel: ObservableObject {
    enum ScanState: Equatable {
        case idle
        case success(String)
        case invalid(String)
        case permissionRequired(String)
    }

    @Published private(set) var scanState: ScanState = .idle
    @Published private(set) var matchedBooking: BookingSummary?
    @Published var isScannerActive = false

    private let bookings: [BookingSummary]
    private let qrCodeManager: QRCodeManager

    init(bookings: [BookingSummary], qrCodeManager: QRCodeManager = .shared) {
        self.bookings = bookings
        self.qrCodeManager = qrCodeManager
    }

    func prepareScanner() async {
        switch qrCodeManager.cameraPermissionStatus() {
        case .authorized:
            isScannerActive = true
            scanState = .idle
        case .notDetermined:
            let granted = await qrCodeManager.requestCameraPermission()
            if granted {
                isScannerActive = true
                scanState = .idle
            } else {
                isScannerActive = false
                scanState = .permissionRequired("Allow camera access in Settings to scan booking QR codes.")
            }
        case .denied, .restricted:
            isScannerActive = false
            scanState = .permissionRequired("Allow camera access in Settings to scan booking QR codes.")
        @unknown default:
            isScannerActive = false
            scanState = .invalid("Camera access is unavailable right now.")
        }
    }

    func processScannedCode(_ code: String) {
        if let booking = bookings.first(where: { $0.qrPayload == code }),
           qrCodeManager.isRecognizedQRCode(code, validPayloads: bookings.map(\.qrPayload)) {
            matchedBooking = booking
            scanState = .success("Booking confirmed for \(booking.title).")
        } else {
            matchedBooking = nil
            scanState = .invalid("This QR code is not recognized for the current mock booking list.")
        }

        isScannerActive = false
    }

    func resetScanner() {
        matchedBooking = nil
        scanState = .idle
        isScannerActive = false
    }
}
