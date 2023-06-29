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
    @State var savedPosts: [Post] = []
    @State var userPosts: [Post] = []
    @State var selectedActivityView = 1
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    HStack {
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
                                Label(loadActivity.status == .success ? "???" : "---", systemImage: "hand.thumbsup.fill")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Label(loadActivity.status == .success ? String(userPosts.count) : "---", systemImage: "bubble.left.fill")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Image(systemName: "laurel.leading")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                Text("Since \(currentUser.formatJoinDate())")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
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
                    
                    switch loadActivity.status {
                    case .failure:
                        Text("error: \(loadActivity.errorMessage)")
                        
                    case .success:
                        HStack {
                            Text("Activity")
                                .dynamicFont(.title, padding: 0)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.top, 5)
                        
                        Picker(selection: $selectedActivityView, label: Text("")) {
                            Text("Saved").tag(1)
                            Text("Posts").tag(2)
                            Text("Comments").tag(3)
                            Text("Votes").tag(4)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch selectedActivityView {
                        case 1:
                            if savedPosts.isEmpty {
                                Text("no saved posts!")
                            }
                            ForEach(savedPosts, id: \.UUID) { eachPost in
                                PostOptionView(post: eachPost, activateNavigation: true, currentUser: currentUser, locationManager: locationManager)
                            }
                            
                        case 2:
                            if userPosts.isEmpty {
                                Text("no user posts!")
                            }
                            ForEach(userPosts, id: \.UUID) { eachPost in
                                PostOptionView(post: eachPost, activateNavigation: true, currentUser: currentUser, locationManager: locationManager)
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
                .padding(.horizontal)
            }
            
            // MARK: Navigation Settings
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
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
                                savedPosts.append(Post.dedictify(eachDocument.data()))
                            }
                            
                            // Query for the user's posts!
                            postsCollection.whereField("authorUUID", isEqualTo: currentUser.UUID).order(by: "timePosted", descending: true).getDocuments() { snapshots, error in
                                if let error = error {
                                    loadActivity.setError(message: error.localizedDescription)
                                    
                                } else {
                                    for eachDocument in snapshots!.documents {
                                        userPosts.append(Post.dedictify(eachDocument.data()))
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
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// MARK: Support Views
// Support views go here! :)
