//
//  PostBrowserView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

/// An app view written in SwiftUI!
struct PostBrowserView: View {
    
    // MARK: View Variables
    @State var currentUser: User? = nil
    @State var showingProfileView = false
    @State var posts: [Post] = []
    @State var postUpdate = Operation()
    @State var showingNewPostView = false
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    switch postUpdate.status {
                    case .failure:
                        Text("error: \(postUpdate.errorMessage)")
                        
                    case .success:
                        if posts.isEmpty {
                            Text("no posts!")
                        }
                        
                        ForEach(posts, id: \.UUID) { eachPost in
                            NavigationLink(destination: PostDetailView(post: eachPost)) {
                                PostOptionView(post: eachPost)
                            }
                        }
                        
                    default:
                        ProgressView()
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Nearby")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfileView = true
                    }) {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(currentUser?.color ?? .gray.opacity(0.25))

                            if let currentUser = currentUser {
                                Text(currentUser.emoji)
                                    .font(.system(size: 20))
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    .sheet(isPresented: $showingProfileView) {
                        ProfileView()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewPostView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                    .sheet(isPresented: $showingNewPostView) {
                        NewPostView()
                    }
                }
            })
        }
        .onAppear {
            // MARK: View Launch Code
            // Add preview data!
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                posts = Post.getSamples()
                postUpdate.status = .success
                return
            }
            
            posts = Post.getSamples()
            postUpdate.status = .success
            // Load the posts array with 50 posts from the cloud function!
//            postUpdate.status = .inProgress
//            Functions.functions().httpsCallable("getLatestPosts").call(["latitude" : "50", "longitude" : "50", "startIndex" : "0"]) { result, error in
//                
//                // Check for errors!
//                if let error = error {
//                    postUpdate.setError(message: error.localizedDescription)
//                } else {
//                    
//                    // Convert the results to Post objects!
//                    var postObjects: [Post] = []
//                    for eachPostString in (result!.data as! [String : Any])["acceptedPosts"] as! [String] {
//                        let postDictionary = try! JSONSerialization.jsonObject(with: eachPostString.data(using: .utf8)!, options: []) as! [String: Any]
//                        postObjects.append(Post.dedictify(postDictionary))
//                    }
//                    
//                    // Update the view state with the new posts!
//                    posts = postObjects
//                    postUpdate.status = .success
//                }
//            }
            
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
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PostBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        PostBrowserView()
    }
}

// MARK: Support Views
// Support views go here! :)
