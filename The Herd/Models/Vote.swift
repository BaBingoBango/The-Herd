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
    var voter: User
    var value: Int
    var timePosted: Date
    
    static let samples: [String : Vote] = [
        Foundation.UUID.getTripleID() : .init(voter: .sample, value: 1, timePosted: Date()),
        Foundation.UUID.getTripleID() : .init(voter: .sample, value: 1, timePosted: Date()),
        Foundation.UUID.getTripleID() : .init(voter: .sample, value: -1, timePosted: Date()),
        Foundation.UUID.getTripleID() : .init(voter: .sample, value: 0, timePosted: Date())
    ]
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "voter" : voter.dictify(),
            "value" : value,
            "timePosted" : Timestamp(date: timePosted)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Vote {
        return Vote(UUID: dictionary["UUID"] as! String,
                    voter: User.dedictify(dictionary["voter"] as! [String : Any]),
                    value: dictionary["value"] as! Int,
                    timePosted: Date.decodeDate(dictionary["timePosted"]!))
    }
}
