# Firestore Schema Guide

File: `Core/Firebase/Firestore/FirestoreSchemaGuide.md`

This schema is designed so the app can start with **Cinnamon Thiya Hotel** while staying scalable for **multiple hotels** later.

## Core Strategy

- Keep **hotels** as a top-level collection: `hotels/{hotelId}`
- Keep **users** as a top-level collection: `users/{userId}`
- Store hotel operations under each hotel document so staff dashboards and hotel-specific reporting scale cleanly
- Store personal guest data under each user document so the mobile app can load guest-centric history and preferences efficiently
- Put `hotelID`, `guestUserID`, `stayID`, and `bookingID` in operational documents even when the path already implies them

## Recommended Collections

### 1. Hotels

Path:

`hotels/{hotelId}`

Purpose:

- property metadata
- branding context
- hotel-level configuration

Suggested fields:

- `name: String`
- `shortCode: String`
- `brandID: String?`
- `city: String`
- `countryCode: String`
- `timeZoneIdentifier: String`
- `currencyCode: String`
- `address: Map`
- `coordinate: Map`
- `isActive: Bool`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 2. Users

Path:

`users/{userId}`

Purpose:

- authenticated guest profile
- app preferences
- cross-hotel identity

Suggested fields:

- `fullName: String`
- `email: String`
- `phoneNumber: String?`
- `primaryHotelID: String?`
- `loyaltyTier: String?`
- `preferredLocaleIdentifier: String`
- `preferredCurrencyCode: String`
- `profileImagePath: String?`
- `notificationPreferences: Map`
- `accessibilityPreferences: Map`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 3. User Hotel Memberships

Path:

`users/{userId}/hotelMemberships/{hotelId}`

Purpose:

- tracks which hotel relationships the guest has access to
- supports future multi-hotel guest experiences
- useful when Cinnamon Thiya is the first active property, but not the only one later

Suggested fields:

- `hotelID: String`
- `permissionStatus: String`
- `isPrimaryHotel: Bool`
- `invitedAt: Timestamp?`
- `grantedAt: Timestamp?`
- `lastSeenAt: Timestamp?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 4. Stays

Path:

`hotels/{hotelId}/stays/{stayId}`

Purpose:

- one actual stay instance for a guest at a hotel
- supports check-in, room assignment, active stay summary, billing linkage

Suggested fields:

- `hotelID: String`
- `guestUserID: String`
- `guest: Map`
- `bookingID: String?`
- `confirmationCode: String`
- `room: Map`
- `adultCount: Int`
- `childCount: Int`
- `checkInDate: Timestamp`
- `checkOutDate: Timestamp`
- `status: String`
- `specialNotes: String?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 5. Bookings

Path:

`hotels/{hotelId}/bookings/{bookingId}`

Purpose:

- reservation or reserved experience
- separate from `stays` so non-room bookings also fit the model

Suggested fields:

- `hotelID: String`
- `guestUserID: String`
- `guest: Map`
- `stayID: String?`
- `experienceID: String?`
- `category: String`
- `status: String`
- `title: String`
- `summary: String?`
- `confirmationCode: String`
- `qrPayloadSource: String`
- `startDate: Timestamp`
- `endDate: Timestamp?`
- `guestCount: Int`
- `totalAmount: Map?`
- `sourceChannel: String?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 6. Service Requests

Path:

`hotels/{hotelId}/serviceRequests/{requestId}`

Purpose:

- housekeeping
- maintenance
- guest amenities

Suggested fields:

- `hotelID: String`
- `guestUserID: String`
- `guest: Map`
- `stayID: String?`
- `roomNumber: String?`
- `requestType: String`
- `note: String`
- `uploadedImageURL: String?`
  This should store the Firebase Storage download URL returned after the maintenance photo upload completes.
- `priority: String`
- `status: String`
- `assignedTeamName: String?`
- `resolvedAt: Timestamp?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 7. Dining Orders

Path:

`hotels/{hotelId}/diningOrders/{orderId}`

Purpose:

- in-room dining
- restaurant order workflow

Suggested fields:

- `hotelID: String`
- `guestUserID: String`
- `guest: Map`
- `stayID: String?`
- `venueName: String`
- `deliveryType: String`
- `deliveryLocationLabel: String`
- `roomNumber: String?`
- `items: [Map]`
- `specialInstructions: String?`
- `status: String`
- `subtotalAmount: Map`
- `taxAmount: Map`
- `totalAmount: Map`
- `requestedFor: Timestamp?`
- `fulfilledAt: Timestamp?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 8. Concierge Requests

Path:

`hotels/{hotelId}/conciergeRequests/{requestId}`

Purpose:

- airport transfers
- dinner reservations
- excursion help

Suggested fields:

- `hotelID: String`
- `guestUserID: String`
- `guest: Map`
- `stayID: String?`
- `requestType: String`
- `status: String`
- `title: String`
- `detail: String`
- `requestedFor: Timestamp?`
- `partySize: Int?`
- `contactMethod: String?`
- `responseNotes: String?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 9. Billing Summaries

Path:

`hotels/{hotelId}/billingSummaries/{billingId}`

Purpose:

- folio summary for a stay
- links stay charges, dining, services, taxes

Suggested fields:

- `hotelID: String`
- `guestUserID: String`
- `guest: Map`
- `stayID: String`
- `folioNumber: String`
- `status: String`
- `lineItems: [Map]`
- `subtotalAmount: Map`
- `taxAmount: Map`
- `discountAmount: Map?`
- `totalAmount: Map`
- `balanceDueAmount: Map`
- `issuedAt: Timestamp`
- `dueAt: Timestamp?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 10. Notifications

Path:

`users/{userId}/notifications/{notificationId}`

Purpose:

- app inbox
- guest-specific operational updates

Suggested fields:

- `userID: String`
- `hotelID: String?`
- `type: String`
- `title: String`
- `body: String`
- `relatedDocumentPath: String?`
- `deepLinkRoute: String?`
- `isRead: Bool`
- `sentAt: Timestamp`
- `readAt: Timestamp?`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

### 11. Guest Activity Timeline

Path:

`users/{userId}/activityTimeline/{eventId}`

Purpose:

- unified guest history across modules and hotels

Suggested fields:

- `userID: String`
- `hotelID: String?`
- `eventType: String`
- `title: String`
- `detail: String`
- `sourceModule: String`
- `relatedDocumentPath: String?`
- `occurredAt: Timestamp`
- `createdAt: Timestamp`

### 12. Saved Attractions

Path:

`users/{userId}/savedAttractions/{savedAttractionId}`

Purpose:

- favorites synced across devices
- can reference hotel-curated attractions or snapshots from local/mock explore content

Suggested fields:

- `userID: String`
- `hotelID: String?`
- `attraction: Map`
- `notes: String?`
- `savedAt: Timestamp`
- `createdAt: Timestamp`
- `updatedAt: Timestamp`

## Relationships

- A Firebase Auth user maps to one `users/{userId}` profile document
- A guest can belong to multiple hotels through `users/{userId}/hotelMemberships/{hotelId}`
- A hotel owns its operational documents under `hotels/{hotelId}/...`
- Hotel-scoped documents should include the guest snapshot and `guestUserID` inside that snapshot for easier filtering
- `stays` represent the actual hotel stay lifecycle
- `bookings` represent reservations and may optionally link to a `stayID`
- `serviceRequests`, `diningOrders`, `conciergeRequests`, and `billingSummaries` can all point back to `stayID`
- `notifications` and `activityTimeline` point back to hotel operations through `relatedDocumentPath`

## Scalable Multi-Hotel Notes

- Never hardcode Cinnamon Thiya-specific values into document paths
- Use generated `hotelId` values like `cinnamon-thiya` only as data, not as code assumptions
- Query by `hotelID` and `guest.userID` for hotel-specific and guest-specific filtering
- Use collection group queries later for cross-hotel views such as all bookings for one guest
- Keep hotel configuration in `hotels/{hotelId}` so theming, coordinates, and operational rules can vary by property

## What Should Stay in Firestore vs Local/UI-Only For Now

Keep in Firestore:

- guest profile and preferences that should sync across devices
- real bookings and stays
- service, dining, concierge, billing, favorites
- notifications inbox
- guest activity history

Keep local or UI-only for now:

- onboarding page content
- temporary form drafts before submit
- current tab selection
- map camera position and filter chip state
- mock explore recommendations
- biometric toggle remains acceptable in local storage for now
- transient loading, error, and success banners

## Server Timestamp Guidance

For production writes:

- set `createdAt` only when documents are first created
- update `updatedAt` on every write
- prefer Firestore server timestamps instead of device time for audit fields
