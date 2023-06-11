//
//  PostDetailView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/4/23.
//

import SwiftUI

/// An app view written in SwiftUI!
struct PostDetailView: View {
    
    // MARK: View Variables
    @State var post = Post.sample
    
    // MARK: View Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                PostOptionView(post: post, showTopBar: false, cornerRadius: 0)
                
                CommentsView(comments: post.comments, post: post)
                    .padding(.horizontal)
            }
            
            // MARK: Navigation Settings
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(post.author.emoji)
                            .font(.system(size: 25))
                            .padding(.top, 10)
                        
                        Text("\(post.distanceFromNow) ago · \(post.calculateDistanceFromLocation(latitude: 42.50807, longitude: 83.40217)) away")
                            .font(.system(size: 15))
                            .fontWeight(.heavy)
                            .padding(.bottom, 17.5)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
            })
            .toolbarBackground(post.author.color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostDetailView()
        }
    }
}

// MARK: Support Views
struct CommentsView: View {
    
    var comments: [Comment]
    @State var post: Post
    
    var body: some View {
        ForEach(comments, id: \.UUID) { eachComment in
            HStack {
                ZStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 37.5))
                        .foregroundColor(eachComment.author.color)
                    
                    Text(eachComment.author.emoji)
                        .font(.system(size: 25))
                }
                
                Text(eachComment.distanceFromNow)
                    .font(.system(size: 17.5))
                    .fontWeight(.heavy)
                    .foregroundColor(.secondary)
            }
            
            Text(eachComment.text)
                .font(.system(size: 22.5, design: .default))
                .fontWeight(.medium)
                .padding(.leading, 7.5)
                .padding(.bottom)
            
            HStack {
                Label("\(Post.countComments(eachComment.comments))", systemImage: Post.hasUserCommented(eachComment.comments, userUUID: User.getSample().UUID) ? "bubble.left.fill" : "bubble.left")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(Post.hasUserCommented(eachComment.comments, userUUID: User.getSample().UUID) ? eachComment.author.color : .secondary)
                
                Spacer()
                
                Button(action: {
                    changeVote(newValue: eachComment.votes[User.getSample().UUID]?.value == 1 ? 0 : 1, commentIndex: 0)
                }) {
                    Image(systemName: eachComment.votes[User.getSample().UUID]?.value ?? 0 == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(eachComment.votes[User.getSample().UUID]?.value == 1 ? .green : .secondary)
                }
                
                Text("\(eachComment.score)")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor({
                        switch eachComment.votes[User.getSample().UUID]?.value ?? 0 {
                        case 1: return .green
                        case -1: return .red
                        default: return .secondary
                        }
                    }())
                
                Button(action: {
                    changeVote(newValue: eachComment.votes[User.getSample().UUID]?.value ?? 0 == -1 ? 0 : -1, commentIndex: 0)
                }) {
                    Image(systemName: voteValue == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(voteValue == -1 ? .red : .secondary)
                }
            }
            .padding(.horizontal)
            
            CommentsView(comments: eachComment.comments)
                .padding(.leading)
        }
    }
    
    func changeVote(newValue: Int, commentIndex: Int) {
        let originalPost = post
        let newVote = Vote(voter: User.getSample(), value: newValue, timePosted: Date())
        post.comments[commentIndex].votes[User.getSample().UUID] = newVote
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
