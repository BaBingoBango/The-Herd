//
//  Address.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/2/23.
//

import Foundation
import SwiftUI

struct Address: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var userUUID: String
    var userEmoji: String
    var userColor: Color
    var nickname: String
    var comment: String
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "userUUID" : userUUID,
            "userEmoji" : userEmoji,
            "userColor" : [
                Double(UIColor(userColor).cgColor.components![0]),
                Double(UIColor(userColor).cgColor.components![1]),
                Double(UIColor(userColor).cgColor.components![2]),
                Double(UIColor(userColor).cgColor.components![3])
            ],
            "nickname" : nickname,
            "comment" : comment
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Address {
        return Address(UUID: dictionary["UUID"] as! String,
                       userUUID: dictionary["userUUID"] as! String,
                       userEmoji: dictionary["userEmoji"] as! String,
                       userColor: {
               let colorComponents = dictionary["userColor"] as! [Double]
               return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
           }(),
                       nickname: dictionary["nickname"] as! String,
                       comment: dictionary["comment"] as! String
        )
    }
}
