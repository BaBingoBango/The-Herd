//
//  User.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct User: Transportable, Codable {
    var UUID = Foundation.UUID.getTripleID()
    var emoji: String
    var color: Color
    var joinDate: Date
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "emoji" : emoji,
            "color" : [
                Double(UIColor(color).cgColor.components![0]),
                Double(UIColor(color).cgColor.components![1]),
                Double(UIColor(color).cgColor.components![2]),
                Double(UIColor(color).cgColor.components![3])
            ],
            "joinDate" : Timestamp(date: joinDate)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> User {
        return User(UUID: dictionary["UUID"] as! String,
                    emoji: dictionary["emoji"] as! String,
                    color: {
            let colorComponents = dictionary["color"] as! [Double]
            return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
        }(),
                    joinDate: (dictionary["joinDate"] as! Timestamp).dateValue())
    }
    
    static func transportUserFromServer(_ userID: String, onError: ((Error) -> ())?, onSuccess: ((Self) -> ())?) {
        usersCollection.document(userID).getDocument { document, error in
            
            if let error = error {
                onError?(error)
                
            } else if !document!.exists {
                let newUserProfile = User(UUID: userID,
                                          emoji: Emoji.allEmojis.randomElement()!,
                                          color: User.iconColors.randomElement()!,
                                          joinDate: Date())
                
                newUserProfile.transportToServer(path: usersCollection,
                                                 documentID: userID,
                                                 operation: nil,
                                                 onError: { error in onError?(error) },
                                                 onSuccess: { onSuccess?(newUserProfile) })
            } else {
                onSuccess?(User.dedictify(document!.data()!))
            }
        }
    }
    
    static func getSample() -> User {
        return .init(UUID: "sample user",
                     emoji: Emoji.allEmojis.randomElement()!,
                     color: User.iconColors.randomElement()!,
                     joinDate: Date())
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
