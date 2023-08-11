//
//  Message.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import Foundation
import FirebaseFirestore

struct Message: Transportable, Hashable {
    var UUID = Foundation.UUID.getTripleID()
    var sender: ChatMember
    var text: String
    var timeSent: Date
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "sender" : sender.dictify(),
            "text" : text,
            "timeSent" : Timestamp(date: timeSent),
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Self {
        return Message(UUID: dictionary["UUID"] as! String,
                       sender: ChatMember.dedictify(dictionary["sender"] as! [String : Any]),
                       text: dictionary["text"] as! String,
                       timeSent: Date.decodeDate(dictionary["timeSent"]!)
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(UUID)
    }
}
