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
    @State var posts: [Post] = []
    @State var postUpdate = Operation()
    @State var showingNewPostView = false
    @State var showingScanView = false
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
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
                                    return currentUser.savedLocations[locationID] != nil ? .accentColor : .gray
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
                                Text("error: \(postUpdate.errorMessage)")
                                
                            case .success:
                                if posts.isEmpty {
                                    Text("no posts!")
                                }
                                
                                if currentUserExists {
                                    ForEach(posts, id: \.UUID) { eachPost in
                                        PostOptionView(post: eachPost, activateNavigation: true, currentUser: currentUser, locationManager: locationManager)
                                    }
                                }
                                
                            default:
                                ProgressView()
                                    .controlSize(.large)
                                    .padding(.top, 30)
                            }
                        }
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
                        ProfileView(currentUser: currentUser, locationManager: locationManager)
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
                        ManagePostsView(currentUser: currentUser, locationManager: locationManager)
                    }
                    .disabled(!currentUserExists || currentUser.getLocation(locationManager) == nil)
                }
            })
        }
        .refreshable {
            await getLatestPosts()
        }
        .onChange(of: showingNewPostView) { newValue in
            if !newValue { Task { await getLatestPosts() } }
        }
        .onChange(of: currentUser.locationMode) { _ in
            Task { await getLatestPosts() }
        }
        .onAppear {
            // MARK: View Launch Code
            // Add preview data!
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                posts = Post.getSamples()
                currentUser.replaceFields(.getSample())
                currentUserExists = true
                postUpdate.status = .success
                return
            }
            
            // If we haven't loaded the user's profile yet, transport it!
            if let userID = Auth.auth().currentUser?.uid {
                User.transportUserFromServer(userID,
                                             onError: { error in fatalError(error.localizedDescription) },
                                             onSuccess: { user in currentUser.replaceFields(user) })
                
                // Set up a real-time listener for the user's profile!
                usersCollection.document(userID).addSnapshotListener({ snapshot, error in
                    if let snapshot = snapshot {
                        if let snapshotData = snapshot.data() { currentUser.replaceFields(User.dedictify(snapshotData)); currentUserExists = true }
                    }
                })
            }
        }
    }
    
    // MARK: View Functions
    func getLatestPosts() async {
        postUpdate.status = .inProgress
        posts.removeAll()
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
        let _ = scanQuery.observe(.documentEntered, with: { documentID, _ in
            if let documentID = documentID {
                
                postsInRange += 1
                
                Post.transportFromServer(path: postsCollection.document(documentID),
                                         operation: nil,
                                         onError: { error in postUpdate.setError(message: error.localizedDescription) },
                                         onSuccess: { post in
                    
                    posts.append(post)
                    if posts.count == postsInRange {
                        posts.sort(by: { $0.timePosted > $1.timePosted }) // TODO: fix this! (querying literally every post is that the issue? lol i think so)
                        postUpdate.status = .success
                    }
                })
            } else {
                postUpdate.setError(message: "TODO: add error message!")
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
