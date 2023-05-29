//
//  Post.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation

struct Post {
    var UUID: String
    var author: User
    var text: String
    /// User UUID : User Vote
    var votes: [String : Vote]
    var timePosted: Date
}
