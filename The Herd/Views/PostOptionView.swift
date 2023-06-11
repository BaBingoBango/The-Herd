//
//  PostOptionView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import SwiftUI
import FirebaseFirestore

/// An app view written in SwiftUI!
struct PostOptionView: View {
    
    // MARK: View Variables
    @State var post = Post.sample
    var showTopBar = true
    var showText = true
    var seperateControls = true
    var cornerRadius = 20.0
    var bottomBarSize: CGFloat = 20
    var voteValue: Int {
        post.votes[User.getSample().UUID]?.value ?? 0
    }
    var hasUserCommented: Bool {
        Post.hasUserCommented(post.comments, userUUID: User.getSample().UUID)
    }
    
    // MARK: View Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showTopBar {
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 37.5))
                            .foregroundColor(post.author.color)

                        Text(post.author.emoji)
                            .font(.system(size: 25))
                    }
                    .offset(y: -12.5)
                    
                    Text("\(post.distanceFromNow) ago · \(post.calculateDistanceFromLocation(latitude: 42.50807, longitude: 83.40217)) away")
                        .font(.system(size: 17.5))
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                        .offset(y: -4.5)
                    
                    Spacer()
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size: 25))
                        .foregroundColor(.secondary)
                        .offset(y: -5)
                }
                .padding(.horizontal)
                
                Divider()
                    .offset(y: -8)
            }
            
            if showText {
                Text(post.text)
                    .font(.system(size: 30, design: .default))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 15)
                    .padding(.top, showTopBar ? 5 : 20)
                    .padding(.horizontal)
            }
            
            HStack {
                Label("\(Post.countComments(post.comments))", systemImage: hasUserCommented ? "bubble.left.fill" : "bubble.left")
                    .font(.system(size: bottomBarSize))
                    .fontWeight(.semibold)
                    .foregroundColor(hasUserCommented ? post.author.color : .secondary)
                    .padding(.trailing, seperateControls ? 0 : 15)
                
                if seperateControls {
                    Spacer()
                }
                
                Button(action: {
                    changeVote(newValue: voteValue == 1 ? 0 : 1)
                }) {
                    Image(systemName: voteValue == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.system(size: bottomBarSize))
                        .fontWeight(.semibold)
                        .foregroundColor(voteValue == 1 ? .green : .secondary)
                }
                
                Text("\(post.score)")
                    .font(.system(size: bottomBarSize))
                    .fontWeight(.semibold)
                    .foregroundColor({
                        switch voteValue {
                        case 1: return .green
                        case -1: return .red
                        default: return .secondary
                        }
                    }())
                
                Button(action: {
                    changeVote(newValue: voteValue == -1 ? 0 : -1)
                }) {
                    Image(systemName: voteValue == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.system(size: bottomBarSize))
                        .fontWeight(.semibold)
                        .foregroundColor(voteValue == -1 ? .red : .secondary)
                }
            }
            .padding(.horizontal, seperateControls ? 15 : 5)
        }
        .padding(.bottom)
        .modifier(RectangleWrapper(color: post.author.color, useGradient: true, opacity: 0.04, cornerRadius: cornerRadius, hideRectangle: !showText))
        .padding(.top, showTopBar ? 20 : 0)
    }
    
    // MARK: View Functions
    func changeVote(newValue: Int) {
        let originalPost = post
        let newVote = Vote(voter: User.getSample(), value: newValue, timePosted: Date())
        post.votes[User.getSample().UUID] = newVote
        updatePostOnServer(originalPost: originalPost)
    }
    
    func updatePostOnServer(originalPost: Post) {
        post.transportToServer(path: postsCollection,
                               documentID: post.UUID,
                               operation: nil,
                               onError: { error in post = originalPost; fatalError(error.localizedDescription) },
                               onSuccess: nil)
    }
}

// MARK: View Preview
struct PostOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            PostOptionView()
                .padding()
        }
    }
}

// MARK: Support Views
// Support views go here! :)
