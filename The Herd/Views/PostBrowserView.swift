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
    @ObservedObject var currentUser: User = .getSample()
    @State var updates: [LocationMode] = []
    @State var locationMode: LocationMode = .none
    @State var showingProfileView = false
    @State var posts: [Post] = []
    @State var postUpdate = Operation()
    @State var showingNewPostView = false
    @State var showingScanView = false
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Text(String(updates.last?.toString() ?? "0 elements"))
                    Text(String(updates.count))
                    if updates.count >= 1 { Text(String(updates[0].toString())) }
                    
                    Button(action: {
                        showingScanView = true
                    }) {
                        HStack {
                            if true {
                                switch locationMode {
                                case .none:
                                    Image(systemName: "location.slash.fill")
                                        .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    
                                case .current:
                                    Image(systemName: "location.fill")
                                        .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                case .saved(locationID: let locationID):
                                    if let locationEmoji = currentUser.savedLocations[locationID]?.emoji {
                                        Text(locationEmoji)
                                            .dynamicFont(.title, padding: 0)
                                            .fontWeight(.bold)
                                        
                                    } else {
                                        Image(systemName: "location.fill")
                                            .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            } else {
                                ProgressView()
                                    .controlSize(.large)
                                    .padding(.trailing, 1)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Scan Location")
                                    .dynamicFont(.callout, fontDesign: .rounded, lineLimit: 4, padding: 0)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 5) {
                                    Text(verbatim: {
                                        if true {
                                            switch locationMode {
                                            case .none:
                                                return "Not Scanning"
                                            case .current:
                                                return "Current Location"
                                            case .saved(locationID: let locationID):
                                                return currentUser.savedLocations[locationID]?.nickname ?? "Not Scanning"
                                            }
                                        }
                                        return "Loading..."
                                    }())
                                        .dynamicFont(.title2, fontDesign: .rounded, lineLimit: 4, padding: 0)
                                        .foregroundColor(.primary)
                                        .fontWeight(.bold)
                                    
                                    if currentUser != nil {
                                        Image(systemName: "chevron.right")
                                            .dynamicFont(.headline, fontDesign: .rounded, padding: 0)
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if true {
                                VStack {
                                    Text("RANGE")
                                        .dynamicFont(.callout, fontDesign: .monospaced, padding: 0)
                                        .foregroundColor(.primary)
                                    
                                    Text(locationMode != .none ? "5mi" : "0mi")
                                        .dynamicFont(.title3, fontDesign: .monospaced, padding: 0)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding()
                        .modifier(RectangleWrapper(color: {
                            if true {
                                switch locationMode {
                                case .none:
                                    return .gray
                                case .current:
                                    return .blue
                                case .saved(locationID: let locationID):
                                    return currentUser.savedLocations[locationID] != nil ? .accentColor : .gray
                                }
                            }
                            return .gray
                            
                        }(), useGradient: true, opacity: 0.15))
                    }
                    .disabled(currentUser == nil)
                    .sheet(isPresented: $showingScanView) {
                        ScanLocationsView(currentUser: currentUser)
                    }
                    
                    switch postUpdate.status {
                    case .failure:
                        Text("error: \(postUpdate.errorMessage)")
                        
                    case .success:
                        if posts.isEmpty {
                            Text("no posts!")
                        }
                        
                        if true {
                            ForEach(posts, id: \.UUID) { eachPost in
                                NavigationLink(destination: PostDetailView(post: $posts.first(where: { $0.wrappedValue.UUID == eachPost.UUID })!, currentUser: currentUser)) {
                                    PostOptionView(post: eachPost, currentUser: currentUser)
                                }
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
                                .foregroundColor(currentUser.color ?? .gray.opacity(0.25))

                            if true {
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
        .refreshable {
            await getLatestPosts()
        }
        .onAppear {
            // MARK: View Launch Code
            // Add preview data!
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                posts = Post.getSamples()
                currentUser.replace(.getSample())
                postUpdate.status = .success
                return
            }
            
            Task { await getLatestPosts() }
            
            // If we haven't loaded the user's profile yet, transport it!
            if let userID = Auth.auth().currentUser?.uid {
                User.transportUserFromServer(userID,
                                             onError: { error in fatalError(error.localizedDescription) },
                                             onSuccess: { user in currentUser.replace(user) })
                
                // Set up a real-time listener for the user's profile!
                usersCollection.document(userID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { currentUser.replace(User.dedictify(snapshotData)); locationMode = currentUser.locationMode; updates.insert(currentUser.locationMode, at: 0) }
                    }
                })
            }
        }
    }
    
    // MARK: View Functions
    func getLatestPosts() async {
        // Load the posts array with 50 posts from the cloud function!
        postUpdate.status = .inProgress
        Functions.functions().httpsCallable("getLatestPosts").call([
            "latitude" : "0",
            "longitude" : "0",
            "startIndex" : "0"]) { result, error in

            // Check for errors!
            if let error = error {
                postUpdate.setError(message: error.localizedDescription)
            } else {

                // Convert the results to Post objects!
                var postObjects: [Post] = []
                for eachPostString in (result!.data as! [String : Any])["acceptedPosts"] as! [String] {
                    let postDictionary = try! JSONSerialization.jsonObject(with: eachPostString.data(using: .utf8)!, options: []) as! [String: Any]
                    postObjects.append(Post.dedictify(postDictionary))
                }

                // Update the view state with the new posts!
                posts = postObjects
                postUpdate.status = .success
            }
        }
    }
}

// MARK: View Preview
struct PostBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        PostBrowserView()
    }
}

// MARK: Support Views
// Support views go here! :)
