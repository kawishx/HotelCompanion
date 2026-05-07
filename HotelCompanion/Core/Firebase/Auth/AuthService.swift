//
//  AuthService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Auth/AuthService.swift
//

import Combine
import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

protocol AuthServicing {
    var currentSession: UserSession? { get }
    var sessionPublisher: AnyPublisher<UserSession?, Never> { get }

    func signIn(email: String, password: String) async throws -> UserSession
    func signUp(email: String, password: String) async throws -> UserSession
    func signInAsGuest() async -> UserSession
    func signOut() throws
}

enum AuthServiceError: LocalizedError, Equatable {
    case firebaseUnavailable
    case invalidCredentials
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case userDisabled
    case tooManyRequests
    case networkError
    case unknown
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .firebaseUnavailable:
            return "Firebase Authentication is not configured yet. Add the FirebaseAuth package and GoogleService-Info.plist first."
        case .invalidCredentials:
            return "Your email or password is incorrect. Please try again."
        case .invalidEmail:
            return "Enter a valid email address to continue."
        case .emailAlreadyInUse:
            return "An account already exists for this email address."
        case .weakPassword:
            return "Choose a stronger password with at least 6 characters."
        case .userNotFound:
            return "No account was found for that email address."
        case .userDisabled:
            return "This account has been disabled. Please contact support."
        case .tooManyRequests:
            return "Too many attempts were made. Please wait a moment and try again."
        case .networkError:
            return "A network issue interrupted sign-in. Check your connection and try again."
        case .unknown:
            return "Authentication could not be completed right now. Please try again."
        case .custom(let message):
            return message
        }
    }
}

final class AuthService: AuthServicing {
    static let shared = AuthService()

    private enum Keys {
        static let isGuestSessionActive = "auth_guest_session_active"
    }

    private let userDefaults: UserDefaults
    private let sessionSubject: CurrentValueSubject<UserSession?, Never>

    #if canImport(FirebaseAuth)
    private let auth: Auth
    private var authStateDidChangeHandle: AuthStateDidChangeListenerHandle?

    private init(auth: Auth = Auth.auth(), userDefaults: UserDefaults = .standard) {
        self.auth = auth
        self.userDefaults = userDefaults
        self.sessionSubject = CurrentValueSubject(nil)
        startObservingAuthenticationState()
        publishResolvedSession()
    }
    #else
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.sessionSubject = CurrentValueSubject(nil)
        publishResolvedSession()
    }
    #endif

    deinit {
        #if canImport(FirebaseAuth)
        if let authStateDidChangeHandle {
            auth.removeStateDidChangeListener(authStateDidChangeHandle)
        }
        #endif
    }

    var currentSession: UserSession? {
        resolveCurrentSession()
    }

    var sessionPublisher: AnyPublisher<UserSession?, Never> {
        sessionSubject.eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) async throws -> UserSession {
        #if canImport(FirebaseAuth)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        return try await withCheckedThrowingContinuation { continuation in
            auth.signIn(withEmail: normalizedEmail, password: password) { [weak self] result, error in
                if let error = error {
                    continuation.resume(throwing: self?.mapAuthError(error) ?? AuthServiceError.unknown)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: AuthServiceError.unknown)
                    return
                }

                self?.userDefaults.set(false, forKey: Keys.isGuestSessionActive)

                let session = UserSession(firebaseUser: user)
                self?.sessionSubject.send(session)
                continuation.resume(returning: session)
            }
        }
        #else
        throw AuthServiceError.firebaseUnavailable
        #endif
    }

    func signUp(email: String, password: String) async throws -> UserSession {
        #if canImport(FirebaseAuth)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        return try await withCheckedThrowingContinuation { continuation in
            auth.createUser(withEmail: normalizedEmail, password: password) { [weak self] result, error in
                if let error = error {
                    continuation.resume(throwing: self?.mapAuthError(error) ?? AuthServiceError.unknown)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: AuthServiceError.unknown)
                    return
                }

                self?.userDefaults.set(false, forKey: Keys.isGuestSessionActive)

                let session = UserSession(firebaseUser: user)
                self?.sessionSubject.send(session)
                continuation.resume(returning: session)
            }
        }
        #else
        throw AuthServiceError.firebaseUnavailable
        #endif
    }

    func signInAsGuest() async -> UserSession {
        userDefaults.set(true, forKey: Keys.isGuestSessionActive)

        let session = UserSession.guest
        sessionSubject.send(session)
        return session
    }

    func signOut() throws {
        userDefaults.set(false, forKey: Keys.isGuestSessionActive)

        #if canImport(FirebaseAuth)
        if auth.currentUser != nil {
            do {
                try auth.signOut()
            } catch {
                throw mapAuthError(error)
            }
        }
        #endif

        sessionSubject.send(nil)
    }
}

private extension AuthService {
    func resolveCurrentSession() -> UserSession? {
        #if canImport(FirebaseAuth)
        if let user = auth.currentUser {
            return UserSession(firebaseUser: user)
        }
        #endif

        if userDefaults.bool(forKey: Keys.isGuestSessionActive) {
            return .guest
        }

        return nil
    }

    func publishResolvedSession() {
        sessionSubject.send(resolveCurrentSession())
    }

    #if canImport(FirebaseAuth)
    func startObservingAuthenticationState() {
        authStateDidChangeHandle = auth.addStateDidChangeListener { [weak self] _, _ in
            self?.publishResolvedSession()
        }
    }

    func mapAuthError(_ error: Error) -> AuthServiceError {
        let nsError = error as NSError

        guard
            nsError.domain == AuthErrorDomain,
            let errorCode = AuthErrorCode(rawValue: nsError.code)
        else {
            return .custom(nsError.localizedDescription)
        }

        switch errorCode {
        case .wrongPassword, .invalidCredential:
            return .invalidCredentials
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .userNotFound:
            return .userNotFound
        case .userDisabled:
            return .userDisabled
        case .tooManyRequests:
            return .tooManyRequests
        case .networkError:
            return .networkError
        default:
            return .custom(nsError.localizedDescription)
        }
    }
    #else
    func mapAuthError(_ error: Error) -> AuthServiceError {
        if let authError = error as? AuthServiceError {
            return authError
        }

        return .custom(error.localizedDescription)
    }
    #endif
}
