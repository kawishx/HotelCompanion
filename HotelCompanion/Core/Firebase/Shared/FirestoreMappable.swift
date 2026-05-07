//
//  FirestoreMappable.swift
//  HotelCompanion
//
//  File: Core/Firebase/Shared/FirestoreMappable.swift
//

import Foundation

protocol FirestoreMappable: Codable {
    init?(dictionary: [String: Any])
    var asDictionary: [String: Any] { get }
}

extension FirestoreMappable {
    init?(dictionary: [String: Any]) {
        guard
            let data = try? JSONSerialization.data(withJSONObject: dictionary),
            let model = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }

        self = model
    }

    var asDictionary: [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self),
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let dictionary = jsonObject as? [String: Any]
        else {
            return [:]
        }

        return dictionary
    }
}

