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
    var author: User
    var text: String
    /// User UUID : User Vote
    var votes: [String : Vote]
    var comments: [Comment]
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
            return "\(Int(secondsFromNow.rounded())) sec"
            
        } else if secondsFromNow < 60 * 60 {
            return "\(Int(secondsFromNow.rounded() / 60)) min"
            
        } else if secondsFromNow < 60 * 60 * 24 {
            return "\(Int(secondsFromNow.rounded() / (60 * 60))) hr"
        
        } else if secondsFromNow < 60 * 60 * 24 * 7 {
            return "\(Int(secondsFromNow.rounded() / (60 * 60 * 24))) dy"
        
        } else {
            return "\(Int(secondsFromNow.rounded() / (60 * 60 * 24 * 7))) wk"
        }
    }
    
    func calculateDistanceFromLocation(latitude: Double, longitude: Double) -> String {
        let postLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let requestedLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        let milesAway = Measurement(value: postLocation.distance(from: requestedLocation), unit: UnitLength.meters).converted(to: .miles).value
        return "\(Int(milesAway.rounded())) mi"
    }
    
    static func countComments(_ commentsToCount: [Comment]) -> Int {
        var count = 0
        for eachComment in commentsToCount {
            count += 1
            count += Post.countComments(eachComment.comments)
        }
        return count
    }
    
    static func uploadSampleData() {
        var successes = 0
        for eachLyric in Taylor.lyrics {
            let newPost = Post(author: .sample, text: eachLyric + " (50, 50)", votes: Vote.samples, comments: Comment.samples, timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))), latitude: 50, longitude: 50)
            newPost.transportToServer(path: Firestore.firestore().collection("posts"),
                                      documentID: newPost.UUID,
                                      operation: nil,
                                      onError: { error in fatalError(error.localizedDescription) },
                                      onSuccess: { successes += 1; print("⭐️ uploaded post no. \(successes)! ⭐️") })
        }
    }
    
    static func getSamples() -> [Post] {
        var posts: [Post] = []
        for eachLyric in Taylor.lyrics {
            posts.append(.init(author: .sample, text: eachLyric, votes: Vote.samples, comments: Comment.samples, timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))), latitude: 50, longitude: 50))
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
                    comments: (dictionary["comments"] as! [[String : Any]]).map { Comment.dedictify($0) },
                    timePosted: Date.decodeDate(dictionary["timePosted"]!),
                    latitude: dictionary["latitude"] as! Double,
                    longitude: dictionary["longitude"] as! Double
        )
    }
    
    static var sample = Post(author: .sample,
                             text: Taylor.lyrics.randomElement()!,
                             votes: Vote.samples,
                             comments: [.init(author: .sample, text: "amazing post", votes: Vote.samples, comments: Comment.samples, timePosted: Date()),
                                        .init(author: .sample, text: "w content 🥶", votes: [:], comments: Comment.samples, timePosted: Date())],
                             timePosted: Date(timeIntervalSinceNow: -6759),
                             latitude: 42.50807,
                             longitude: 83.40217)
}
