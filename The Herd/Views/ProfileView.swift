//
//  ProfileView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/12/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// An app view written in SwiftUI!
struct ProfileView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var currentUser: User = .getSample()
    var locationManager = LocationManager()
    @State var loadActivity = Operation()
    @State var karmaScore = 0
    @StateObject var savedPosts = PostListViewModel()
    @StateObject var userPosts = PostListViewModel()
    @State var selectedActivityView = 1
    @Binding var newlyCreatedPost: Post
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 2.5) {
                    HStack(alignment: .center) {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 75))
                                .foregroundColor(currentUser.color)
                            
                            Text(currentUser.emoji)
                                .font(.system(size: 45))
                        }
                        .shadow(color: .gray, radius: 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 10) {
                                Label(loadActivity.status == .success ? String(karmaScore) : "---", systemImage: "hand.thumbsup.fill")
                                    .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Label(loadActivity.status == .success ? String(userPosts.posts.count) : "---", systemImage: "bubble.left.fill")
                                    .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Image(systemName: "laurel.leading")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                Text("Since \(currentUser.formatJoinDate())")
                                    .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "laurel.trailing")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    switch loadActivity.status {
                    case .failure:
                        EmptyCollectionView(iconName: "person.crop.circle.fill", heading: "Couldn't Load Profile", text: loadActivity.errorMessage)
                        
                    case .success:
//                        HStack {
//                            Text("Activity")
//                                .dynamicFont(.title, padding: 0)
//                                .fontWeight(.bold)
//                            Spacer()
//                        }
//                        .padding(.top, 5)
                        
                        Picker(selection: $selectedActivityView, label: Text("")) {
                            Text("Your Posts").tag(1)
                            Text("Saved Posts").tag(2)
//                            Text("Comments").tag(3)
//                            Text("Votes").tag(4)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom, 5)
                        
                        switch selectedActivityView {
                        case 1:
                            if userPosts.posts.isEmpty {
                                EmptyCollectionView(iconName: "ellipsis.bubble.fill", heading: "No Posts", text: "")
                            }
                            ForEach(Array(userPosts.posts.enumerated()), id: \.offset) { index, eachPost in
                                PostOptionView(post: $userPosts.posts[index], activateNavigation: true, currentUser: currentUser, locationManager: locationManager, parentPost: eachPost, newlyCreatedPost: $newlyCreatedPost)
                            }
                            
                        case 2:
                            if savedPosts.posts.isEmpty {
                                EmptyCollectionView(iconName: "bookmark.slash.fill", heading: "No Saved Posts", text: "")
                            }
                            ForEach(Array(savedPosts.posts.enumerated()), id: \.offset) { index, eachPost in
                                PostOptionView(post: $userPosts.posts[index], activateNavigation: true, currentUser: currentUser, locationManager: locationManager, parentPost: eachPost, newlyCreatedPost: $newlyCreatedPost)
                            }
                            
                        case 3:
                            Text("nothing yet...")
                            
                        default:
                            Text("nothing yet...")
                        }
                        
                    default:
                        ProgressView()
                            .controlSize(.large)
                            .padding(.top, 10)
                    }
                }
                .padding([.horizontal, .bottom])
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView(currentUser: currentUser)) {
                        Image(systemName: "gear")
                            .fontWeight(.bold)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            })
        }
        .onAppear {
            // MARK: View Launch Code
            // TODO: query stuff!
            loadActivity.status = .inProgress
            
            // Query for the user's saved post IDs!
            var savedPostIDs: [String] = [""] // TODO: possible inefficency if no saved posts but not that bad probs
            Firestore.firestore().collectionGroup("saved").whereField("userUUID", isEqualTo: currentUser.UUID).order(by: "dateSaved", descending: true).getDocuments { snapshots, error in
                if let error = error {
                    loadActivity.setError(message: error.localizedDescription)
                    
                } else {
                    for eachDocument in snapshots!.documents {
                        savedPostIDs.append(SavedPostRecord.dedictify(eachDocument.data()).postUUID)
                    }
                    
                    // TODO: query the Post object for each saved ID then on success do the next one!
                    // TODO: speed this up by using diff threads for each?
                    postsCollection.whereField("UUID", in: savedPostIDs).getDocuments { snapshots, error in
                        if let error = error {
                            loadActivity.setError(message: error.localizedDescription)
                            
                        } else {
                            for eachDocument in snapshots!.documents {
                                savedPosts.posts.append(Post.dedictify(eachDocument.data()))
                            }
                            
                            // Query for the user's posts!
                            postsCollection.whereField("authorUUID", isEqualTo: currentUser.UUID).order(by: "timePosted", descending: true).getDocuments() { snapshots, error in
                                if let error = error {
                                    loadActivity.setError(message: error.localizedDescription)
                                    
                                } else {
                                    for eachDocument in snapshots!.documents {
                                        userPosts.posts.append(Post.dedictify(eachDocument.data()))
                                    }
                                    
                                    postsCollection.whereFilter(.orFilter([
                                        .whereField("associatedUserIDs", arrayContains: currentUser.UUID),
                                        .whereField("authorUUID", isEqualTo: currentUser.UUID)
                                    ])).getDocuments() { snapshots, error in
                                        if let error = error {
                                            loadActivity.setError(message: error.localizedDescription)
                                            
                                        } else {
                                            for eachDocument in snapshots!.documents {
                                                let post = Post.dedictify(eachDocument.data())
                                                karmaScore += post.getUserKarma(currentUser.UUID)
                                            }
                                            loadActivity.status = .success
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(newlyCreatedPost: .constant(.sample))
    }
}

// MARK: Support Views
// Support views go here! :)
