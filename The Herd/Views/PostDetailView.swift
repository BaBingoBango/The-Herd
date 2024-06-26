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
    var commentingAnonymously: Bool
    @State var deletePost = Operation()
    @State var savePost = Operation()
    @State var isPostSaved = false
    @Binding var newlyCreatedPost: Post
    @State var refreshView = false
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // FIXME: the comment count dosen't update when new comments are added bc this is static and not a state pass-in to POV
                    // FIX? make an optional state version? probs not...acc maybe with an on change?
                    PostOptionView(post: $post, currentUser: currentUser, locationManager: locationManager, showTopBar: false, cornerRadius: 0, parentPost: post, newlyCreatedPost: $newlyCreatedPost)
                    
                    CommentsView(currentUser: currentUser, comments: $post.comments, post: $post, parentPost: post, commentingAnonymously: commentingAnonymously, newlyCreatedPost: $newlyCreatedPost, locationManager: locationManager)
                        .padding(.horizontal)
                }
                
                // MARK: Navigation Settings
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(post.authorEmoji)
                                .font(.system(size: 12.5))
                                .padding(.top, 10)
                            
                            Text("\(post.distanceFromNow) · \(post.calculateDistanceFromLocation(latitude: currentUser.getLocation(locationManager)!.0, longitude: currentUser.getLocation(locationManager)!.1)) away")
                                .font(.system(size: 15))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .padding(.bottom, 17.5)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // TODO: add menu button
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

                                    Text(commentingAnonymously ? post.getAnonymousNumber(currentUser.UUID) ?? "🕶️" : currentUser.emoji)
                                        .font(.system(size: 17, design: .monospaced))
                                        .fontDesign(.monospaced)
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
        }
        .onAppear {
            // Set up a real-time listener for this post's comments!
            postsCollection.document(post.UUID).addSnapshotListener({ snapshot, error in
                if let snapshot = snapshot {
                    if let snapshotData = snapshot.data() {
                        post.replaceFields(Post.dedictify(snapshotData))
                    }
                    refreshView.toggle()
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
            PostDetailView(post: .constant(Post.sample), commentingAnonymously: false, newlyCreatedPost: .constant(.sample))
        }
    }
}

// MARK: Support Views
struct CommentsView: View {
    
    var currentUser = User.getSample()
    @Binding var comments: [Post]
    @Binding var post: Post
    var barColor: Color = .clear
    var parentPost: Post?
    var commentingAnonymously: Bool
    @Binding var newlyCreatedPost: Post
    var locationManager = LocationManager()
    
    var body: some View {
        ForEach(Array(comments.enumerated()), id: \.offset) { eachIndex, eachComment in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 37.5))
                            .foregroundColor(parentPost!.getAnonymousNumber(eachComment.authorUUID) != nil ? .gray : eachComment.authorColor)
                        
                        Text(parentPost!.getAnonymousNumber(eachComment.authorUUID) ?? eachComment.authorEmoji)
                            .font(.system(size: 22.5))
                            .fontDesign(.monospaced)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text(eachComment.distanceFromNow)
                        .font(.system(size: 17.5))
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(eachComment.text)
                        .dynamicFont(.title3, fontDesign: currentUser.fontPreference.toFontDesign(), lineLimit: 15, padding: 0)
                        .fontWeight(.medium)
                        .padding(.leading, 7.5)
                        .padding(.bottom)
                    
                    Spacer()
                }
                
                if eachIndex < post.comments.count {
                    PostOptionView(post: $post.comments[eachIndex], currentUser: currentUser, locationManager: locationManager, showTopBar: false, showText: false, seperateControls: false, cornerRadius: 0, bottomBarFont: .body, parentPost: parentPost ?? post, newlyCreatedPost: $newlyCreatedPost)
                }
                
                if !eachComment.comments.isEmpty {
                    HStack {
                        Rectangle()
                            .frame(width: 4)
                            .cornerRadius(10)
                            .foregroundColor(parentPost!.getAnonymousNumber(eachComment.authorUUID) != nil ? .gray : eachComment.authorColor)
                            .padding(.trailing, 7.5)
                            .isHidden({
                                for eachSecondLevelComment in eachComment.comments {
                                    if currentUser.blockedUserIDs.contains(eachSecondLevelComment.authorUUID) {
                                        return true
                                    }
                                }
                                return false
                            }(), remove: true)
                        
                        VStack {
                            ForEach(Array(eachComment.comments.enumerated()), id: \.offset) { eachSecondIndex, eachSecondComment in
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        ZStack {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 37.5))
                                                .foregroundColor(parentPost!.getAnonymousNumber(eachSecondComment.authorUUID) != nil ? .gray : eachSecondComment.authorColor)
                                            
                                            Text(parentPost!.getAnonymousNumber(eachSecondComment.authorUUID) ?? eachSecondComment.authorEmoji)
                                                .font(.system(size: 22.5))
                                                .fontDesign(.monospaced)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text(eachSecondComment.distanceFromNow)
                                            .font(.system(size: 17.5))
                                            .fontWeight(.heavy)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text(eachSecondComment.text)
                                            .dynamicFont(.title3, fontDesign: currentUser.fontPreference.toFontDesign(), lineLimit: 15, padding: 0)
                                            .fontWeight(.medium)
                                            .padding(.leading, 7.5)
                                            .padding(.bottom)
                                        
                                        Spacer()
                                    }
                                    
                                    if eachSecondIndex < post.comments.count {
                                        PostOptionView(post: $post.comments[eachSecondIndex], currentUser: currentUser, locationManager: locationManager, showTopBar: false, showText: false, seperateControls: false, cornerRadius: 0, bottomBarFont: .body, parentPost: parentPost ?? post, newlyCreatedPost: $newlyCreatedPost)
                                    }
                                }
                                .isHidden(currentUser.blockedUserIDs.contains(eachComment.authorUUID), remove: true)
                            }
                        }
                    }
                }
            }
            .isHidden(currentUser.blockedUserIDs.contains(eachComment.authorUUID), remove: true)
        }
    }
}
