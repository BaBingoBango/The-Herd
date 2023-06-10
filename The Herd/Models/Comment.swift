//
//  Comment.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import Foundation
import FirebaseFirestore

struct Comment: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var author: User
    var text: String
    /// User UUID : User Vote
    var votes: [String : Vote]
    var comments: [Comment]
    var timePosted: Date
    
    static let samples: [Comment] = [
        .init(author: .getSample(), text: Taylor.lyrics.randomElement()!, votes: Vote.samples, comments: [], timePosted: Date()),
        .init(author: .getSample(), text: Taylor.lyrics.randomElement()!, votes: Vote.samples, comments: [
            .init(author: .getSample(), text: Taylor.lyrics.randomElement()!, votes: Vote.samples, comments: [], timePosted: Date())
        ], timePosted: Date())
    ]
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "author" : author.dictify(),
            "text" : text,
            "votes" : votes.mapValues({ $0.dictify() }),
            "comments" : comments.map({ $0.dictify() }),
            "timePosted" : Timestamp(date: timePosted)
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Comment {
        return Comment(UUID: dictionary["UUID"] as! String,
                    author: User.dedictify(dictionary["author"] as! [String : Any]),
                    text: dictionary["text"] as! String,
                    votes: (dictionary["votes"] as! [String : Any]).mapValues({ Vote.dedictify($0 as! [String : Any]) }),
                    comments: (dictionary["comments"] as! [[String : Any]]).map { Comment.dedictify($0) },
                    timePosted: Date.decodeDate(dictionary["timePosted"]!)
        )
    }
}
