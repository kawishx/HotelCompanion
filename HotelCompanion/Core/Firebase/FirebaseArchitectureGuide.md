# Firebase Architecture Guide

File: `Core/Firebase/FirebaseArchitectureGuide.md`

## Recommended Dependency Structure

Keep the Firebase layer split into four simple levels:

1. `AppConfiguration`
   Initializes Firebase once at app launch.

2. `Shared`
   Cross-cutting helpers used by both Firestore and Storage.
   Examples:
   - `FirebaseSessionCoordinator`
   - `HotelContextResolver`
   - `DateProviding`
   - `FirebasePaths`

3. `Firestore` and `Storage`
   Remote infrastructure adapters.
   Examples:
   - `FirestoreRemoteStore`
   - `StorageService`

4. Feature services
   App-specific business logic.
   Examples:
   - `BookingService`
   - `ServiceRequestService`
   - `DiningOrderService`
   - `NotificationFeedService`

View models should depend on feature service protocols, not directly on Firebase SDK types.

## What Was Consolidated

- current user resolution moved into `FirebaseSessionCoordinator`
- current hotel / stay resolution moved into `HotelContextResolver`
- repeated raw Firestore document/query access moved into `FirestoreRemoteStore`
- repeated timestamp conversion helpers centralized in `FirestoreDateCoding`
- reusable document path construction expanded in `FirebasePaths`

## Repository Guidance

Use a repository when a module has non-trivial remote persistence rules or multiple query/write shapes.

Good current example:
- `BookingRepository`

Good next candidates if those modules grow further:
- `ServiceRequestRepository`
- `DiningOrderRepository`
- `ConciergeRequestRepository`
- `NotificationFeedRepository`

Keep simple read-only modules as services until complexity justifies a repository.

## Testability Guidance

For unit tests, inject:

- protocol-based feature services into view models
- `FirebaseSessionCoordinating` into Firebase-backed services
- `FirestoreRemoteStoring` into Firestore-backed services
- `DateProviding` where timestamps affect business logic

This keeps tests independent of the real Firebase SDK and real wall-clock time.

## Practical Rule

Avoid letting feature services call `Firestore.firestore()` directly.
Use the shared remote store unless a module has enough complexity to justify its own repository abstraction.
