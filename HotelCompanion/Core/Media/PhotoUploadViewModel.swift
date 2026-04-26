//
//  PhotoUploadViewModel.swift
//  HotelCompanion
//
//  File: Core/Media/PhotoUploadViewModel.swift
//

import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

enum PhotoUploadContext {
    case idDocument
    case maintenanceIssue

    var title: String {
        switch self {
        case .idDocument:
            return "ID or Passport Upload"
        case .maintenanceIssue:
            return "Maintenance Photo Upload"
        }
    }

    var subtitle: String {
        switch self {
        case .idDocument:
            return "Capture or choose a clear image of your identification for digital check-in."
        case .maintenanceIssue:
            return "Attach a clear photo of the issue so our hotel team can respond faster."
        }
    }

    var placeholderTitle: String {
        switch self {
        case .idDocument:
            return "No ID image selected"
        case .maintenanceIssue:
            return "No issue photo selected"
        }
    }

    var placeholderSystemImage: String {
        switch self {
        case .idDocument:
            return "person.text.rectangle"
        case .maintenanceIssue:
            return "wrench.and.screwdriver"
        }
    }

    var confirmButtonTitle: String {
        switch self {
        case .idDocument:
            return "Confirm ID Upload"
        case .maintenanceIssue:
            return "Confirm Issue Upload"
        }
    }

    var successMessage: String {
        switch self {
        case .idDocument:
            return "Your ID or passport image is ready for digital check-in."
        case .maintenanceIssue:
            return "Your maintenance issue photo is ready to send to guest services."
        }
    }
}

struct PhotoUploadAlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class PhotoUploadViewModel: ObservableObject {
    @Published private(set) var selectedImage: UIImage?
    @Published var isPresentingCamera = false
    @Published var alertItem: PhotoUploadAlertItem?
    @Published private(set) var statusMessage: String?
    @Published private(set) var hasConfirmedUpload = false

    let context: PhotoUploadContext

    init(context: PhotoUploadContext) {
        self.context = context
    }

    var canConfirmUpload: Bool {
        selectedImage != nil && !hasConfirmedUpload
    }

    func loadSelectedPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                alertItem = PhotoUploadAlertItem(
                    title: "Image Error",
                    message: "The selected image could not be loaded. Please try another photo."
                )
                return
            }

            applySelectedImage(image)
        } catch {
            alertItem = PhotoUploadAlertItem(
                title: "Image Error",
                message: "The selected image could not be loaded. Please try again."
            )
        }
    }

    func prepareCameraCapture() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            alertItem = PhotoUploadAlertItem(
                title: "Camera Unavailable",
                message: "This device does not currently have an available camera."
            )
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isPresentingCamera = true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                isPresentingCamera = true
            } else {
                alertItem = PhotoUploadAlertItem(
                    title: "Camera Access Denied",
                    message: "Allow camera access in Settings to take a photo in Cinnamon Companion."
                )
            }
        case .denied, .restricted:
            alertItem = PhotoUploadAlertItem(
                title: "Camera Access Denied",
                message: "Allow camera access in Settings to take a photo in Cinnamon Companion."
            )
        @unknown default:
            alertItem = PhotoUploadAlertItem(
                title: "Camera Error",
                message: "Camera access is unavailable right now."
            )
        }
    }

    func applyCapturedImage(_ image: UIImage) {
        applySelectedImage(image)
    }

    func removeImage() {
        selectedImage = nil
        hasConfirmedUpload = false
        statusMessage = nil
    }

    func confirmUpload() {
        guard selectedImage != nil else {
            alertItem = PhotoUploadAlertItem(
                title: "No Image Selected",
                message: "Choose or capture a photo before confirming the upload."
            )
            return
        }

        hasConfirmedUpload = true
        statusMessage = context.successMessage
        alertItem = PhotoUploadAlertItem(
            title: "Upload Confirmed",
            message: context.successMessage
        )
    }

    private func applySelectedImage(_ image: UIImage) {
        selectedImage = image
        hasConfirmedUpload = false
        statusMessage = "Image preview ready. Review it before confirming upload."
    }
}

