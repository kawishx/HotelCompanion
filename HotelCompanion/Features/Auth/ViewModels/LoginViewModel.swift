//
//  LoginViewModel.swift
//  HotelCompanion
//
//  File: Features/Auth/ViewModels/LoginViewModel.swift
//

import Combine
import Foundation

final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    var canSignIn: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
}

