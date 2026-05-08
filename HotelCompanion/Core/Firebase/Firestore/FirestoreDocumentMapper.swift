//
//  FirestoreDocumentMapper.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/FirestoreDocumentMapper.swift
//

import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

enum FirestoreDocumentMapper {
    static func decode<T: Decodable>(
        _ type: T.Type,
        from rawData: [String: Any],
        documentID: String
    ) throws -> T {
        var normalizedData = normalizeDictionary(rawData)
        normalizedData["id"] = documentID

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        let jsonData = try JSONSerialization.data(withJSONObject: normalizedData)
        return try decoder.decode(T.self, from: jsonData)
    }

    static func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try configuredEncoder().encode(value)
        let jsonObject = try JSONSerialization.jsonObject(with: data)

        guard let dictionary = jsonObject as? [String: Any] else {
            throw FirestoreDocumentMapperError.invalidEncodedPayload
        }

        return dictionary
    }
}

enum FirestoreDocumentMapperError: LocalizedError {
    case invalidEncodedPayload

    var errorDescription: String? {
        switch self {
        case .invalidEncodedPayload:
            return "The Firestore document payload could not be encoded correctly."
        }
    }
}

private extension FirestoreDocumentMapper {
    static func configuredEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }

    static func normalizeDictionary(_ dictionary: [String: Any]) -> [String: Any] {
        dictionary.mapValues { normalizeValue($0) }
    }

    static func normalizeValue(_ value: Any) -> Any {
        #if canImport(FirebaseFirestore)
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue().timeIntervalSince1970
        }

        if let geoPoint = value as? GeoPoint {
            return [
                "latitude": geoPoint.latitude,
                "longitude": geoPoint.longitude
            ]
        }

        if let documentReference = value as? DocumentReference {
            return documentReference.path
        }
        #endif

        if let date = value as? Date {
            return date.timeIntervalSince1970
        }

        if let nestedDictionary = value as? [String: Any] {
            return normalizeDictionary(nestedDictionary)
        }

        if let nestedArray = value as? [Any] {
            return nestedArray.map { item in
                normalizeValue(item)
            }
        }

        if let url = value as? URL {
            return url.absoluteString
        }

        return value
    }
}
