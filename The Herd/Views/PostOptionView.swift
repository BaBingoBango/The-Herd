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
    var activateNavigation = false
    @State var showingPostDetail = false
    var currentUser = User.getSample()
    var locationManager = LocationManager()
    var showTopBar = true
    var showText = true
    var seperateControls = true
    var cornerRadius = 20.0
    var bottomBarFont: Font = .headline
    var blockRecursion = false
    @State var deletePost = Operation()
    var voteValue: Int {
        post.votes[currentUser.UUID]?.value ?? 0
    }
    var hasUserCommented: Bool {
        Post.hasUserCommented(post.comments, userUUID: currentUser.UUID)
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
                    
                    Text("\(post.distanceFromNow) · \(post.calculateDistanceFromLocation(latitude: currentUser.getLocation(locationManager)!.0, longitude: currentUser.getLocation(locationManager)!.1)) away")
                        .dynamicFont(.callout, padding: 0)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                        .offset(y: -4.5)
                    
                    Spacer()
                    
                    if !blockRecursion {
                        Menu {
                            let viewCopy = PostOptionView(post: post, currentUser: currentUser, locationManager: locationManager, blockRecursion: true).frame(width: 500)
                            let viewImage = Image(uiImage: ImageRenderer(content: viewCopy).uiImage!)
                            
                            ShareLink(item: viewImage, preview: SharePreview(post.text, image: viewImage)) {
                                Label("Share...", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: {}) { // TODO: add saving!
                                Label("Save Post", systemImage: "bookmark")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive, action: {
                                deletePost.status = .inProgress
                                
                                // TODO: add delete!
                            }) {
                                Label("Delete Post", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        }
                        .offset(y: -5)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .offset(y: -8)
            }
            
            NavigationLink(destination: PostDetailView(post: $post, currentUser: currentUser), isActive: $showingPostDetail) { EmptyView() }
            
            switch deletePost.status {
            case .inProgress:
                HStack {
                    Spacer()
                    
                    VStack(spacing: 7.5) {
                        ProgressView()
                            .controlSize(.large)
                        
                        Text("Deleting...")
                            .dynamicFont(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
            case .success:
                HStack {
                    Spacer()
                    
                    VStack(spacing: 7.5) {
                        Image(systemName: "trash")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text("Post Deleted")
                            .dynamicFont(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
            default:
                Button(action: {
                    if activateNavigation { showingPostDetail = true }
                }) {
                    VStack(alignment: .leading) {
                        if showText {
                            Text(post.text)
                                .dynamicFont(.title2, lineLimit: 100, padding: 0)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 15)
                                .padding(.top, showTopBar ? 5 : 20)
                                .padding(.horizontal)
                        }
                        
                        HStack {
                            Label("\(Post.countComments(post.comments))", systemImage: hasUserCommented ? "bubble.left.fill" : "bubble.left")
                                .dynamicFont(bottomBarFont, padding: 0)
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
                                    .dynamicFont(bottomBarFont, padding: 0)
                                    .fontWeight(.semibold)
                                    .foregroundColor(voteValue == 1 ? .green : .secondary)
                            }
                            
                            Text("\(post.score)")
                                .dynamicFont(bottomBarFont, padding: 0)
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
                                    .dynamicFont(bottomBarFont, padding: 0)
                                    .fontWeight(.semibold)
                                    .foregroundColor(voteValue == -1 ? .red : .secondary)
                            }
                        }
                        .padding(.horizontal, seperateControls ? 15 : 5)
                    }
                }
            }
        }
        .padding(.bottom)
        .modifier(RectangleWrapper(color: post.author.color, useGradient: true, opacity:  !blockRecursion ? 0.15 : 0.75, cornerRadius: cornerRadius, hideRectangle: !showText))
        .padding(.top, showTopBar ? 15 : 0)
    }
    
    // MARK: View Functions
    func changeVote(newValue: Int) {
        let originalPost = post
        let newVote = Vote(voter: currentUser, value: newValue, timePosted: Date())
        post.votes[currentUser.UUID] = newVote
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
