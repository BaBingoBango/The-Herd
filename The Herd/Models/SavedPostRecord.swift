//
//  SavedPostRecord.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/29/23.
//

import Foundation
import FirebaseFirestore

struct SavedPostRecord: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var userUUID: String
    var postUUID: String
    var dateSaved: Date
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "userUUID" : userUUID,
            "postUUID" : postUUID,
            "dateSaved" : Timestamp(date: dateSaved)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> SavedPostRecord {
        return SavedPostRecord(UUID: dictionary["UUID"] as! String,
                             userUUID: dictionary["userUUID"] as! String,
                             postUUID: dictionary["postUUID"] as! String,
                             dateSaved: Date.decodeDate(dictionary["dateSaved"]!)
        )
    }
}
