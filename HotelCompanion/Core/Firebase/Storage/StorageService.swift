//
//  StorageService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Storage/StorageService.swift
//

import Foundation
import UIKit

#if canImport(FirebaseStorage)
import FirebaseStorage
#endif

enum StorageModuleType: String, Sendable {
    case idDocument = "id-document"
    case maintenanceIssue = "maintenance-issue"

    var rootFolder: String {
        switch self {
        case .idDocument:
            return FirebaseStoragePath.idDocuments
        case .maintenanceIssue:
            return FirebaseStoragePath.maintenanceUploads
        }
    }
}

struct StorageUploadResult: Sendable {
    let downloadURL: URL
    let storagePath: String
    let fileName: String
}

enum StorageServiceError: LocalizedError {
    case invalidImageData
    case uploadFailed(String)
    case missingDownloadURL

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "The selected image could not be prepared for upload."
        case .uploadFailed(let message):
            return message
        case .missingDownloadURL:
            return "The file uploaded successfully, but no download URL was returned."
        }
    }
}

protocol StorageServicing {
    func isConfigured() -> Bool
    func uploadImage(
        _ image: UIImage,
        hotelID: String,
        guestID: String,
        moduleType: StorageModuleType,
        progressHandler: (@Sendable (Double) -> Void)?
    ) async throws -> StorageUploadResult
    func storagePath(
        hotelID: String,
        guestID: String,
        moduleType: StorageModuleType,
        fileExtension: String,
        timestamp: Date
    ) -> String
}

final class StorageService: StorageServicing {
    static let shared = StorageService()

    private let dateProvider: DateProviding

    #if canImport(FirebaseStorage)
    let storage: Storage

    private init(
        storage: Storage = Storage.storage(),
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.storage = storage
        self.dateProvider = dateProvider
    }
    #else
    private init(dateProvider: DateProviding = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }
    #endif

    func isConfigured() -> Bool {
        #if canImport(FirebaseStorage)
        return true
        #else
        return false
        #endif
    }

    func uploadImage(
        _ image: UIImage,
        hotelID: String,
        guestID: String,
        moduleType: StorageModuleType,
        progressHandler: (@Sendable (Double) -> Void)? = nil
    ) async throws -> StorageUploadResult {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw StorageServiceError.invalidImageData
        }

        let timestamp = dateProvider.now
        let path = storagePath(
            hotelID: hotelID,
            guestID: guestID,
            moduleType: moduleType,
            fileExtension: "jpg",
            timestamp: timestamp
        )

        #if canImport(FirebaseStorage)
        let reference = storage.reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let uploadTask = reference.putData(data, metadata: metadata)
        let progressObserver = uploadTask.observe(.progress) { snapshot in
            let progress = snapshot.progress?.fractionCompleted ?? 0
            progressHandler?(progress)
        }

        do {
            try await awaitUpload(uploadTask)
            uploadTask.removeObserver(withHandle: progressObserver)
            progressHandler?(1.0)

            let downloadURL = try await awaitDownloadURL(from: reference)
            return StorageUploadResult(
                downloadURL: downloadURL,
                storagePath: path,
                fileName: URL(fileURLWithPath: path).lastPathComponent
            )
        } catch {
            uploadTask.removeObserver(withHandle: progressObserver)
            throw mapStorageError(error)
        }
        #else
        progressHandler?(1.0)
        let fallbackURL = URL(string: "https://storage.cinnamon-companion.example/\(path)")!
        return StorageUploadResult(
            downloadURL: fallbackURL,
            storagePath: path,
            fileName: URL(fileURLWithPath: path).lastPathComponent
        )
        #endif
    }

    func storagePath(
        hotelID: String,
        guestID: String,
        moduleType: StorageModuleType,
        fileExtension: String = "jpg",
        timestamp: Date = Date()
    ) -> String {
        let fileName = [
            sanitizedPathComponent(hotelID),
            sanitizedPathComponent(guestID),
            sanitizedPathComponent(moduleType.rawValue),
            timestampLabel(from: timestamp)
        ]
        .joined(separator: "_") + ".\(fileExtension)"

        return [
            moduleType.rootFolder,
            sanitizedPathComponent(hotelID),
            sanitizedPathComponent(guestID),
            fileName
        ]
        .joined(separator: "/")
    }
}

private extension StorageService {
    func sanitizedPathComponent(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9_-]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    func timestampLabel(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter.string(from: date)
    }

    #if canImport(FirebaseStorage)
    func awaitUpload(_ task: StorageUploadTask) async throws {
        try await withCheckedThrowingContinuation { continuation in
            task.observe(.success) { _ in
                continuation.resume(returning: ())
            }

            task.observe(.failure) { snapshot in
                let error = snapshot.error ?? StorageServiceError.uploadFailed("The upload could not be completed.")
                continuation.resume(throwing: error)
            }
        }
    }

    func awaitDownloadURL(from reference: StorageReference) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            reference.downloadURL { url, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let url else {
                    continuation.resume(throwing: StorageServiceError.missingDownloadURL)
                    return
                }

                continuation.resume(returning: url)
            }
        }
    }

    func mapStorageError(_ error: Error) -> StorageServiceError {
        let nsError = error as NSError

        guard nsError.domain == StorageErrorDomain else {
            return .uploadFailed(error.localizedDescription)
        }

        let storageCode = StorageErrorCode(rawValue: nsError.code)
        switch storageCode {
        case .unauthenticated:
            return .uploadFailed("You need to be signed in before uploading files.")
        case .unauthorized:
            return .uploadFailed("Upload permission was denied for this file.")
        case .quotaExceeded:
            return .uploadFailed("Storage quota was exceeded. Please try again later.")
        case .retryLimitExceeded, .nonMatchingChecksum:
            return .uploadFailed("The image upload was interrupted. Please retry.")
        case .downloadSizeExceeded:
            return .uploadFailed("The uploaded file was too large to process.")
        default:
            return .uploadFailed(error.localizedDescription)
        }
    }
    #endif
}
