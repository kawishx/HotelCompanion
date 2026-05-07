# Firebase Storage Integration Guide

File: `Core/Firebase/Storage/FirebaseStorageGuide.md`

## Supported Upload Modules

- `idDocument`
  Used for guest ID or passport uploads during digital check-in.
- `maintenanceIssue`
  Used for maintenance issue photos attached to service requests.

## File Naming Strategy

Each uploaded image path is generated from:

- `hotelID`
- `guestID`
- `moduleType`
- UTC timestamp

Example generated path:

```text
id-documents/cinnamon-thiya/user-123/cinnamon-thiya_user-123_id-document_20260507T101530Z.jpg
```

Another example:

```text
maintenance-uploads/cinnamon-thiya/user-123/cinnamon-thiya_user-123_maintenance-issue_20260507T101540Z.jpg
```

## Firestore Storage Pattern

### Service Requests

Store the Firebase Storage download URL directly in the existing Firestore field:

```text
hotels/{hotelId}/serviceRequests/{requestId}
uploadedImageURL: "https://firebasestorage.googleapis.com/..."
```

The app already writes this URL through `ServiceRequestService`.

### Future Digital Check-In Records

When a check-in document or arrival record is added later, store the upload URL in a dedicated Firestore field such as:

```text
hotels/{hotelId}/checkIns/{checkInId}
idDocumentImageURL: "https://firebasestorage.googleapis.com/..."
```

If you later want stronger file management, also store the Storage path:

```text
idDocumentStoragePath: "id-documents/cinnamon-thiya/user-123/..."
```

## Error Handling Strategy

- image encoding failure returns a user-friendly error before any network call
- Firebase Storage permission, quota, and retry errors are mapped to readable app messages
- upload screens keep the selected image intact so the user can retry without reselecting

## Upload Progress Strategy

- `StorageService` emits progress through a callback
- `PhotoUploadViewModel` converts that into `uploadProgress`
- `PhotoUploadFieldView` renders a `ProgressView` and percentage label

This keeps the upload API async/await-friendly while still supporting progress UI.
