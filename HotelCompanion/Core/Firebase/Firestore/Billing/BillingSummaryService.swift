//
//  BillingSummaryService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Billing/BillingSummaryService.swift
//

import Foundation

protocol BillingSummaryServicing {
    func fetchCurrentUserBillingSummaries() async throws -> [BillingSummaryRecord]
}

final class BillingSummaryService: BillingSummaryServicing {
    static let shared = BillingSummaryService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating
    private var fallbackSummariesByUserID: [String: [BillingSummaryRecord]] = [:]

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
    }

    func fetchCurrentUserBillingSummaries() async throws -> [BillingSummaryRecord] {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return fallbackSummaries(for: session)
        }

        do {
            let records: [BillingSummaryRecord] = try await remoteStore.fetchCollectionGroup(
                subcollection: .billingSummaries,
                filters: [.equalTo(field: FirestoreDocumentField.guestUserID, value: session.id)],
                orderBy: FirestoreDocumentField.issuedAt,
                descending: true,
                limit: nil
            )

            return records.isEmpty ? fallbackSummaries(for: session) : records
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return fallbackSummaries(for: session)
        }
    }
}

private extension BillingSummaryService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !remoteStore.isAvailable()
    }

    func fallbackSummaries(for session: UserSession) -> [BillingSummaryRecord] {
        if let existing = fallbackSummariesByUserID[session.id] {
            return existing.sorted { $0.issuedAt > $1.issuedAt }
        }

        let seeded = sampleSummaries(for: session)
        fallbackSummariesByUserID[session.id] = seeded
        return seeded.sorted { $0.issuedAt > $1.issuedAt }
    }

    func sampleSummaries(for session: UserSession) -> [BillingSummaryRecord] {
        let now = Date()
        let roomCharge = MoneyAmount(currencyCode: "LKR", amountMinorUnits: 145000)
        let foodCharge = MoneyAmount(currencyCode: "LKR", amountMinorUnits: 12450)
        let experienceCharge = MoneyAmount(currencyCode: "LKR", amountMinorUnits: 18500)
        let extraServiceCharge = MoneyAmount(currencyCode: "LKR", amountMinorUnits: 6000)
        let subtotal = MoneyAmount(currencyCode: "LKR", amountMinorUnits: 181950)
        let tax = MoneyAmount(currencyCode: "LKR", amountMinorUnits: 18195)
        let total = MoneyAmount(currencyCode: "LKR", amountMinorUnits: 200145)

        return [
            BillingSummaryRecord(
                id: "billing-sample-001",
                hotelID: "cinnamon-thiya",
                guestUserID: session.id,
                guest: GuestSnapshot(
                    userID: session.id,
                    fullName: session.displayName ?? "Kawish Jayawardena",
                    email: session.email,
                    phoneNumber: nil
                ),
                stayID: "stay-sample-cinnamon-thiya-001",
                folioNumber: "FOLIO-508-2026",
                status: .open,
                lineItems: [
                    BillingLineItem(id: "room-charge", title: "Oceanfront Suite", category: "room", quantity: 3, amount: roomCharge, postedAt: Calendar.current.date(byAdding: .day, value: -2, to: now)),
                    BillingLineItem(id: "food-charge", title: "In-Room Dining", category: "food", quantity: 2, amount: foodCharge, postedAt: Calendar.current.date(byAdding: .hour, value: -6, to: now)),
                    BillingLineItem(id: "experience-charge", title: "Sunset River Cruise", category: "experience", quantity: 2, amount: experienceCharge, postedAt: Calendar.current.date(byAdding: .day, value: -1, to: now)),
                    BillingLineItem(id: "extra-service-charge", title: "Private Airport Transfer", category: "service", quantity: 1, amount: extraServiceCharge, postedAt: Calendar.current.date(byAdding: .hour, value: -14, to: now))
                ],
                subtotalAmount: subtotal,
                taxAmount: tax,
                discountAmount: nil,
                totalAmount: total,
                balanceDueAmount: total,
                issuedAt: now,
                dueAt: Calendar.current.date(byAdding: .day, value: 1, to: now),
                createdAt: now,
                updatedAt: now
            )
        ]
    }
}
