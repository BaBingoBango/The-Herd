//
//  Vote.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation
import FirebaseFirestore

struct Vote: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var voterUUID: String
    var value: Int
    var timePosted: Date
    
    static let samples: [String : Vote] = [
        Foundation.UUID.getTripleID() : .init(voterUUID: Foundation.UUID.getTripleID(), value: 1, timePosted: Date()),
        Foundation.UUID.getTripleID() : .init(voterUUID: Foundation.UUID.getTripleID(), value: 1, timePosted: Date()),
        Foundation.UUID.getTripleID() : .init(voterUUID: Foundation.UUID.getTripleID(), value: -1, timePosted: Date()),
        Foundation.UUID.getTripleID() : .init(voterUUID: Foundation.UUID.getTripleID(), value: 0, timePosted: Date())
    ]
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "voterUUID" : Foundation.UUID.getTripleID(),
            "value" : value,
            "timePosted" : Timestamp(date: timePosted)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Vote {
        return Vote(UUID: dictionary["UUID"] as! String,
                    voterUUID: dictionary["voterUUID"] as! String,
                    value: dictionary["value"] as! Int,
                    timePosted: Date.decodeDate(dictionary["timePosted"]!))
    }
}
