//
//  SavedLocation.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/15/23.
//

import Foundation
import FirebaseFirestore

struct SavedLocation: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var emoji: String
    var nickname: String
    var latitude: Double
    var longitude: Double
    var dateSaved = Date()
    // TODO: NEXT! :)
    // TODO: add customizing/deleting the saved locs!
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "emoji" : emoji,
            "nickname" : nickname,
            "latitude" : latitude,
            "longitude" : longitude,
            "dateSaved" : Timestamp(date: dateSaved)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> SavedLocation {
        return SavedLocation(UUID: dictionary["UUID"] as! String,
                             emoji: dictionary["emoji"] as! String,
                             nickname: dictionary["nickname"] as! String,
                             latitude: dictionary["latitude"] as! Double,
                             longitude: dictionary["longitude"] as! Double,
                             dateSaved: Date.decodeDate(dictionary["dateSaved"]!))
    }
}

enum LocationMode: Equatable {
    case current
    case saved(locationID: String)
    
    func toString() -> String {
        switch self {
        case .current:
            return "current"
        case .saved(let locationID):
            return locationID
        }
    }
    
    static func fromString(_ string: String) -> LocationMode {
        if string == "current" {
            return .current
        } else {
            return .saved(locationID: string)
        }
    }
}
