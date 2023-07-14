//
//  SavedLocation.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/15/23.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct SavedLocation: Transportable, Identifiable {
    var UUID = Foundation.UUID.getTripleID(); var id: String { UUID }
    var emoji: String
    var color = Color.cyan
    var nickname: String
    var latitude: Double
    var longitude: Double
    var dateSaved = Date()
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "emoji" : emoji,
            "color" : [
                Double(UIColor(color).cgColor.components![0]),
                Double(UIColor(color).cgColor.components![1]),
                Double(UIColor(color).cgColor.components![2]),
                Double(UIColor(color).cgColor.components![3])
            ],
            "nickname" : nickname,
            "latitude" : latitude,
            "longitude" : longitude,
            "dateSaved" : Timestamp(date: dateSaved)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> SavedLocation {
        return SavedLocation(UUID: dictionary["UUID"] as! String,
                             emoji: dictionary["emoji"] as! String,
                             color: {
                     let colorComponents = dictionary["color"] as! [Double]
                     return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
                 }(),
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
