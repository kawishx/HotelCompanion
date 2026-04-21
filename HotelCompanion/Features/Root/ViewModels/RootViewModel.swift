//
//  RootViewModel.swift
//  HotelCompanion
//
//  File: Features/Root/ViewModels/RootViewModel.swift
//

import Combine

final class RootViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
}
