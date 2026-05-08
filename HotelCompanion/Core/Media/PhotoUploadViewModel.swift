//
//  PhotoUploadViewModel.swift
//  HotelCompanion
//
//  File: Core/Media/PhotoUploadViewModel.swift
//

import Combine
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

    var uploadButtonTitle: String {
        switch self {
        case .idDocument:
            return "Upload ID Securely"
        case .maintenanceIssue:
            return "Upload Photo Securely"
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

    var uploadSuccessMessage: String {
        switch self {
        case .idDocument:
            return "Your ID or passport image was uploaded securely and is ready to link with check-in records."
        case .maintenanceIssue:
            return "Your maintenance issue photo was uploaded securely and is ready to attach to the service request."
        }
    }

    var moduleType: StorageModuleType {
        switch self {
        case .idDocument:
            return .idDocument
        case .maintenanceIssue:
            return .maintenanceIssue
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
    @Published private(set) var isUploading = false
    @Published private(set) var uploadProgress: Double = 0
    @Published private(set) var uploadedDownloadURL: URL?
    @Published private(set) var uploadedStoragePath: String?

    let context: PhotoUploadContext
    private let storageService: StorageServicing
    private let sessionCoordinator: FirebaseSessionCoordinating
    private let hotelContextResolver: HotelContextResolving

    init(
        context: PhotoUploadContext,
        storageService: StorageServicing = StorageService.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared,
        hotelContextResolver: HotelContextResolving = HotelContextResolver.shared
    ) {
        self.context = context
        self.storageService = storageService
        self.sessionCoordinator = sessionCoordinator
        self.hotelContextResolver = hotelContextResolver
    }

    var canConfirmUpload: Bool {
        selectedImage != nil && !hasConfirmedUpload
    }

    var canStartUpload: Bool {
        hasConfirmedUpload && selectedImage != nil && !isUploading && uploadedDownloadURL == nil
    }

    var hasUploadedFile: Bool {
        uploadedDownloadURL != nil
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
        uploadedDownloadURL = nil
        uploadedStoragePath = nil
        uploadProgress = 0
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

    @discardableResult
    func uploadConfirmedImageIfNeeded() async -> Bool {
        if uploadedDownloadURL != nil {
            return true
        }

        return await uploadConfirmedImage()
    }

    @discardableResult
    func uploadConfirmedImage() async -> Bool {
        guard let image = selectedImage else {
            alertItem = PhotoUploadAlertItem(
                title: "No Image Selected",
                message: "Choose or capture a photo before uploading."
            )
            return false
        }

        guard hasConfirmedUpload else {
            alertItem = PhotoUploadAlertItem(
                title: "Confirmation Required",
                message: "Confirm the selected image before uploading it to secure storage."
            )
            return false
        }

        let session = sessionCoordinator.resolvedSession()
        let hotelContext = await hotelContextResolver.resolveCurrentHotelContext()
        let hotelID = hotelContext.hotelID

        isUploading = true
        uploadProgress = 0
        statusMessage = "Uploading image to secure storage."
        defer { isUploading = false }

        do {
            let result = try await storageService.uploadImage(
                image,
                hotelID: hotelID,
                guestID: session.id,
                moduleType: context.moduleType,
                progressHandler: { [weak self] progress in
                    Task { @MainActor in
                        self?.uploadProgress = progress
                        self?.statusMessage = "Uploading image to secure storage. \(Int((progress * 100).rounded()))% complete."
                    }
                }
            )

            uploadedDownloadURL = result.downloadURL
            uploadedStoragePath = result.storagePath
            uploadProgress = 1
            statusMessage = context.uploadSuccessMessage
            alertItem = PhotoUploadAlertItem(
                title: "Upload Complete",
                message: context.uploadSuccessMessage
            )
            return true
        } catch {
            statusMessage = "Image upload failed. Please retry."
            alertItem = PhotoUploadAlertItem(
                title: "Upload Failed",
                message: error.localizedDescription
            )
            return false
        }
    }

    private func applySelectedImage(_ image: UIImage) {
        selectedImage = image
        hasConfirmedUpload = false
        uploadedDownloadURL = nil
        uploadedStoragePath = nil
        uploadProgress = 0
        statusMessage = "Image preview ready. Review it before confirming upload."
    }
}
