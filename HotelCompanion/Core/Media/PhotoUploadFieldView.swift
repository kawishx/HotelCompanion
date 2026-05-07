//
//  PhotoUploadFieldView.swift
//  HotelCompanion
//
//  File: Core/Media/PhotoUploadFieldView.swift
//

import PhotosUI
import SwiftUI

struct PhotoUploadFieldView: View {
    @ObservedObject var viewModel: PhotoUploadViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        SectionCard(
            title: viewModel.context.title,
            subtitle: viewModel.context.subtitle
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                previewArea
                actionButtons

                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(AppTypography.footnote)
                        .foregroundStyle(viewModel.hasConfirmedUpload ? AppColors.brandBrown : AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Upload status: \(statusMessage)")
                }

                if viewModel.isUploading {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        ProgressView(value: viewModel.uploadProgress)
                            .tint(AppColors.brandBrown)
                            .accessibilityLabel("Upload progress")

                        Text("\(Int((viewModel.uploadProgress * 100).rounded()))% complete")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                if let uploadedDownloadURL = viewModel.uploadedDownloadURL {
                    Text("Stored file URL: \(uploadedDownloadURL.absoluteString)")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                        .accessibilityLabel("Uploaded file URL available")
                }

                PrimaryButton(
                    title: viewModel.confirmButtonTitle,
                    systemImage: "checkmark.circle.fill"
                ) {
                    viewModel.confirmUpload()
                }
                .disabled(!viewModel.canConfirmUpload)
                .opacity(viewModel.canConfirmUpload ? 1 : 0.6)
                .accessibilityLabel(viewModel.context.confirmButtonTitle)

                PrimaryButton(
                    title: viewModel.isUploading ? "Uploading..." : viewModel.context.uploadButtonTitle,
                    systemImage: "icloud.and.arrow.up.fill"
                ) {
                    Task {
                        _ = await viewModel.uploadConfirmedImage()
                    }
                }
                .disabled(!viewModel.canStartUpload)
                .opacity(viewModel.canStartUpload ? 1 : 0.6)
                .accessibilityLabel(viewModel.context.uploadButtonTitle)
            }
        }
        .sheet(isPresented: $viewModel.isPresentingCamera) {
            CameraImagePicker { image in
                viewModel.applyCapturedImage(image)
            }
            .ignoresSafeArea()
        }
        .alert(item: $viewModel.alertItem) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                await viewModel.loadSelectedPhoto(from: newValue)
            }
        }
    }
}

private extension PhotoUploadFieldView {
    var previewArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                .fill(AppColors.surfaceWarm.opacity(0.35))
                .frame(maxWidth: .infinity)
                .frame(height: 220)

            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous))
                    .accessibilityLabel("Selected upload image preview")
            } else {
                VStack(spacing: AppSpacing.medium) {
                    Image(systemName: viewModel.context.placeholderSystemImage)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(AppColors.brandBrown)
                        .accessibilityHidden(true)

                    Text(viewModel.context.placeholderTitle)
                        .font(AppTypography.bodyEmphasized)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Use the library or camera buttons below to continue.")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(AppSpacing.large)
                .accessibilityElement(children: .combine)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    var actionButtons: some View {
        VStack(spacing: AppSpacing.medium) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images
            ) {
                uploadActionLabel(
                    title: viewModel.selectedImage == nil ? "Choose from Library" : "Replace from Library",
                    systemImage: "photo.on.rectangle"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(viewModel.selectedImage == nil ? "Choose image from library" : "Replace image from library")

            Button {
                Task {
                    await viewModel.prepareCameraCapture()
                }
            } label: {
                uploadActionLabel(
                    title: viewModel.selectedImage == nil ? "Take Photo" : "Retake with Camera",
                    systemImage: "camera.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(viewModel.selectedImage == nil ? "Take photo with camera" : "Retake photo with camera")

            if viewModel.selectedImage != nil {
                Button {
                    viewModel.removeImage()
                    selectedPhotoItem = nil
                } label: {
                    uploadActionLabel(
                        title: "Remove Photo",
                        systemImage: "trash"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove selected photo")
            }
        }
    }

    func uploadActionLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: systemImage)
                .font(.headline)

            Text(title)
                .font(AppTypography.bodyEmphasized)
        }
        .foregroundStyle(AppColors.brandBrown)
        .frame(maxWidth: .infinity)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .background(AppColors.surfaceCream)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
    }
}

#Preview {
    PhotoUploadFieldView(viewModel: PhotoUploadViewModel(context: .idDocument))
        .padding()
        .background(AppColors.backgroundCream)
}
