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
    var userUUID: String
    var repost: [Post] = []
    var mentions: [ChatMember] = []
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "text" : text,
            "dateCreated" : Timestamp(date: dateCreated),
            "userUUID" : userUUID,
            "repost" : repost.map({ $0.dictify() }),
            "mentions": mentions.map({ $0.dictify() })
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Draft {
        return Draft(UUID: dictionary["UUID"] as! String,
                     text: dictionary["text"] as! String,
                     dateCreated: Date.decodeDate(dictionary["dateCreated"]!),
                     userUUID: dictionary["userUUID"] as! String,
                     repost: (dictionary["repost"] as! [[String : Any]]).map { Post.dedictify($0) },
                     mentions: (dictionary["mentions"] as! [[String : Any]]).map { ChatMember.dedictify($0) }
        )
    }
}
