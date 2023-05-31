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
    var userUUID: String
    var isUpvote: Bool
    var timePosted: Date
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "userUUID" : userUUID,
            "isUpvote" :isUpvote,
            "timePosted" : Timestamp(date: timePosted)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Vote {
        return Vote(UUID: dictionary["UUID"] as! String,
                    userUUID: dictionary["userUUID"] as! String,
                    isUpvote: dictionary["isUpvote"] as! Bool,
                    timePosted: { (dictionary["timePosted"] as! Timestamp).dateValue() }())
    }
}
