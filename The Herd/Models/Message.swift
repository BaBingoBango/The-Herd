//
//  Message.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import Foundation

struct Message {
    var UUID = Foundation.UUID.getTripleID()
    var sender: ChatMember
    var text: String
    var timeSent: Date
}
