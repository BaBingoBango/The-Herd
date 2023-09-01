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

class Post: Transportable, Equatable, ObservableObject, Identifiable {
    
    @Published var UUID = Foundation.UUID.getTripleID(); var id: String { UUID }
    @Published var authorUUID: String
    @Published var authorEmoji: String
    @Published var authorColor: Color
    @Published var anonymousIdentifierTable: [String : Int] = [:]
    @Published var text: String
    @Published var votes: [String : Vote] // user ID : user vote
    @Published var commentLevel: Int = 0
    @Published var comments: [Post]
    @Published var timePosted: Date
    @Published var latitude: Double
    @Published var longitude: Double
    @Published var mentions: [ChatMember]
    @Published var associatedUserIDs: [String] = []
    @Published var repost: [Post] = []
    
    required init(UUID: String = Foundation.UUID.getTripleID(), authorUUID: String, authorEmoji: String, authorColor: Color, anonymousIdentifierTable: [String : Int] = [:], text: String, votes: [String : Vote], commentLevel: Int = 0, comments: [Post], timePosted: Date, latitude: Double, longitude: Double, mentions: [ChatMember], associatedUserIDs: [String] = [], repost: [Post] = []) {
        self.UUID = UUID
        self.authorUUID = authorUUID
        self.authorEmoji = authorEmoji
        self.authorColor = authorColor
        self.anonymousIdentifierTable = anonymousIdentifierTable
        self.text = text
        self.votes = votes
        self.commentLevel = commentLevel
        self.comments = comments
        self.timePosted = timePosted
        self.latitude = latitude
        self.longitude = longitude
        self.mentions = mentions
        self.associatedUserIDs = associatedUserIDs
        self.repost = repost
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    
    func replaceFields(_ post: Post) {
        self.UUID = post.UUID
        self.authorUUID = post.authorUUID
        self.authorEmoji = post.authorEmoji
        self.authorColor = post.authorColor
        self.anonymousIdentifierTable = post.anonymousIdentifierTable
        self.text = post.text
        self.votes = post.votes
        self.commentLevel = post.commentLevel
        self.comments = post.comments
        self.timePosted = post.timePosted
        self.latitude = post.latitude
        self.longitude = post.longitude
        self.mentions = post.mentions
        self.associatedUserIDs = post.associatedUserIDs
        self.repost = post.repost
    }
    
    func getAnonymousNumber(_ userID: String) -> String? {
        if let number = anonymousIdentifierTable[userID] {
            if number == 0 {
                return "🕶️"
            } else if number / 10 >= 1 {
                return String(number)
            } else {
                return "0" + String(number)
            }
        } else {
            return nil
        }
    }
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
                          onSuccess: { [self] in
            
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
    
    func getUserKarma(_ userID: String) -> Int {
        var answer = 0
        if authorUUID == userID {
            answer += score
        }
        
        for eachComment in comments {
            if eachComment.authorUUID == userID {
                answer += eachComment.score
            }
            
            for eachSecondLevelComment in eachComment.comments {
                if eachSecondLevelComment.authorUUID == userID {
                    answer += eachSecondLevelComment.score
                }
            }
        }
        
        return answer
    }
    
    static func countComments(_ commentsToCount: [Post]) -> Int {
        var count = 0
        for eachComment in commentsToCount {
            count += 1
            count += Post.countComments(eachComment.comments)
        }
        return count
    }
    
    func countComments(_ userUUID: String) -> Int {
        var count = 0

        for eachFirstLevelComment in comments {
            if eachFirstLevelComment.authorUUID == userUUID {
                count += 1
            }
            
            for eachSecondLevelComment in eachFirstLevelComment.comments {
                if eachSecondLevelComment.authorUUID == userUUID {
                    count += 1
                }
            }
        }
        return count
    }
    
    func isUserCommenter(_ userUUID: String) -> Bool {
        return countComments(userUUID) >= 1
    }
    
    func removeUserComments(_ userUUID: String) -> [Post] {
        var commentsList = comments.filter { $0.authorUUID != userUUID }
        
        for (index, eachFirstLevelComment) in commentsList.enumerated() {
            commentsList[index].comments = eachFirstLevelComment.comments.filter { $0.authorUUID != userUUID }
        }
        
        return commentsList
    }
    
    static func hasUserCommented(_ commentsToCheck: [Post], userUUID: String) -> Bool {
        for eachComment in commentsToCheck {
            if eachComment.authorUUID == userUUID { return true }
            return Post.hasUserCommented(eachComment.comments, userUUID: userUUID)
        }
        return false
    }
    
    func deleteCommentOutOfPlace(_ withID: String) -> Post {
        Post(UUID: UUID,
             authorUUID: authorUUID,
             authorEmoji: authorEmoji,
             authorColor: authorColor,
             anonymousIdentifierTable: anonymousIdentifierTable,
             text: text,
             votes: votes,
             commentLevel: commentLevel,
             comments: {
            
            let newCommentsList = comments
            for eachComment in comments {
                eachComment.comments = eachComment.comments.filter({ $0.UUID != withID })
            }
            return newCommentsList.filter({ $0.UUID != withID })
        }(),
             timePosted: timePosted,
             latitude: latitude,
             longitude: longitude,
             mentions: mentions, associatedUserIDs: associatedUserIDs,
             repost: repost
        )
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
//                           timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))),
                           timePosted: Date(),
                           latitude: 10 * Double.random(in: 1...5),
                           longitude: 10 * Double.random(in: 1...5),
                           mentions: [])
        
        newPost.upload(operation: nil,
                       onError: { error in fatalError(error.localizedDescription) },
                       onSuccess: { print("⭐️ uploaded post no. \(successes)! ⭐️"); uploadSampleData(successes: successes + 1) })
    }
    
    static func getSamples() -> [Post] {
        var posts: [Post] = []
        for eachLyric in Taylor.lyrics {
            posts.append(.init(authorUUID: User.getSample().UUID, authorEmoji: User.getSample().emoji, authorColor: User.getSample().color, text: eachLyric, votes: Vote.samples, comments: [Post.sample], timePosted: Date() - TimeInterval((60 * Int.random(in: 0...500))), latitude: 50, longitude: 50, mentions: []))
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
            "anonymousIdentifierTable" : anonymousIdentifierTable,
            "text" : text,
            "votes" : votes.mapValues({ $0.dictify() }),
            "commentLevel" : commentLevel,
            "comments" : comments.map({ $0.dictify() }),
            "timePosted" : Timestamp(date: timePosted),
            "latitude" : latitude,
            "longitude" : longitude,
            "mentions": mentions.map({ $0.dictify() }),
            "associatedUserIDs" : associatedUserIDs,
            "repost" : repost.map({ $0.dictify() })
        ]
    }
    
    static func dedictify(_ dictionary: [String : Any]) -> Self {
        return Self(UUID: dictionary["UUID"] as! String,
                    authorUUID: dictionary["authorUUID"] as! String,
                    authorEmoji: dictionary["authorEmoji"] as! String,
                    authorColor: {
            let colorComponents = dictionary["authorColor"] as! [Double]
            return Color(cgColor: .init(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: colorComponents[3]))
        }(),
                    anonymousIdentifierTable: dictionary["anonymousIdentifierTable"] as! [String : Int],
                    text: dictionary["text"] as! String,
                    votes: (dictionary["votes"] as! [String : Any]).mapValues({ Vote.dedictify($0 as! [String : Any]) }),
                    commentLevel: dictionary["commentLevel"] as! Int,
                    comments: (dictionary["comments"] as! [[String : Any]]).map { Post.dedictify($0) },
                    timePosted: Date.decodeDate(dictionary["timePosted"]!),
                    latitude: dictionary["latitude"] as! Double,
                    longitude: dictionary["longitude"] as! Double,
                    mentions: (dictionary["mentions"] as! [[String : Any]]).map { ChatMember.dedictify($0) },
                    associatedUserIDs: dictionary["associatedUserIDs"] as! [String],
                    repost: (dictionary["repost"] as! [[String : Any]]).map { Post.dedictify($0) }
        )
    }
    
    static var sample = Post(UUID: "SAMPLE-POST",
                             authorUUID: Foundation.UUID.getTripleID(),
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
                                                               longitude: 0, mentions: []),
                                                         .init(authorUUID: Foundation.UUID.getTripleID(),
                                                                          authorEmoji: Emoji.allEmojis.randomElement()!,
                                                                          authorColor: User.iconColors.randomElement()!,
                                                                          text: "That sure was a long comment! 🫡🫡",
                                                                          votes: [:],
                                                                          commentLevel: 2,
                                                                          comments: [],
                                                                          timePosted: Date(),
                                                                          latitude: 0,
                                                                          longitude: 0,
                                                                          mentions: [])],
                                              
                                              timePosted: Date(),
                                              latitude: 0,
                                              longitude: 0,
                                              mentions: []),
                                        
                                        .init(authorUUID: Foundation.UUID.getTripleID(),
                                              authorEmoji: Emoji.allEmojis.randomElement()!,
                                              authorColor: User.iconColors.randomElement()!, text: "w content 🥶",
                                              votes: [:],
                                              commentLevel: 1,
                                              comments: [],
                                              timePosted: Date(),
                                              latitude: 0,
                                              longitude: 0,
                                              mentions: [])],
                             timePosted: Date(timeIntervalSinceNow: -6759),
                             latitude: 42.50807,
                             longitude: 83.40217,
                             mentions: [])
}

class PostListViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var listeners: [ListenerRegistration] = []
    
    func updatePost(at index: Int, with newPost: Post) {
        posts[index].replaceFields(newPost)
    }
    
    func observePost(at index: Int) {
        let post = posts[index]
        let listener = postsCollection.document(post.UUID).addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, let snapshotData = snapshot.data() {
                print("updating post...")
                DispatchQueue.main.async {
                    self.posts[index].replaceFields(Post.dedictify(snapshotData))
                }
            }
        }
        listeners.append(listener)
    }
}
