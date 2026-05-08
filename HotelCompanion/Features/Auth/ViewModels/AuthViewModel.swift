//
//  AuthViewModel.swift
//  HotelCompanion
//
//  File: Features/Auth/ViewModels/AuthViewModel.swift
//

import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var userSession: UserSession?
    @Published private(set) var isLoading = false
    @Published private(set) var lastSuccessMessage: String?
    @Published var errorMessage: String?

    private let authService: AuthServicing
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServicing? = nil) {
        let resolvedAuthService = authService ?? AuthService.shared

        self.authService = resolvedAuthService
        self.userSession = resolvedAuthService.currentSession
        bindSessionUpdates()
    }

    var isAuthenticated: Bool {
        userSession != nil
    }

    var isGuestSession: Bool {
        userSession?.isGuest == true
    }

    var sessionTitle: String {
        if let userSession {
            return userSession.isGuest ? "Guest Session" : "Signed In Account"
        }

        return "No Active Session"
    }

    var sessionSubtitle: String {
        guard let userSession else {
            return "Sign in with Firebase Authentication or continue as a guest."
        }

        if userSession.isGuest {
            return "You are browsing with limited guest access on this device."
        }

        return userSession.email ?? userSession.greetingName
    }

    func signIn(email: String, password: String) async -> Bool {
        await performAuthentication(successMessage: "Welcome back to Cinnamon Companion.") {
            try await authService.signIn(email: email, password: password)
        }
    }

    func signUp(email: String, password: String) async -> Bool {
        await performAuthentication(successMessage: "Your account has been created successfully.") {
            try await authService.signUp(email: email, password: password)
        }
    }

    func continueAsGuest() async -> Bool {
        errorMessage = nil
        lastSuccessMessage = nil
        isLoading = true
        defer { isLoading = false }

        _ = await authService.signInAsGuest()
        lastSuccessMessage = "You are now continuing as a guest."
        return true
    }

    @discardableResult
    func signOut() -> Bool {
        errorMessage = nil
        lastSuccessMessage = nil

        do {
            try authService.signOut()
            lastSuccessMessage = "You have been signed out."
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func clearTransientMessages() {
        errorMessage = nil
        lastSuccessMessage = nil
    }
}

private extension AuthViewModel {
    func bindSessionUpdates() {
        authService.sessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                self?.userSession = session
            }
            .store(in: &cancellables)
    }

    func performAuthentication(
        successMessage: String,
        operation: () async throws -> UserSession
    ) async -> Bool {
        errorMessage = nil
        lastSuccessMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await operation()
            lastSuccessMessage = successMessage
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
