//
//  ChatMember.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/6/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct ChatMember: Transportable, Equatable {
    var UUID = Foundation.UUID.getTripleID()
    var userID: String
    var emoji: String
    var color: Color
    /// This is used for blocked users as the block date.
    ///
    /// In other contexts, this variable is meaningless.
    var associatedDate = Date()
    
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
            ],
            "associatedDate" : Timestamp(date: associatedDate)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> ChatMember {
        return ChatMember(UUID: dictionary["UUID"] as! String,
                          userID: dictionary["userID"] as! String,
                          emoji: dictionary["emoji"] as! String,
                          color: {
            let colorComponents = dictionary["color"] as! [Double]
            return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
        }(),
                          associatedDate: Date.decodeDate(dictionary["associatedDate"]!))
    }
    
    static func == (lhs: ChatMember, rhs: ChatMember) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    
    static var samples: [ChatMember] = [
        .init(userID: "001", emoji: "😔", color: .blue, associatedDate: Date()),
        .init(userID: "002", emoji: "😅", color: .orange, associatedDate: Date()),
        .init(userID: "003", emoji: "📨", color: .red, associatedDate: Date()),
        .init(userID: "004", emoji: "🎀", color: .purple, associatedDate: Date()),
        .init(userID: "005", emoji: "🇸🇭", color: .yellow, associatedDate: Date())
    ]
    
    static var sampleIDs = ["001", "002", "003", "004", "005"]
    static var sampleEmojis = ["😔", "😅", "📨", "🎀", "🇸🇭"]
    static var sampleColors: [Color] = [.blue, .orange, .red, .purple, .yellow]
    static var sampleColorNames = ["blue", "orange", "red", "purple", "yellow"]
}
