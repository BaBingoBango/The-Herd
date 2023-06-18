//
//  Draft.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/17/23.
//

import Foundation
import FirebaseFirestore

struct Draft: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var text: String
    var dateCreated: Date
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "text" : text,
            "dateCreated" : Timestamp(date: dateCreated)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Draft {
        return Draft(UUID: dictionary["UUID"] as! String,
                     text: dictionary["text"] as! String,
                     dateCreated: Date.decodeDate(dictionary["dateCreated"]!)
        )
    }
}
