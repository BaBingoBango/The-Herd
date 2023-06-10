//
//  PostBrowserView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import SwiftUI
import FirebaseFunctions

/// An app view written in SwiftUI!
struct PostBrowserView: View {
    
    // MARK: View Variables
    @State var posts: [Post] = []
    @State var postUpdate = Operation()
    @State var isShowingNewPostView = false
    
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
                            PostOptionView(post: eachPost)
                        }
                        
                    default:
                        ProgressView()
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Posts")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingNewPostView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                    .sheet(isPresented: $isShowingNewPostView) {
                        EmptyView()
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
