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
    @Published var addresses: [String : Address]
    @Published var hiddenChatIDs: [String]
    @Published var fontPreference: FontPreference
    
    required init(UUID: String = Foundation.UUID.getTripleID(), emoji: String, color: Color, joinDate: Date, locationMode: LocationMode, savedLocations: [String : SavedLocation], addresses: [String : Address], hiddenChatIDs: [String], fontPreference: FontPreference) {
        self.UUID = UUID
        self.emoji = emoji
        self.color = color
        self.joinDate = joinDate
        self.locationMode = locationMode
        self.savedLocations = savedLocations
        self.addresses = addresses
        self.hiddenChatIDs = hiddenChatIDs
        self.fontPreference = fontPreference
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    
    func replaceFields(_ user: User) {
        self.UUID = user.UUID
        self.emoji = user.emoji
        self.color = user.color
        self.joinDate = user.joinDate
        self.locationMode = user.locationMode
        self.savedLocations = user.savedLocations
        self.addresses = user.addresses
        self.hiddenChatIDs = user.hiddenChatIDs
        self.fontPreference = user.fontPreference
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
            "addresses" : addresses.mapValues({ $0.dictify() }),
            "hiddenChatIDs" : hiddenChatIDs,
            "fontPreference" : fontPreference.toString()
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
                    savedLocations: (dictionary["savedLocations"] as! [String : Any]).mapValues({ SavedLocation.dedictify($0 as! [String : Any]) }),
                    addresses: (dictionary["addresses"] as! [String : Any]).mapValues({ Address.dedictify($0 as! [String : Any]) }),
                    hiddenChatIDs: dictionary["hiddenChatIDs"] as! [String],
                    fontPreference: FontPreference.fromString(dictionary["fontPreference"] as! String)
        )
    }
    
    func formatJoinDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: joinDate)
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
                                          locationMode: .current,
                                          savedLocations: [:],
                                          addresses: [:],
                                          hiddenChatIDs: [],
                                          fontPreference: .regular)
                
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
    
    func getLocation(_ locationManager: LocationManager) -> (Double, Double)? {
        switch locationMode {
        case .current:
            if let location = locationManager.lastLocation {
                return (location.coordinate.latitude, location.coordinate.longitude)
            } else {
                return nil
            }
            
        case .saved(let locationID):
            if let location = savedLocations[locationID] {
                return (location.latitude, location.longitude)
            } else {
                return nil
            }
        }
    }
    
    static func getSample() -> User {
        return .init(UUID: "sample user",
                     emoji: Emoji.allEmojis.randomElement()!,
                     color: User.iconColors.randomElement()!,
                     joinDate: Date(),
                     locationMode: .saved(locationID: "BEACH!!"),
                     savedLocations: ["E1974DB9-5198-409C-9707-599C56AB84A7-D8C69522-5B0F-4106-9149-A4CA2420F027-3105478D-4B1E-4A08-8AD2-989E41EB2096" : .init(emoji: "🐳", nickname: "example!", latitude: 0, longitude: 0)],
                     addresses: [:],
                     hiddenChatIDs: [],
                     fontPreference: .serif)
    }
    
    static var iconColors: [Color] = [
        .blue,
        .brown,
        .cyan,
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
    
    func generateReport() -> String {
        var answer = "[User Data Report for The Herd]\n\n"
        
        answer += "The following contains all information associated with your The Herd account.\n"
        answer += "Some data may be redacted to maintain the security and privacy of other users.\n\n"
        
        answer += "This file was generated on \(Date().formatted()).\n"
        answer += "It was generated by The Herd version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String), build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String).\n\n"
        
        answer += "[Google Firebase Authentication Data]\n"
        answer += "UID: Redacted for security reasons.\n"
        answer += "Is Anonymous: \(Auth.auth().currentUser!.isAnonymous)\n"
        answer += "Is Email Verified: \(Auth.auth().currentUser!.isEmailVerified)\n"
        answer += "Metadata:\n"
            answer += "\tCreation Date: \(Auth.auth().currentUser!.metadata.creationDate?.formatted() ?? "No Data")\n"
            answer += "\tLast Sign In Date: \(Auth.auth().currentUser!.metadata.lastSignInDate?.formatted() ?? "No Data")\n"
        answer += "Enrolled Multi Factors: \(Auth.auth().currentUser!.multiFactor.enrolledFactors.count)\n"
        answer += "Provider Data:\n"
        for eachDataItem in Auth.auth().currentUser!.providerData {
            answer += "\t(Provider Data Item)\n"
                answer += "\t\tDisplay Name: \(eachDataItem.displayName ?? "No Data")\n"
                answer += "\t\tEmail: \(eachDataItem.email ?? "No Data")\n"
                answer += "\t\tPhone Number: \(eachDataItem.phoneNumber ?? "No Data")\n"
                answer += "\t\tProvider ID: Redacted for security reasons.\n"
                answer += "\t\tUID: Redacted for security reasons.\n"
                answer += "\t\tPhoto URL: \(eachDataItem.photoURL?.absoluteString ?? "No Data")\n"
        }
        answer += "Provider ID: Redacted for security reasons.\n\n"
        
        answer += "[The Herd User Data]\n"
        answer += "UUID: Redacted for security reasons.\n"
        answer += "Color (RGB): \(color.cgColor?.components?.description ?? "No Data")\n"
        answer += "Join Date: \(joinDate.formatted())\n"
        answer += "Location Mode: \(locationMode == .current ? locationMode.toString() : "custom location with nickname \"\(savedLocations[locationMode.toString()]?.nickname ?? "unknown")\"")\n"
        answer += "Saved Locations:\n"
        for eachLocation in savedLocations {
            answer += "(Location with nickname \"\(eachLocation.value.nickname)\")\n"
                answer += "\tUUID: Redacted for security reasons.\n"
                answer += "\tEmoji: \(eachLocation.value.emoji)\n"
                answer += "\tColor (RGB): \(eachLocation.value.color.cgColor?.components?.description ?? "No Data")\n"
                answer += "\tLatitude: \(eachLocation.value.latitude)\n"
                answer += "\tLongitude: \(eachLocation.value.longitude)\n"
            answer += "\tDate Saved: \(eachLocation.value.dateSaved.formatted())\n"
        }
        answer += "Rolodex Entries:\n"
        for eachAddress in addresses {
            answer += "(Entry with nickname \"\(eachAddress.value.nickname)\")\n"
            answer += "\tUser UUID: Redacted for privacy reasons.\n"
            answer += "\tUser Emoji: \(eachAddress.value.userEmoji)\n"
            answer += "\tUser Color (RGB): \(eachAddress.value.userColor.cgColor?.components?.description ?? "No Data")\n"
            answer += "\tNickname: \(eachAddress.value.nickname)\n"
            answer += "\tComment: \(eachAddress.value.comment)\n"
        }
        answer += "Hidden Chats: \(hiddenChatIDs.count) (IDs redacted for security reasons)\n"
        answer += "Font Preference: \(fontPreference.toString())\n\n"
        
        answer += "Thank you for using The Herd! :)"
        
        return answer
    }
}
