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

class User: Transportable, Equatable, ObservableObject {
    @Published var UUID = Foundation.UUID.getTripleID()
    @Published var emoji: String
    @Published var color: Color
    @Published var joinDate: Date
    @Published var locationMode: LocationMode
    @Published var savedLocations: [String : SavedLocation]
    
    required init(UUID: String = Foundation.UUID.getTripleID(), emoji: String, color: Color, joinDate: Date, locationMode: LocationMode, savedLocations: [String : SavedLocation]) {
        self.UUID = UUID
        self.emoji = emoji
        self.color = color
        self.joinDate = joinDate
        self.locationMode = locationMode
        self.savedLocations = savedLocations
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    
    func replace(_ user: User) {
        self.UUID = user.UUID
        self.emoji = user.emoji
        self.color = user.color
        self.joinDate = user.joinDate
        self.locationMode = user.locationMode
        self.savedLocations = user.savedLocations
    }
    
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
            "joinDate" : Timestamp(date: joinDate),
            "locationMode" : locationMode.toString(),
            "savedLocations" : savedLocations.mapValues({ $0.dictify() }),
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Self {
        return Self(UUID: dictionary["UUID"] as! String,
                    emoji: dictionary["emoji"] as! String,
                    color: {
            let colorComponents = dictionary["color"] as! [Double]
            return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
        }(),
                    joinDate: Date.decodeDate(dictionary["joinDate"]!),
                    locationMode: LocationMode.fromString(dictionary["locationMode"] as! String),
                    savedLocations: (dictionary["savedLocations"] as! [String : Any]).mapValues({ SavedLocation.dedictify($0 as! [String : Any]) }))
    }
    
    static func transportUserFromServer(_ userID: String, onError: ((Error) -> ())?, onSuccess: ((User) -> ())?) {
        usersCollection.document(userID).getDocument { document, error in
            
            if let error = error {
                onError?(error)
                
            } else if !document!.exists {
                let newUserProfile = User(UUID: userID,
                                          emoji: Emoji.allEmojis.randomElement()!,
                                          color: User.iconColors.randomElement()!,
                                          joinDate: Date(),
                                          locationMode: .none,
                                          savedLocations: [:])
                
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
                     joinDate: Date(),
                     locationMode: .none,
                     savedLocations: ["BEACH!!" : .init(emoji: "🏖️", nickname: "the beach!", latitude: 25.79327, longitude: 25.237094)])
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
