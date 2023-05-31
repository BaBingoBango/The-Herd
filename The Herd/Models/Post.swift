//
//  Post.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation
import FirebaseFirestore

struct Post: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var author: User
    var text: String
    /// User UUID : User Vote
    var votes: [String : Vote]
    var timePosted: Date
    var latitude: Double
    var longitude: Double
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "author" : author.dictify(),
            "text" : text,
            "votes" : votes.mapValues({ $0.dictify() }),
            "timePosted" : Timestamp(date: timePosted),
            "latitude" : latitude,
            "longitude" : longitude
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Post {
        return Post(UUID: dictionary["UUID"] as! String,
                    author: User.dedictify(dictionary["author"] as! [String : Any]),
                    text: dictionary["text"] as! String,
                    votes: (dictionary["votes"] as! [String : Any]).mapValues({ Vote.dedictify($0 as! [String : Any]) }),
                    timePosted: { (dictionary["timePosted"] as! Timestamp).dateValue() }(),
                    latitude: dictionary["latitude"] as! Double,
                    longitude: dictionary["longitude"] as! Double
        )
    }
}
