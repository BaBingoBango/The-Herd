//
//  ChatMember.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import Foundation
import SwiftUI

struct ChatMember: Transportable, Equatable {
    var UUID = Foundation.UUID.getTripleID()
    var userID: String
    var emoji: String
    var color: Color
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "userID" : userID,
            "emoji" : emoji,
            "color" : [
                Double(UIColor(color).cgColor.components![0]),
                Double(UIColor(color).cgColor.components![1]),
                Double(UIColor(color).cgColor.components![2]),
                Double(UIColor(color).cgColor.components![3])
            ]
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> ChatMember {
        return ChatMember(UUID: dictionary["UUID"] as! String,
                          userID: dictionary["userID"] as! String,
                          emoji: dictionary["emoji"] as! String,
                          color: {
            let colorComponents = dictionary["color"] as! [Double]
            return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
        }())
    }
    
    static func == (lhs: ChatMember, rhs: ChatMember) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    
    static var samples: [ChatMember] = [
        .init(userID: "001", emoji: "😔", color: .blue),
        .init(userID: "002", emoji: "😅", color: .orange),
        .init(userID: "003", emoji: "📨", color: .red),
        .init(userID: "004", emoji: "🎀", color: .purple),
        .init(userID: "005", emoji: "🇸🇭", color: .yellow)
    ]
    
    static var sampleIDs = ["001", "002", "003", "004", "005"]
    static var sampleEmojis = ["😔", "😅", "📨", "🎀", "🇸🇭"]
    static var sampleColors = ["blue", "orange", "red", "purple", "yellow"]
}
