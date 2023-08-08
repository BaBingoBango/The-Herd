//
//  Chat.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import Foundation

struct Chat {
    var UUID = Foundation.UUID.getTripleID()
    var members: [ChatMember]
    var messages: [Message]
    
    static var samples: [Chat] = [
        .init(members: ChatMember.samples, messages: [
            .init(sender: .samples.randomElement()!, text: "The good!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "The bad!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "The ugly!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "I'm now going to write my very long opinions on this movie. I think it was great! What do you guys think? Although it was long, to be sure, it was a ton of fun! A blast! Hah!", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "Hard agree!", timeSent: Date.randomBackdate())
        ]),
        .init(members: [ChatMember.samples.randomElement()!], messages: [
            .init(sender: .samples.randomElement()!, text: "Who am I?", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "Is this a group chat?", timeSent: Date.randomBackdate()),
            .init(sender: .samples.randomElement()!, text: "Huh?? 🌞", timeSent: Date.randomBackdate()),
        ])
    ]
}
