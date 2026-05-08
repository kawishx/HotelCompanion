//
//  ExploreNearbyView.swift
//  HotelCompanion
//
//  File: Features/Explore/Views/ExploreNearbyView.swift
//

import CoreLocation
import MapKit
import SwiftUI
import UIKit

@MainActor
struct ExploreNearbyView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var viewModel: ExploreNearbyViewModel
    @StateObject private var locationManager: LocationManager
    @State private var mapPosition: MapCameraPosition
    @Environment(\.openURL) private var openURL

    init(
        viewModel: ExploreNearbyViewModel? = nil,
        locationManager: LocationManager? = nil
    ) {
        let resolvedViewModel = viewModel ?? ExploreNearbyViewModel()
        let resolvedLocationManager = locationManager ?? LocationManager()

        _viewModel = StateObject(wrappedValue: resolvedViewModel)
        _locationManager = StateObject(wrappedValue: resolvedLocationManager)
        _mapPosition = State(initialValue: .region(resolvedViewModel.hotelRegion))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
                headerSection
                permissionSection
                mapSection
                filtersSection
                attractionListSection
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.large)
        .task {
            locationManager.startUpdatingLocation()
            await viewModel.loadSavedAttractions()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .sheet(item: $viewModel.selectedAttraction) { attraction in
            AttractionDetailView(
                attraction: attraction,
                distanceText: viewModel.distanceText(for: attraction),
                isFavorite: viewModel.isFavorite(attraction),
                onNavigate: {
                    if let url = viewModel.navigationURL(for: attraction) {
                        openURL(url)
                    }
                },
                onToggleFavorite: {
                    Task {
                        await viewModel.toggleFavorite(for: attraction)
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

private extension ExploreNearbyView {
    var headerSection: some View {
        SectionCard(
            title: "Explore Nearby",
            subtitle: "Personalized discovery around \(viewModel.hotel.name)"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text("Browse curated attractions around your hotel, switch between map and list, and save favorites for the rest of your stay.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if let favoriteMessage = viewModel.favoriteMessage {
                    Label(favoriteMessage, systemImage: "heart.fill")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.brandBrown)
                        .fixedSize(horizontal: false, vertical: true)
                }

                NavigationLink {
                    SavedAttractionsView()
                } label: {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: AppSpacing.small) {
                            Text("View Saved Attractions")
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.brandBrown)

                            Text("(\(viewModel.savedAttractions.count))")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text("View Saved Attractions")
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.brandBrown)

                            Text("\(viewModel.savedAttractions.count) saved")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View saved attractions")
                .accessibilityValue("\(viewModel.savedAttractions.count) saved places")
            }
        }
    }

    @ViewBuilder
    var permissionSection: some View {
        if locationManager.authorizationStatus == .notDetermined {
            locationStatusCard(
                title: "Enable your location",
                message: "Allow location access to display your current position and help you orient yourself around nearby places.",
                actionTitle: "Allow Location",
                action: {
                    locationManager.requestPermission()
                }
            )
        } else if locationManager.isDeniedOrRestricted {
            locationStatusCard(
                title: "Location unavailable",
                message: locationManager.deniedMessage ?? "Location access is currently unavailable.",
                actionTitle: "Open Settings",
                action: {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        openURL(settingsURL)
                    }
                }
            )
        }
    }

    var mapSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $mapPosition, interactionModes: .all) {
                Annotation(viewModel.hotel.name, coordinate: viewModel.hotel.coordinate, anchor: .bottom) {
                    hotelMarker
                }

                ForEach(viewModel.filteredAttractions) { attraction in
                    Annotation(attraction.title, coordinate: attraction.coordinate, anchor: .bottom) {
                        Button {
                            focusOnAttraction(attraction)
                        } label: {
                            attractionMarker(for: attraction)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(attraction.title), \(attraction.category.rawValue)")
                        .accessibilityHint("Shows attraction details")
                    }
                }

                if locationManager.isAuthorized {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: AppColors.shadow, radius: 12, y: 6)
            .accessibilityLabel("Map of nearby attractions and hotel location")
            .accessibilityHint("Browse hotel and attraction pins. Use the list below for a more detailed accessible summary")

            if let currentLocation = locationManager.currentLocation {
                Button {
                    mapPosition = .region(viewModel.regionForUserLocation(currentLocation))
                } label: {
                    Label("My Location", systemImage: "location.fill")
                        .font(AppTypography.bodyEmphasized)
                        .foregroundStyle(AppColors.brandBrown)
                        .padding(.horizontal, AppSpacing.large)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                        .background(AppColors.surfaceCream)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(AppSpacing.large)
                .accessibilityLabel("Center map on my location")
                .accessibilityHint("Centers the map on your current location")
            }
        }
    }

    var filtersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Categories")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.medium) {
                    CategoryFilterChip(
                        title: "All",
                        systemImage: "square.grid.2x2.fill",
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        updateFilter(nil)
                    }

                    ForEach(AttractionCategory.allCases) { category in
                        CategoryFilterChip(
                            title: category.rawValue,
                            systemImage: category.symbolName,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            updateFilter(category)
                        }
                    }
                }
                .padding(.vertical, AppSpacing.xSmall)
            }
        }
    }

    var attractionListSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Nearby Highlights")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)

            ForEach(viewModel.filteredAttractions) { attraction in
                Button {
                    focusOnAttraction(attraction)
                } label: {
                    SectionCard(
                        title: attraction.title,
                        subtitle: attraction.category.rawValue
                    ) {
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            Text(viewModel.distanceText(for: attraction))
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.brandBrown)

                            Text(attraction.shortDescription)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: AppSpacing.medium) {
                                Label("Details", systemImage: "chevron.right.circle.fill")
                                    .font(AppTypography.bodyEmphasized)
                                    .foregroundStyle(AppColors.brandBrown)

                                if viewModel.isFavorite(attraction) {
                                    Label("Saved", systemImage: "heart.fill")
                                        .font(AppTypography.footnote)
                                        .foregroundStyle(AppColors.brandBrown)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(attraction.title), \(attraction.category.rawValue), \(viewModel.distanceText(for: attraction))")
                .accessibilityValue(viewModel.isFavorite(attraction) ? "Saved to favorites" : "Not saved")
                .accessibilityHint("Opens attraction details")
            }
        }
    }

    var hotelMarker: some View {
        VStack(spacing: AppSpacing.xSmall) {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.title2)
                .foregroundStyle(AppColors.accentGoldSoft)
                .padding(AppSpacing.small)
                .background(AppColors.brandBrownDeep)
                .clipShape(Circle())

            Text(viewModel.hotel.name)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.small)
                .padding(.vertical, AppSpacing.xSmall)
                .background(AppColors.surfaceCream)
                .clipShape(Capsule())
        }
    }

    func attractionMarker(for attraction: Attraction) -> some View {
        VStack(spacing: AppSpacing.xSmall) {
            Image(systemName: attraction.category.symbolName)
                .font(.headline)
                .foregroundStyle(Color.white)
                .padding(AppSpacing.small)
                .background(AppColors.brandBrown)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(viewModel.isFavorite(attraction) ? AppColors.accentGoldSoft : AppColors.surfaceCream, lineWidth: 2)
                )

            Text(attraction.title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.small)
                .padding(.vertical, AppSpacing.xSmall)
                .background(AppColors.surfaceCream)
                .clipShape(Capsule())
                .lineLimit(1)
        }
    }

    func locationStatusCard(
        title: String,
        message: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        SectionCard(title: title, subtitle: "Location Access") {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                PrimaryButton(title: actionTitle, systemImage: "location.fill") {
                    action()
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityValue(message)
        }
    }

    func focusOnAttraction(_ attraction: Attraction) {
        mapPosition = .region(viewModel.region(for: attraction))
        viewModel.selectAttraction(attraction)
    }

    func updateFilter(_ category: AttractionCategory?) {
        viewModel.selectCategory(category)
        mapPosition = .region(viewModel.hotelRegion)
    }
}

#Preview {
    NavigationStack {
        ExploreNearbyView()
    }
}
