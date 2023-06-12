//
//  User.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct User: Transportable, Codable {
    var UUID = Foundation.UUID.getTripleID()
    var phoneNumber: String
    var emoji: String
    var color: Color
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "phoneNumber" : phoneNumber,
            "emoji" : emoji,
            "color" : [
                Double(UIColor(color).cgColor.components![0]),
                Double(UIColor(color).cgColor.components![1]),
                Double(UIColor(color).cgColor.components![2]),
                Double(UIColor(color).cgColor.components![3])
            ]
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> User {
        return User(UUID: dictionary["UUID"] as! String,
                    phoneNumber: dictionary["phoneNumber"] as! String,
                    emoji: dictionary["emoji"] as! String,
                    color: {
            let colorComponents = dictionary["color"] as! [Double]
            return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
        }())
    }
    
    func getCurrentUser() -> User {
        // TODO: Attempt to transport /users/{UID} from the server!
        // If it doesn't exist, create it!
        // Then return the User object!
        // We should be able to check against error code 1 for the existence! Yay! :)
        // Also, change this to async!
        // Also also, maybe get this right on sign-in so we don't have to do it every time? Idk
    }
    
    static func getSample() -> User {
        return .init(UUID: "sample user",
                     phoneNumber: "313-605-9030",
                     emoji: Emoji.allEmojis.randomElement()!,
                     color: User.iconColors.randomElement()!)
    }
    
    static var iconColors: [Color] = [
        .blue,
        .brown,
        .cyan,
        .gray,
        .green,
        .indigo,
        .mint,
        .orange,
        .pink,
        .purple,
        .red,
        .teal,
        .yellow
    ]
}
