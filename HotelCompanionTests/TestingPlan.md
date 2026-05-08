# Cinnamon Companion Testing Plan

File: `HotelCompanionTests/TestingPlan.md`

## Focus

- Prefer service, model, and helper tests over view snapshot tests.
- Keep business rules pure where possible.
- Test async service flows through protocol-based doubles.
- Use `@MainActor` tests only for view models that own UI-facing state.

## Recommended Test Structure

- `HotelCompanionTests/Support`
  - reusable test doubles, fixed dates, and sample builders
- `HotelCompanionTests/Services`
  - booking, service request, and other async service rules
- `HotelCompanionTests/ViewModels`
  - dining, billing-facing, and state-focused MVVM tests
- `HotelCompanionTests/Logic`
  - billing calculator, geofence resolver, notifications payload factory, recommendation engine
- `HotelCompanionTests/Firestore`
  - mapping, encoding, and decoding tests

## Xcode Target Setup

- Add a `Unit Testing Bundle` target named `HotelCompanionTests`.
- Set the host application to `HotelCompanion`.
- Add every file in `HotelCompanionTests` to the test target only.
- Enable `@testable import HotelCompanion` by keeping `Enable Testability = Yes` for Debug builds.
- Start by running the pure logic and service tests before broader integration tests.

## Initial Coverage

- Booking validation
- Booking cancel and reschedule rules
- Service request validation
- Dining cart subtotal, tax, and total math
- Billing line-item aggregation
- Geofence message and event-state resolution
- Notification payload generation
- Recommendation selection logic
- Firestore mapping for Codable models

## Testability Guidance

- Keep network and SDK code behind protocols.
- Move display-independent calculations into pure helpers.
- Inject `DateProviding` into services that stamp dates.
- Prefer immutable value models for domain and mapping tests.
- Keep view models thin and let helpers/services own the rules.
