//
//  Chat.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Chat: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var memberIDs: [String]
    var memberEmojis: [String]
    var memberColors: [Color]
    var messages: [Message]
    var dateCreated = Date()
    
    func getEmoji(_ forID: String) -> String {
        return memberEmojis[memberIDs.firstIndex(of: forID) ?? 0]
    }
    
    func getColor(_ forID: String) -> Color {
        return memberColors[memberIDs.firstIndex(of: forID) ?? 0]
    }
    
    static var samples: [Chat] = [
        .init(memberIDs: ChatMember.sampleIDs, memberEmojis: ChatMember.sampleEmojis, memberColors: ChatMember.sampleColors, messages: [
            .init(sender: .samples.randomElement()!, text: "The good!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "The bad!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "The ugly!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "I'm now going to write my very long opinions on this movie. I think it was great! What do you guys think? Although it was long, to be sure, it was a ton of fun! A blast! Hah!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "Hard agree!", timeSent: Date.randomBackdate())
        ]),
        .init(memberIDs: ChatMember.sampleIDs, memberEmojis: ChatMember.sampleEmojis, memberColors: ChatMember.sampleColors, messages: [
            .init(sender: .samples.randomElement()!, text: "Who am I?", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "Is this a group chat?", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "Huh?? 🌞", timeSent: Date.randomBackdate()),
        ])
    ]
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "memberIDs" : memberIDs,
            "memberEmojis" : memberEmojis,
            "memberColors" : memberColors.map({ $0.dictify() }),
            "messages" : messages.map({ $0.dictify() }),
            "dateCreated" : Timestamp(date: dateCreated)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Chat {
        return Chat(UUID: dictionary["UUID"] as! String,
                    memberIDs: dictionary["memberIDs"] as! [String],
                    memberEmojis: dictionary["memberEmojis"] as! [String],
                    memberColors: (dictionary["memberColors"] as! [[String : Any]]).map { Color.dedictify($0) },
                    messages: (dictionary["messages"] as! [[String : Any]]).map { Message.dedictify($0) },
                    dateCreated: Date.decodeDate(dictionary["dateCreated"]!)
                    )
    }
}
