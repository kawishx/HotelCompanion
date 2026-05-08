//
//  FirestoreMappable.swift
//  HotelCompanion
//
//  File: Core/Firebase/Shared/FirestoreMappable.swift
//

import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

protocol FirestoreMappable: Codable {
    init?(dictionary: [String: Any])
    var asDictionary: [String: Any] { get }
}

extension FirestoreMappable {
    init?(dictionary: [String: Any]) {
        guard
            let data = try? JSONSerialization.data(withJSONObject: Self.normalizedDictionary(dictionary)),
            let model = try? Self.configuredDecoder().decode(Self.self, from: data)
        else {
            return nil
        }

        self = model
    }

    var asDictionary: [String: Any] {
        guard
            let data = try? Self.configuredEncoder().encode(self),
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let dictionary = jsonObject as? [String: Any]
        else {
            return [:]
        }

        return dictionary
    }
}

private extension FirestoreMappable {
    static func configuredDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    static func configuredEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }

    static func normalizedDictionary(_ dictionary: [String: Any]) -> [String: Any] {
        dictionary.mapValues(normalizedValue)
    }

    static func normalizedValue(_ value: Any) -> Any {
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
            return normalizedDictionary(nestedDictionary)
        }

        if let nestedArray = value as? [Any] {
            return nestedArray.map(normalizedValue)
        }

        if let url = value as? URL {
            return url.absoluteString
        }

        return value
    }
}
