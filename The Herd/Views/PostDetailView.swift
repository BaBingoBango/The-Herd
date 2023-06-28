//
//  PostDetailView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/4/23.
//

import SwiftUI
import FirebaseAuth

/// An app view written in SwiftUI!
struct PostDetailView: View {
    
    // MARK: View Variables
    @Binding var post: Post
    @State var currentUser: User? = nil
    
    // MARK: View Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let currentUser = currentUser {
                    PostOptionView(post: post, currentUser: currentUser, showTopBar: false, cornerRadius: 0)
                    
                    CommentsView(comments: post.comments, post: post)
                        .padding(.horizontal)
                }
            }
            
            // MARK: Navigation Settings
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(post.authorEmoji)
                            .font(.system(size: 25))
                            .padding(.top, 10)
                        
                        Text("\(post.distanceFromNow) · \(post.calculateDistanceFromLocation(latitude: 42.50807, longitude: 83.40217)) away")
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
            .toolbarBackground(post.authorColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            // MARK: View Launch Code
            // If we haven't loaded the user's profile yet, transport it!
            if let userID = Auth.auth().currentUser?.uid {
                User.transportUserFromServer(userID,
                                             onError: { error in fatalError(error.localizedDescription) },
                                             onSuccess: { user in currentUser = user })
                
                // Set up a real-time listener for the user's profile!
                usersCollection.document(userID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { currentUser = User.dedictify(snapshotData) }
                    }
                })
            }
            // Set up a real-time listener for this post!
            postsCollection.document(post.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data() { post = Post.dedictify(snapshotData) }
                }
            })
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostDetailView(post: .constant(Post.sample))
        }
    }
}

// MARK: Support Views
struct CommentsView: View {
    
    var comments: [Post]
    var post: Post
    var barColor: Color = .clear
    
    var body: some View {
        ForEach(comments, id: \.UUID) { eachComment in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 37.5))
                            .foregroundColor(eachComment.authorColor)
                        
                        Text(eachComment.authorEmoji)
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
                
                PostOptionView(post: eachComment, showTopBar: false, showText: false, seperateControls: false, cornerRadius: 0, bottomBarFont: .body)
                
                CommentsView(comments: eachComment.comments, post: post, barColor: eachComment.authorColor)
                    .padding(.leading)
            }
        }
    }
}
