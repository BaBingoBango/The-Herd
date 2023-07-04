//
//  Post.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import CoreLocation

struct Post: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var authorUUID: String
    var authorEmoji: String
    var authorColor: Color
    var text: String
    var votes: [String : Vote] // user ID : user vote
    var commentLevel = 0
    var comments: [Post]
    var timePosted: Date
    var latitude: Double
    var longitude: Double
    
    var score: Int {
        var score = 0
        for eachVote in votes.values {
            score += eachVote.value
        }
        return score
    }
    
    var distanceFromNow: String {
        let secondsFromNow = timePosted.distance(to: Date())
        
        if secondsFromNow < 1 {
            return "just now"
            
        } else if secondsFromNow < 60 {
            return "\(Int(secondsFromNow.rounded())) sec ago"
            
        } else if secondsFromNow < 60 * 60 {
            return "\(Int(secondsFromNow.rounded() / 60)) min ago"
            
        } else if secondsFromNow < 60 * 60 * 24 {
            return "\(Int(secondsFromNow.rounded() / (60 * 60))) hr ago"
        
        } else if secondsFromNow < 60 * 60 * 24 * 7 {
            return "\(Int(secondsFromNow.rounded() / (60 * 60 * 24))) dy ago"
        
        } else {
            return "\(Int(secondsFromNow.rounded() / (60 * 60 * 24 * 7))) wk ago"
        }
    }
    
    func upload(operation: Binding<Operation>?, onError: ((Error) -> ())?, onSuccess: (() -> ())?) {
        // First, upload the post!
        transportToServer(path: postsCollection,
                                  documentID: UUID,
                                  operation: operation,
                                  onError: { error in onError?(error) },
                                  onSuccess: {
            
            // Then, upload the location!
            GeoFirestore(collectionRef: postsCollection).setLocation(geopoint: .init(latitude: latitude, longitude: longitude), forDocumentWithID: UUID) { error in
                if let error = error {
                    onError?(error)
                    
                } else {
                    onSuccess?()
                }
            }
        })
    }
    
    func calculateDistanceFromLocation(latitude: Double, longitude: Double) -> String {
        let postLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let requestedLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        let milesAway = Measurement(value: postLocation.distance(from: requestedLocation), unit: UnitLength.meters).converted(to: .miles).value
        return "\(Int(milesAway.rounded())) mi"
    }
    
    static func countComments(_ commentsToCount: [Post]) -> Int {
        var count = 0
        for eachComment in commentsToCount {
            count += 1
            count += Post.countComments(eachComment.comments)
        }
        return count
    }
    
    static func hasUserCommented(_ commentsToCheck: [Post], userUUID: String) -> Bool {
        for eachComment in commentsToCheck {
            if eachComment.authorUUID == userUUID { return true }
            return Post.hasUserCommented(eachComment.comments, userUUID: userUUID)
        }
        return false
    }
    
    static func uploadSampleData(successes: Int = 0) {
        if successes >= 2000 {
            return
        }
        
        let newPost = Post(authorUUID: User.getSample().UUID,
                           authorEmoji: User.getSample().emoji,
                           authorColor: User.getSample().color,
                           text: Taylor.lyrics.randomElement()!,
                           votes: Vote.samples,
                           comments: [Post.sample],
//                                   timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))),
                           timePosted: Date(),
                           latitude: 10 * Double.random(in: 1...5),
                           longitude: 10 * Double.random(in: 1...5))
        
        newPost.upload(operation: nil,
                       onError: { error in fatalError(error.localizedDescription) },
                       onSuccess: { print("⭐️ uploaded post no. \(successes)! ⭐️"); uploadSampleData(successes: successes + 1) })
    }
    
    static func getSamples() -> [Post] {
        var posts: [Post] = []
        for eachLyric in Taylor.lyrics {
            posts.append(.init(authorUUID: User.getSample().UUID, authorEmoji: User.getSample().emoji, authorColor: User.getSample().color, text: eachLyric, votes: Vote.samples, comments: [Post.sample], timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))), latitude: 50, longitude: 50))
        }
        return posts
    }
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "authorUUID" : authorUUID,
            "authorEmoji" : authorEmoji,
            "authorColor" : [
                Double(UIColor(authorColor).cgColor.components![0]),
                Double(UIColor(authorColor).cgColor.components![1]),
                Double(UIColor(authorColor).cgColor.components![2]),
                Double(UIColor(authorColor).cgColor.components![3])
            ],
            "text" : text,
            "votes" : votes.mapValues({ $0.dictify() }),
            "comments" : comments.map({ $0.dictify() }),
            "timePosted" : Timestamp(date: timePosted),
            "latitude" : latitude,
            "longitude" : longitude
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Post {
        return Post(UUID: dictionary["UUID"] as! String,
                    authorUUID: dictionary["authorUUID"] as! String,
                    authorEmoji: dictionary["authorEmoji"] as! String,
                    authorColor: {
            let colorComponents = dictionary["authorColor"] as! [Double]
            return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
        }(),
                    text: dictionary["text"] as! String,
                    votes: (dictionary["votes"] as! [String : Any]).mapValues({ Vote.dedictify($0 as! [String : Any]) }),
                    comments: (dictionary["comments"] as! [[String : Any]]).map { Post.dedictify($0) },
                    timePosted: Date.decodeDate(dictionary["timePosted"]!),
                    latitude: dictionary["latitude"] as! Double,
                    longitude: dictionary["longitude"] as! Double
        )
    }
    
    static var sample = Post(authorUUID: Foundation.UUID.getTripleID(),
                             authorEmoji: Emoji.allEmojis.randomElement()!,
                             authorColor: User.iconColors.randomElement()!,
                             text: Taylor.lyrics.randomElement()!,
                             votes: Vote.samples,
                             comments: [.init(authorUUID: Foundation.UUID.getTripleID(),
                                              authorEmoji: Emoji.allEmojis.randomElement()!,
                                              authorColor: User.iconColors.randomElement()!,
                                              text: "amazing post",
                                              votes: Vote.samples,
                                              
                                              commentLevel: 1,
                                              comments: [.init(authorUUID: Foundation.UUID.getTripleID(),
                                                               authorEmoji: Emoji.allEmojis.randomElement()!,
                                                               authorColor: User.iconColors.randomElement()!,
                                                               text: "This is a longer comment. I wonder how lots of these comments will appear in the app?",
                                                               votes: [:],
                                                               commentLevel: 2,
                                                               comments: [],
                                                               timePosted: Date(),
                                                               latitude: 0,
                                                               longitude: 0)],
                                              
                                              timePosted: Date(),
                                              latitude: 0,
                                              longitude: 0),
                                        
                                        .init(authorUUID: Foundation.UUID.getTripleID(),
                                              authorEmoji: Emoji.allEmojis.randomElement()!,
                                              authorColor: User.iconColors.randomElement()!, text: "w content 🥶",
                                              votes: [:],
                                              commentLevel: 1,
                                              comments: [],
                                              timePosted: Date(),
                                              latitude: 0,
                                              longitude: 0)],
                             timePosted: Date(timeIntervalSinceNow: -6759),
                             latitude: 42.50807,
                             longitude: 83.40217)
}
