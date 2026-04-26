//
//  QRCodeManager.swift
//  HotelCompanion
//
//  File: Core/QR/QRCodeManager.swift
//

import AVFoundation
import CoreImage.CIFilterBuiltins
import UIKit

final class QRCodeManager {
    static let shared = QRCodeManager()

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    func generateQRCodeImage(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func cameraPermissionStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestCameraPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func isRecognizedQRCode(_ scannedCode: String, validPayloads: [String]) -> Bool {
        validPayloads.contains(scannedCode)
    }
}
