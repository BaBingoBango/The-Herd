//
//  PostBrowserView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/3/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

/// An app view written in SwiftUI!
struct PostBrowserView: View {
    
    // MARK: View Variables
    @State var currentUserExists = false
    @ObservedObject var currentUser: User = .getSample()
    @StateObject var locationManager = LocationManager()
    @State var showingProfileView = false
    @ObservedObject var posts = PostListViewModel()
    @State var postUpdate = Operation()
    @State var showingNewPostView = false
    @State var showingScanView = false
    @State var showingRolodex = false
    @State var areMorePosts = false
    var batchSize = 5
    @State var scannedSnapshots: [DocumentSnapshot] = []
    @State var startAfterPoint: DocumentSnapshot? = nil
    @State var newlyCreatedPost: Post = .sample
    @State private var refreshView = false
    
    // MARK: View Body
    var body: some View {
        let postBrowserView = NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    Button(action: {
                        showingScanView = true
                    }) {
                        HStack {
                            if currentUserExists {
                                switch currentUser.locationMode {
                                case .current:
                                    Image(systemName: locationManager.locationStatus == .authorizedWhenInUse ? "location.fill" : "location.slash.fill")
                                        .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                        .fontWeight(.bold)
                                        .foregroundColor(locationManager.locationStatus == .authorizedWhenInUse ? .blue : .gray)
                                    
                                case .saved(locationID: let locationID):
                                    if let locationEmoji = currentUser.savedLocations[locationID]?.emoji {
                                        Text(locationEmoji)
                                            .dynamicFont(.title, padding: 0)
                                            .fontWeight(.bold)
                                        
                                    } else {
                                        Image(systemName: "location.fill")
                                            .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                                            .fontWeight(.bold)
                                            .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                ProgressView()
                                    .controlSize(.large)
                                    .padding(.trailing, 1)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(verbatim: "are more posts? \(areMorePosts)")
                                Text(verbatim: "batch size:  \(batchSize)")
                                Text(verbatim: "scanned snapshots: \(scannedSnapshots.count)")
                                Text(verbatim: "start after point: \(startAfterPoint?.data()?["text"] ?? "nil")")
                                
                                Text("Scan Location")
                                    .dynamicFont(.callout, fontDesign: .rounded, lineLimit: 4, padding: 0)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 5) {
                                    Text(verbatim: {
                                        if currentUserExists {
                                            switch currentUser.locationMode {
                                            case .current:
                                                return locationManager.locationStatus == .authorizedWhenInUse ? "Current Location" : "Location Unknown"
                                            case .saved(locationID: let locationID):
                                                return currentUser.savedLocations[locationID]?.nickname ?? "Not Scanning"
                                            }
                                        }
                                        return "Loading..."
                                    }())
                                        .dynamicFont(.title2, fontDesign: .rounded, lineLimit: 4, padding: 0)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.primary)
                                        .fontWeight(.bold)
                                    
                                    if currentUserExists {
                                        Image(systemName: "chevron.right")
                                            .dynamicFont(.headline, fontDesign: .rounded, padding: 0)
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if currentUserExists {
                                VStack {
                                    Text("RANGE")
                                        .dynamicFont(.callout, fontDesign: .monospaced, padding: 0)
                                        .foregroundColor(.primary)
                                    
                                    Text((locationManager.locationStatus != .authorizedWhenInUse && currentUser.locationMode == .current) ? "0mi" : "5mi")
                                        .dynamicFont(.title3, fontDesign: .monospaced, padding: 0)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding()
                        .modifier(RectangleWrapper(color: {
                            if currentUserExists {
                                switch currentUser.locationMode {
                                case .current:
                                    return locationManager.locationStatus == .authorizedWhenInUse ? .blue : .gray
                                case .saved(locationID: let locationID):
                                    return currentUser.savedLocations[locationID] != nil ? currentUser.savedLocations[locationID]!.color : .gray
                                }
                            }
                            return .gray
                            
                        }(), useGradient: true, opacity: 0.15))
                    }
                    .disabled(!currentUserExists)
                    .sheet(isPresented: $showingScanView) {
                        ScanLocationsView(currentUser: currentUser)
                    }
                    
                    if currentUserExists {
                        if currentUser.locationMode == .current && locationManager.locationStatus != .authorizedWhenInUse {
                            Image(systemName: "location.fill.viewfinder")
                                .dynamicFont(.system(size: 75), fontDesign: .rounded)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.top, 30)
                            
                            Text("Location Unknown")
                                .dynamicFont(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            Text("Grant location access in Settings or choose a custom location by tapping on the banner above.")
                                .dynamicFont(.headline, lineLimit: 10)
                                .fontWeight(.regular)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        
                        } else {
                            switch postUpdate.status {
                            case .failure:
                                EmptyCollectionView(iconName: "wifi.slash", heading: "Couldn't Update Posts", text: postUpdate.errorMessage)
                                
                            case .success, .inProgress:
                                if posts.posts.isEmpty && postUpdate.status != .inProgress {
                                    EmptyCollectionView(iconName: "face.dashed", heading: "No Posts Yet", text: "Looks like you're the first one here!")
                                }
                                
                                if currentUserExists {
                                    ForEach(Array(posts.posts.enumerated()), id: \.offset) { index, eachPost in
                                        PostOptionView(post: $posts.posts[index], activateNavigation: true, currentUser: currentUser, locationManager: locationManager, parentPost: eachPost, newlyCreatedPost: $newlyCreatedPost)
                                            .onAppear {
                                                // Set up a real-time listener for this post!
                                                postsCollection.document(posts.posts[index].UUID).addSnapshotListener({ snapshot, error in
                                                    if let snapshot = snapshot {
                                                        if let snapshotData = snapshot.data(), let arrayIndex = posts.posts.firstIndex(where: { $0.UUID == eachPost.UUID }) {
                                                            print("updating post...")
//                                                            posts.posts[index] = Post.dedictify(snapshotData)
                                                            print("post comments: \(posts.posts[arrayIndex].comments.count)")
                                                            posts.posts[arrayIndex].replaceFields(Post.dedictify(snapshotData))
                                                            print("post comments: \(posts.posts[arrayIndex].comments.count)")
                                                        }
                                                        refreshView.toggle()
                                                    }
                                                })
                                            }
                                            .isHidden(currentUser.blockedUserIDs.contains(posts.posts[index].authorUUID), remove: true)
                                    }
                                    
                                    if postUpdate.status != .inProgress && areMorePosts {
                                        ProgressView()
                                            .onAppear {
                                                Task { await getLatestPosts() }
                                            }
                                    }
                                }
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            .onChange(of: newlyCreatedPost) { _ in
                if newlyCreatedPost.UUID != Post.sample.UUID {
                    posts.posts.insert(newlyCreatedPost, at: 0)
                }
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
                                .foregroundColor(currentUserExists ? currentUser.color : .gray.opacity(0.25))

                            if currentUserExists {
                                Text(currentUser.emoji)
                                    .font(.system(size: 20))
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    .sheet(isPresented: $showingProfileView) {
                        ProfileView(currentUser: currentUser, locationManager: locationManager, newlyCreatedPost: $newlyCreatedPost)
                    }
                    .disabled(!currentUserExists || currentUser.getLocation(locationManager) == nil)
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
                        ManagePostsView(currentUser: currentUser, locationManager: locationManager, newlyCreatedPost: $newlyCreatedPost)
                    }
                    .disabled(!currentUserExists || currentUser.getLocation(locationManager) == nil)
                }
            })
        }
        .refreshable {
            posts.posts.removeAll()
            startAfterPoint = nil
            await getLatestPosts()
        }
        .onAppear {
            // MARK: View Launch Code
            // Add preview data!
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                posts.posts = Post.getSamples()
                currentUser.replaceFields(.getSample())
                currentUserExists = true
                postUpdate.status = .success
                return
            }
            
            // If we haven't loaded the user's profile yet, transport it!
            if let userID = Auth.auth().currentUser?.uid {
                User.transportUserFromServer(userID,
                                             onError: { error in fatalError(error.localizedDescription) },
                                             onSuccess: { user in currentUser.replaceFields(user); Task { await getLatestPosts() } })
                
                // Set up a real-time listener for the user's profile!
                usersCollection.document(userID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { currentUser.replaceFields(User.dedictify(snapshotData)); currentUserExists = true }
                    }
                })
            }
        }
        
        TabView {
            postBrowserView
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
            ChatsView(currentUser: currentUser, locationManager: locationManager, newlyCreatedPost: $newlyCreatedPost)
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
                }
            AddressBookView(currentUser: currentUser, mentions: .constant([]), excludedUserIDs: [], locationManager: locationManager, newlyCreatedPost: $newlyCreatedPost)
                .tabItem {
                    Label("Rolodex", systemImage: "person.text.rectangle.fill")
                }
        }
    }
    
    // MARK: View Functions
    func getLatestPosts() async {
        postUpdate.status = .inProgress
        areMorePosts = false
        var postsInRange = 0
        
        var scanLocation = CLLocation()
        switch currentUser.locationMode {
        case .current:
            if let lastLocation = locationManager.lastLocation {
                scanLocation = lastLocation
            } else {
                postUpdate.setError(message: "Current Location mode is enabled but couldn't access the device's location.")
                return
            }
        case .saved(locationID: let locationID):
            if let savedLocation = currentUser.savedLocations[locationID] {
                scanLocation = CLLocation(latitude: savedLocation.latitude, longitude: savedLocation.longitude)
            } else {
                postUpdate.setError(message: "The location is set to a saved location which does not exist on the server.")
                return
            }
        }
        
        // 5 miles = 8,046.72 m = 8.04672 km
        let scanQuery = GeoFirestore(collectionRef: postsCollection).query(withCenter: scanLocation, radius: 8.04672)
        scanQuery.searchLimit = batchSize + 1
        scanQuery.orderField = "timePosted"; scanQuery.orderDescending = true
        scanQuery.startAfterPoint = startAfterPoint
        
        var postsTransported = 0
        let _ = scanQuery.observe(.documentEntered, with: { documentID, _ in
            if let documentID = documentID {
                
                postsInRange += 1
                Post.transportFromServer(path: postsCollection.document(documentID),
                                         operation: nil,
                                         onError: { error in postUpdate.setError(message: error.localizedDescription); return },
                                         onSuccess: { post, snapshot in
                    
                    posts.posts.append(post)
                    scannedSnapshots.append(snapshot)
                    postsTransported += 1
                    
                    if postsTransported == postsInRange { // FIXME: not guaranteed that detection numbers stay ahead of tramsport numbers; e.g. posts in range is calculated as we go, instead of divined in advance
                        posts.posts.sort(by: { $0.timePosted > $1.timePosted })
                        scannedSnapshots.sort(by: { Post.dedictify($0.data()!).timePosted > Post.dedictify($1.data()!).timePosted })
                        startAfterPoint = scannedSnapshots.last!
                        
                        if postsTransported == batchSize + 1 {
                            areMorePosts = true
                            posts.posts.removeLast()
                            scannedSnapshots.removeLast()
                            startAfterPoint = scannedSnapshots.last!
                        }
                        scannedSnapshots.removeAll()
                        scanQuery.removeAllObservers()
                        postUpdate.status = .success
                    }
                })
            } else {
                postUpdate.setError(message: "TODO: add error message!"); return
            }
        })
        let _ = scanQuery.observeReady {
            if postsInRange == 0 {
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
