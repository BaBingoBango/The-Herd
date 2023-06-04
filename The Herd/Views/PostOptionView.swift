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
    
    // MARK: View Body
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(post.author.color)
                    
                    Text(post.author.emoji)
                        .font(.system(size: 25))
                }
                .offset(y: -12.5)
                
                Text("\(post.calculateDistanceFromLocation(latitude: 30, longitude: 50)) · \(post.distanceFromNow)")
                    .offset(y: -6.5)
                
                Spacer()
                
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 30))
                    .padding(.top, 12.5)
            }
            
            Text(post.text)
                .font(.system(size: 30))
                .padding(.bottom, 5)
            
            HStack {
                Label("\(Post.countComments(post.comments))", systemImage: "bubble.left")
                
                Spacer()
                
                Button(action: {
                    changeVote(newValue: post.votes[User.sample.UUID]?.value == 1 ? 0 : 1)
                }) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(post.votes[User.sample.UUID]?.value == 1 ? .green : .primary)
                }
                
                Text("\(post.score)")
                
                Button(action: {
                    changeVote(newValue: post.votes[User.sample.UUID]?.value == -1 ? 0 : -1)
                }) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(post.votes[User.sample.UUID]?.value == -1 ? .red : .primary)
                }
            }
        }
        .padding([.leading, .bottom, .trailing])
        .modifier(RectangleWrapper(color: .gray, opacity: 0.1))
        .padding(.top, 20)
    }
    
    // MARK: View Functions
    func changeVote(newValue: Int) {
        let originalPost = post
        let newVote = Vote(voter: User.sample, value: newValue, timePosted: Date())
        post.votes[User.sample.UUID] = newVote
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
