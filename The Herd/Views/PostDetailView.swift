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
    @ObservedObject var currentUser: User = .getSample()
    var locationManager = LocationManager()
    @State var showingCommentField = false
    @State var commentFieldDetent = PresentationDetent.large
    @AppStorage("postingAnonymously") var postingAnonymously = false
    var commentingAnonymously: Bool {
        let hasSpokenAnonymously = post.anonymousIdentifierTable.contains(where: { $0.key == currentUser.UUID })
        if post.authorUUID == currentUser.UUID {
            return hasSpokenAnonymously
        } else {
            return hasSpokenAnonymously || postingAnonymously
        }
    }
    var anonymousNumber: String {
        var number = post.anonymousIdentifierTable[currentUser.UUID] ?? post.anonymousIdentifierTable.count
        if number == 0 {
            return "🕶️"
        } else if number / 10 >= 1 {
            return String(number)
        } else {
            return "0" + String(number)
        }
    }
    @State var deletePost = Operation()
    @State var savePost = Operation()
    @State var isPostSaved = false
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // FIXME: the comment count dosen't update when new comments are added bc this is static and not a state pass-in to POV
                    // FIX? make an optional state version? probs not...acc maybe with an on change?
                    PostOptionView(post: post, currentUser: currentUser, showTopBar: false, cornerRadius: 0)
                    
                    CommentsView(currentUser: currentUser, comments: post.comments, post: post)
                        .padding(.horizontal)
                }
                
                // MARK: Navigation Settings
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(post.authorEmoji)
                                .font(.system(size: 25))
                                .padding(.top, 10)
                            
                            Text("\(post.distanceFromNow) · \(post.calculateDistanceFromLocation(latitude: currentUser.getLocation(locationManager)!.0, longitude: currentUser.getLocation(locationManager)!.1)) away")
                                .font(.system(size: 15))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .padding(.bottom, 17.5)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // FIXME: post already is a binding - why would it let us use $post?
    //                    PostMenuButton(post: $post, currentUser: currentUser, locationManager: locationManager, deletePost: $deletePost, savePost: $savePost, isPostSaved: $isPostSaved, makeBold: true)
                    }
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: {
                            showingCommentField = true
                        }) {
                            HStack {
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 25))
                                        .foregroundColor(commentingAnonymously ? .gray : currentUser.color)

                                    Text(commentingAnonymously ? anonymousNumber : currentUser.emoji)
                                        .font(.system(size: 17, design: .monospaced))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }

                                Text("Reply to this post...")
                                    .dynamicFont(.body, padding: 0)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .sheet(isPresented: $showingCommentField) {
                            CommentFieldView(commentingAnonymously: commentingAnonymously, post: $post, currentUser: currentUser, locationManager: locationManager, parentPost: post)
                                .presentationDetents([.medium, .large], selection: $commentFieldDetent)
                        }
                        .padding(.bottom, 5)

                        Spacer()
                    }
                })
                .toolbarBackground(post.authorColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar(.visible, for: .bottomBar)
            }
            .onAppear {
                // MARK: View Launch Code
                // Set up a real-time listener for this post!
                postsCollection.document(post.UUID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { post = Post.dedictify(snapshotData) }
                    }
                })
            }
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
    
    var currentUser = User.getSample()
    var comments: [Post]
    var post: Post
    var barColor: Color = .clear
    var parentPost: Post?
    
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
                
                HStack {
                    Text(eachComment.text)
                        .font(.system(size: 22.5, design: .default))
                        .fontWeight(.medium)
                        .padding(.leading, 7.5)
                        .padding(.bottom)
                    
                    Spacer()
                }
                
                PostOptionView(post: eachComment, currentUser: currentUser, showTopBar: false, showText: false, seperateControls: false, cornerRadius: 0, bottomBarFont: .body, parentPost: parentPost ?? post)
                
                if !eachComment.comments.isEmpty {
                    HStack {
                        Rectangle()
                            .frame(width: 4)
                            .cornerRadius(10)
                            .foregroundColor(eachComment.authorColor)
                        
                        VStack {
                            CommentsView(currentUser: currentUser, comments: eachComment.comments, post: post, barColor: eachComment.authorColor, parentPost: post)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, 1)
                        }
                    }
                }
            }
        }
    }
}
