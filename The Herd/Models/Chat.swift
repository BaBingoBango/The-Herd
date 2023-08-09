//
//  Chat.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import Foundation

struct Chat: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var memberIDs: [String]
    var memberEmojis: [String]
    var memberColorNames: [String]
    var messages: [Message]
    
    static var samples: [Chat] = [
        .init(memberIDs: ChatMember.sampleIDs, memberEmojis: ChatMember.sampleEmojis, memberColorNames: ChatMember.sampleColors, messages: [
            .init(sender: .samples.randomElement()!, text: "The good!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "The bad!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "The ugly!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "I'm now going to write my very long opinions on this movie. I think it was great! What do you guys think? Although it was long, to be sure, it was a ton of fun! A blast! Hah!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "Hard agree!", timeSent: Date.randomBackdate())
        ]),
        .init(memberIDs: ChatMember.sampleIDs, memberEmojis: ChatMember.sampleEmojis, memberColorNames: ChatMember.sampleColors, messages: [
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
            "memberColorNames" : memberColorNames,
            "messages" : messages.map({ $0.dictify() })
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Chat {
        return Chat(UUID: dictionary["UUID"] as! String,
                    memberIDs: dictionary["memberIDs"] as! [String],
                    memberEmojis: dictionary["memberEmojis"] as! [String],
                    memberColorNames: dictionary["memberColorNames"] as! [String],
                    messages: (dictionary["messages"] as! [[String : Any]]).map { Message.dedictify($0) }
                    )
    }
}
