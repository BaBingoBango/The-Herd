//
//  ProfileView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/12/23.
//

import SwiftUI
import FirebaseAuth

/// An app view written in SwiftUI!
struct ProfileView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var currentUser: User? = nil
    @State var loadActivity = Operation()
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
                                .foregroundColor(currentUser?.color ?? .gray.opacity(0.25))
                            
                            if let currentUser = currentUser {
                                Text(currentUser.emoji)
                                    .font(.system(size: 45))
                            } else {
                                ProgressView()
                            }
                        }
                        .shadow(color: .gray, radius: 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 10) {
                                Label("5000", systemImage: "hand.thumbsup.fill")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Label("145", systemImage: "bubble.left.fill")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Image(systemName: "laurel.leading")
                                    .dynamicFont(.title2, fontDesign: .rounded, padding: 0)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                
                                Text("Since June 2023")
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
                            Text("Posts").tag(1)
                            Text("Comments").tag(2)
                            Text("Votes").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch selectedActivityView{
                        case 1:
                            if userPosts.isEmpty {
                                Text("no user posts!")
                            }
                            
                            ForEach(userPosts, id: \.UUID) { eachPost in
                                PostOptionView(post: eachPost, currentUser: currentUser!)
                            }
                            
                        case 2:
                            Text("nothing yet...")
                            
                        default:
                            Text("nothing yet...")
                        }
                        
                    default:
                        ProgressView()
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
        .onChange(of: currentUser) { _ in
            if let currentUser = currentUser {
                loadActivity.status = .inProgress
                
                // Query the server for the user's posts!
                postsCollection.whereField("author.UUID", isEqualTo: currentUser.UUID).getDocuments() { snapshot, error in
                    if let error = error {
                        loadActivity.setError(message: error.localizedDescription)
                        
                    } else {
                        for eachDocument in snapshot!.documents {
                            userPosts.append(Post.dedictify(eachDocument.data()))
                        }
                        
                        loadActivity.status = .success
                    }
                }
            }
        }
        .onAppear {
            // MARK: View Launch Code
            // Add preview data!
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                currentUser = .getSample()
                return
            }
            
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
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// MARK: Support Views
// Support views go here! :)
