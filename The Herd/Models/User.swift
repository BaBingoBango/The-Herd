//
//  User.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation
import SwiftUI

struct User: Transportable {
    var UUID: String
    var phoneNumber: String
    var emoji: String
    var color: Color
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "phoneNumber" : phoneNumber,
            "emoji" : emoji,
            "color" : [
                Double(color.cgColor?.components![0] ?? 1),
                Double(color.cgColor?.components![1] ?? 0),
                Double(color.cgColor?.components![2] ?? 0),
                Double(color.cgColor?.components![3] ?? 1)
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
}
