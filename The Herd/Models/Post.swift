//
//  Post.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Post: Transportable {
    var UUID = Foundation.UUID.getTripleID()
    var author: User // TODO: replace this with ID for privacy reasons
    var text: String
    /// User UUID : User Vote
    var votes: [String : Vote]
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
            if eachComment.author.UUID == userUUID { return true }
            return Post.hasUserCommented(eachComment.comments, userUUID: userUUID)
        }
        return false
    }
    
    static func uploadSampleData(successes: Int = 0) {
        if successes >= 2000 {
            return
        }
        
        let newPost = Post(author: .getSample(),
                           text: Taylor.lyrics.randomElement()!,
                           votes: Vote.samples,
                           comments: [Post.sample],
//                                   timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))),
                           timePosted: Date(),
                           latitude: 10 * Double.random(in: 1...5),
                           longitude: 10 * Double.random(in: 1...5))
        
        newPost.transportToServer(path: postsCollection,
                                  documentID: newPost.UUID,
                                  operation: nil,
                                  onError: { error in fatalError(error.localizedDescription) },
                                  onSuccess: { print("⭐️ uploaded post no. \(successes)! ⭐️"); uploadSampleData(successes: successes + 1) })
    }
    
    static func getSamples() -> [Post] {
        var posts: [Post] = []
        for eachLyric in Taylor.lyrics {
            posts.append(.init(author: .getSample(), text: eachLyric, votes: Vote.samples, comments: [Post.sample], timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))), latitude: 50, longitude: 50))
        }
        return posts
    }
    
    func dictify() -> [String : Any] {
        return [
            "UUID" : UUID,
            "author" : author.dictify(),
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
                    author: User.dedictify(dictionary["author"] as! [String : Any]),
                    text: dictionary["text"] as! String,
                    votes: (dictionary["votes"] as! [String : Any]).mapValues({ Vote.dedictify($0 as! [String : Any]) }),
                    comments: (dictionary["comments"] as! [[String : Any]]).map { Post.dedictify($0) },
                    timePosted: Date.decodeDate(dictionary["timePosted"]!),
                    latitude: dictionary["latitude"] as! Double,
                    longitude: dictionary["longitude"] as! Double
        )
    }
    
    static var sample = Post(author: .getSample(),
                             text: Taylor.lyrics.randomElement()!,
                             votes: Vote.samples,
                             comments: [.init(author: .getSample(), text: "amazing post", votes: Vote.samples, comments: [
                                .init(author: .getSample(), text: "This is a longer comment. I wonder how lots of these comments will appear in the app?", votes: [:], comments: [], timePosted: Date(), latitude: 0, longitude: 0)
                             ], timePosted: Date(), latitude: 0, longitude: 0),
                                        .init(author: .getSample(), text: "w content 🥶", votes: [:], comments: [], timePosted: Date(), latitude: 0, longitude: 0)],
                             timePosted: Date(timeIntervalSinceNow: -6759),
                             latitude: 42.50807,
                             longitude: 83.40217)
}
